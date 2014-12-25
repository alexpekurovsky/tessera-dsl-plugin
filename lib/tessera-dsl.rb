#!/usr/bin/env ruby

require 'json'
require 'time'

@output ||= []

def dashboard(&block)
	@output.push TesseraDSL.build(&block).result
end


module TesseraDSL

	def self.build(&block)
		$global_count = 1
		dashboard = Dashboard.new
		dashboard.instance_eval(&block)
		@queries = []
		dashboard.result[:definition][:items].each do |section|
			section[:items].each do |row|
				row[:items].each do |cell|
					cell[:items].each do |graph|
						if graph[:query]
							@queries.push({:name => graph[:query], :targets => [graph[:query_target]]})
							graph.delete(:query_target)
						end
						if graph[:query_other]
							@queries.push({:name => graph[:query_other], :targets => [graph[:query_other_target]]})
							graph.delete(:query_other_target)
						end
					end
				end
			end
		end
		dashboard.result[:definition][:queries] = {}
		if @queries
			@queries.each do |query|
				dashboard.result[:definition][:queries][query[:name].to_sym] = {:name => query[:name], :targets => query[:targets]}
			end
		end
		return dashboard
	end

	class Dashboard
		attr_accessor :result

		def initialize
			@result = {}
			@result.compare_by_identity
			@result[:title] = "Default Title"
			@result[:creation_date] = Time.now.utc.iso8601(6)
			@result[:category] = "Default Category"
			@result[:description] = "Default Description"
			@result[:imported_from] = nil
			@result[:summary] = "Default Summary"
			@result[:tags] = []
		end

		%w{title creation_date category description summary tags}.each do |meth|
			define_method meth, ->(value) { 
				@result[meth.to_sym] = value
			}
		end

		def definition(&block)
			definition = Definition.new
			definition.instance_eval(&block)
			@result[:definition] = definition.result
		end

	end

	class Definition
		attr_accessor :result

		def initialize
			$global_count += 1
			@result = {}
			@result[:css_class] = nil
			@result[:height] = nil
			@result[:item_id] = "d#{$global_count}"
			@result[:item_type] = "dashboard_definition"
			@result[:style] = nil
			@result[:items] = []
		end

		%w{css_class height item_id style}.each do |meth|
			define_method meth, ->(value) {
				@result[meth.to_sym] = value
			}
		end

		def section(&block)
			section = Section.new
			section.instance_eval(&block)
			@result[:items].push(section.result)
		end

	end

	class Section
		attr_accessor :result

		def initialize
			$global_count += 1
			@result = {}
			@result[:css_class] = nil
			@result[:height] = nil
			@result[:item_id] = "d#{$global_count}"
			@result[:item_type] = "section"
			@result[:layout] = "fixed"
			@result[:style] = nil
			@result[:title] = nil
			@result[:items] = []
		end

		%w{css_class height item_id layout style title}.each do |meth|
			define_method meth, ->(value) {
				@result[meth.to_sym] = value
			}
		end
		
		def row(&block)
			row = Row.new
			row.instance_eval(&block)
			@result[:items].push(row.result)
		end

	end

	class Row
		attr_accessor :result
	
		def initialize
			$global_count += 1
			@result = {}
			@result[:css_class] = nil
			@result[:height] = nil	
			@result[:item_id] = "d#{$global_count}"
			@result[:item_type] = "row"
			@result[:style] = nil
			@result[:items] = []
		end

		%w{css_class height item_id style}.each do |meth|
			define_method meth, ->(value) {
				@result[meth.to_sym] = value
			}
		end

		def cell(&block)
			cell = Cell.new
			cell.instance_eval(&block)
			@result[:items].push(cell.result)
		end

	end

	class Cell
		attr_accessor :result

		def initialize
			$global_count += 1
			@result = {}
			@result[:align] = nil
			@result[:css_class] = nil
			@result[:height] = nil
			@result[:item_id] = "d#{$global_count}"
			@result[:item_type] = "cell"
			@result[:offset] = nil
			@result[:span] = "3"
			@result[:style] = nil
			@result[:items] = []
		end

		%w{align css_clas height item_id offset span style}.each do |meth|
			define_method meth, ->(value) {
				@result[meth.to_sym] = value
			}
		end
	
		%w{ 
			separator
			markdown
			heading
			jumbotron_singlestat
			singlestat
			comparison_summation_table
			percentage_table
			summation_table
			timeshift_summation_table
			stacked_area_chart
			singlegraph
			standard_time_series
			simple_time_series
			donut_chart
		}.each do |meth|
			eval("
				def #{meth}(&block)
					#{meth} = #{meth.split("_").map(&:capitalize).join('_')}.new
					#{meth}.instance_eval(&block)
					@result[:items].push(#{meth}.result)
				end
			")
		end	

	end

	class Separator
		attr_accessor :result

		def initialize
			$global_count
			@result = {}
			@result[:item_id] = "d#{$global_count}"
			@result[:item_type] = "separator"
			@result[:css_class] = nil
			@result[:style] = nil
			@result[:height] = nil
		end

		%w{css_class item_id style height}.each do |meth|
			define_method meth, ->(value) {
				@result[meth.to_sym] = value
			}
		end
	
	end

	class Markdown
		attr_accessor :result

		def initialize
			$global_count += 1
			@result = {}
			@result[:css_class] = nil
			@result[:height] = nil
			@result[:item_id] = "d#{$global_count}"
			@result[:item_type] = "markdown"
			@result[:raw] = false
			@result[:text] = nil
			@result[:style] = nil
		end

		%w{css_class height item_id raw text style}.each do |meth|
			define_method meth, ->(value) {
				@result[meth.to_sym] = value
			}
		end

	end

	class Heading
		attr_accessor :result

                def initialize
			$global_count += 1
                        @result = {}
			@result[:css_class] = nil
                        @result[:description] = nil
			@result[:height] = nil
                        @result[:item_id] = "d#{$global_count}"
                        @result[:item_type] = "heading"
                        @result[:level] = "1"
                        @result[:text] = nil
			@result[:style] = nil
                end

                %w{description item_id level text height css_class style}.each do |meth|
                        define_method meth, ->(value) {
                                @result[meth.to_sym] = value
                        }
                end

        end 

	class Jumbotron_Singlestat
		attr_accessor :result, :query

		def initialize
			$global_count += 1
			@result = {}
			@result[:css_class] = nil
			@result[:format] = ",.3s"
			@result[:height] = nil
			@result[:index] = false
			@result[:item_id] = "d#{$global_count}"
			@result[:item_type] = "jumbotron_singlestat"
			@result[:thresholds] = nil
			@result[:title] = ""
			@result[:transform] = "max"
			@result[:query] = nil
			@result[:style] = nil
			@result[:units] = nil
		end

		%w{css_class format height index item_id thresholds title transform units style}.each do |meth|
			define_method meth, ->(value) {
				@result[meth.to_sym] = value
			}
		end

		def query(&block)
			query = Query.new
			query.instance_eval(&block)
			@result[:query] = query.result[:name]
			@result[:query_target] = query.result[:target]
		end
	
	end

	class Singlestat
		attr_accessor :result, :query

		def initialize
			$global_count += 1
			@result = {}
			@result[:css_class] = nil
			@result[:format] = ",.3s"
			@result[:height] = nil
			@result[:index] = false
			@result[:item_id] = "d#{$global_count}"
			@result[:item_type] = "singlestat"
			@result[:title] = ""
			@result[:thresholds] = nil
			@result[:transform] = "mean"
			@result[:query] = nil
			@result[:style] = nil
			@result[:units] = nil
		end

		%w{css_class format height index item_id title transform units style thresholds}.each do |meth|
			define_method meth, ->(value) {
				@result[meth.to_sym] = value
			}
		end

		def query(&block)
			query = Query.new
                        query.instance_eval(&block)
                        @result[:query] = query.result[:name]
                        @result[:query_target] = query.result[:target]
                end

	end

	class Comparison_Summation_Table
		attr_accessor :result, :query, :query_other
	
		def initialize
			$global_count += 1
			@result = {}
			@result[:css_class] = nil
			@result[:format] = ",.3s"
			@result[:height] = nil
			@result[:item_id] = "d#{$global_count}"
			@result[:item_type] = "comparison_summation_table"
			@result[:striped] = false
			@result[:style] = nil
			@result[:title] = ""
		end

		%w{css_class format item_id striped title height style}.each do |meth|
			define_method meth, ->(value) {
				@result[meth.to_sym] = value
			}
		end

		def query(&block)
                        query = Query.new
                        query.instance_eval(&block)
                        @result[:query] = query.result[:name]
                        @result[:query_target] = query.result[:target]
                end

		def query_other(&block)
                        query = Query.new
                        query.instance_eval(&block)
                        @result[:query_other] = query.result[:name]
                        @result[:query_other_target] = query.result[:target]
                end
	
	end


	class Percentage_Table
		attr_accessor :result, :query

		def initialize
			$global_count += 1
			@result = {}
			@result[:css_class] = nil
			@result[:format] = ",.3s"
			@result[:height] = nil
			@result[:include_sums] = false
			@result[:item_id] = "d#{$global_count}"
			@result[:item_type] = "percentage_table"
			@result[:title] = ""
			@result[:style] = nil
		end

		%w{css_class format height include_sums item_id title style}.each do |meth|
			define_method meth, ->(value) {
				@result[meth.to_sym] = value
			}
		end

		def query(&block)
                        query = Query.new
                        query.instance_eval(&block)
                        @result[:query] = query.result[:name]
                        @result[:query_target] = query.result[:target]
                end

	end

	class Summation_Table
		attr_accessor :result, :query

		def initialize
			$global_count += 1
			@result = {}
			@result[:css_class] = nil
			@result[:format] = ",.3s"
			@result[:height] = nil
			@result[:item_id] = "d#{$global_count}"
			@result[:item_type] = "summation_table"
#
# Commented due to bug in tessera. It doesn't save these fields
#
#			@result[:show_color] = false
#			@result[:sortable] = false
#
			@result[:striped] = false
			@result[:query] = nil
			@result[:thresholds] = nil
			@result[:title] = ""
			@result[:style] = nil
		end

		%w{css_class format height item_id striped title thresholds style}.each do |meth|
			define_method meth, ->(value) {
				@result[meth.to_sym] = value
			}
		end

		def query(&block)
                        query = Query.new
                        query.instance_eval(&block)
                        @result[:query] = query.result[:name]
                        @result[:query_target] = query.result[:target]
                end

	end

	class Timeshift_Summation_Table
                attr_accessor :result, :query

                def initialize
			$global_count += 1
                        @result = {}
                        @result[:css_class] = nil
			@result[:height] = nil
                        @result[:format] = ",.3s"
                        @result[:item_id] = "d#{$global_count}"
                        @result[:item_type] = "timeshift_summation_table"
                        @result[:shift] = "1d"
			@result[:style] = nil
                        @result[:title] = ""
                end

                %w{css_class format item_id shift title height style}.each do |meth|
                        define_method meth, ->(value) {
                                @result[meth.to_sym] = value
                        }
                end

                def query(&block)
                        query = Query.new
                        query.instance_eval(&block)
                        @result[:query] = query.result[:name]
                        @result[:query_target] = query.result[:target]
                end

        end

	class Stacked_Area_Chart
                attr_accessor :result, :query

                def initialize
			$global_count += 1
                        @result = {}
                        @result[:css_class] = nil
                        @result[:height] = nil
			@result[:interactive] = true
                        @result[:item_id] = "d#{$global_count}"
                        @result[:item_type] = "stacked_area_chart"
			@result[:options] = {}
			@result[:options][:palette] = nil
			@result[:options][:y1] = {}
			@result[:options][:y1][:label] = nil
			@result[:options][:y1][:max] = nil
			@result[:options][:y1][:min] = nil
			@result[:query] = nil
                        @result[:title] = ""
			@result[:thresholds] = nil
			@result[:style] = nil
                end

                %w{css_class height interactive item_id title thresholds style}.each do |meth|
                        define_method meth, ->(value) {
                                @result[meth.to_sym] = value
                        }
                end

		%w{palette}.each do |meth|
			define_method meth, ->(value) {
				@result[:options][meth.to_sym] = value
			}
		end
		
		%w{label max min}.each do |meth|
			define_method meth, ->(value) {
				@result[:options][:y1][meth.to_sym] = value
			}
		end

                def query(&block)
                        query = Query.new
                        query.instance_eval(&block)
                        @result[:query] = query.result[:name]
                        @result[:query_target] = query.result[:target]
                end

        end

	class Singlegraph
                attr_accessor :result, :query

                def initialize
			$global_count += 1
                        @result = {}
                        @result[:css_class] = nil
			@result[:format] = ",.1s"
                        @result[:height] = nil
                        @result[:item_id] = "d#{$global_count}"
                        @result[:item_type] = "singlegraph"
			@result[:interactive] = true
                        @result[:options] = {}
                        @result[:options][:palette] = nil
                        @result[:options][:y1] = {}
                        @result[:options][:y1][:label] = nil
                        @result[:options][:y1][:max] = nil
                        @result[:options][:y1][:min] = nil
			@result[:style] = nil
                        @result[:title] = ""
			@result[:thresholds] = nil
			@result[:transform] = "mean"
			@result[:query] = nil
                end

                %w{css_class format height interactive item_id style title thresholds transform}.each do |meth|
                        define_method meth, ->(value) {
                                @result[meth.to_sym] = value
                        }
                end

                %w{palette}.each do |meth|
                        define_method meth, ->(value) {
                                @result[:options][meth.to_sym] = value
                        }
                end

                %w{label max min}.each do |meth|
                        define_method meth, ->(value) {
                                @result[:options][:y1][meth.to_sym] = value
                        }
                end

                def query(&block)
                        query = Query.new
                        query.instance_eval(&block)
                        @result[:query] = query.result[:name]
                        @result[:query_target] = query.result[:target]
                end

        end

	class Standard_Time_Series
                attr_accessor :result, :query

                def initialize
			$global_count += 1
                        @result = {}
                        @result[:css_class] = nil
                        @result[:height] = nil
			@result[:interactive] = true
                        @result[:item_id] = "d#{$global_count}"
                        @result[:item_type] = "standard_time_series"
                        @result[:options] = {}
                        @result[:options][:palette] = nil
                        @result[:options][:y1] = {}
                        @result[:options][:y1][:label] = nil
                        @result[:options][:y1][:max] = nil
                        @result[:options][:y1][:min] = nil
			@result[:query] = nil
			@result[:thresholds] = nil
                        @result[:title] = ""
			@result[:style] = nil
                end

                %w{css_class height interactive item_id thresholds title style}.each do |meth|
                        define_method meth, ->(value) {
                                @result[meth.to_sym] = value
                        }
                end

                %w{palette}.each do |meth|
                        define_method meth, ->(value) {
                                @result[:options][meth.to_sym] = value
                        }
                end

                %w{label max min}.each do |meth|
                        define_method meth, ->(value) {
                                @result[:options][:y1][meth.to_sym] = value
                        }
                end

                def query(&block)
                        query = Query.new
                        query.instance_eval(&block)
                        @result[:query] = query.result[:name]
                        @result[:query_target] = query.result[:target]
                end

        end

	class Simple_Time_Series
                attr_accessor :result, :query

                def initialize
			$global_count += 1
                        @result = {}
                        @result[:css_class] = nil
			@result[:filled] = true
                        @result[:height] = nil
			@result[:interactive] = true
                        @result[:item_id] = "d#{$global_count}"
                        @result[:item_type] = "simple_time_series"
                        @result[:options] = {}
                        @result[:options][:palette] = nil
                        @result[:options][:y1] = {}
                        @result[:options][:y1][:label] = nil
                        @result[:options][:y1][:max] = nil
                        @result[:options][:y1][:min] = nil
                        @result[:title] = ""
			@result[:thresholds] = nil
			@result[:style] = nil
			@result[:query] = nil
                end

                %w{css_class filled interactive height item_id title thresholds style}.each do |meth|
                        define_method meth, ->(value) {
                                @result[meth.to_sym] = value
                        }
                end

                %w{palette}.each do |meth|
                        define_method meth, ->(value) {
                                @result[:options][meth.to_sym] = value
                        }
                end

                %w{label max min}.each do |meth|
                        define_method meth, ->(value) {
                                @result[:options][:y1][meth.to_sym] = value
                        }
                end

                def query(&block)
                        query = Query.new
                        query.instance_eval(&block)
                        @result[:query] = query.result[:name]
                        @result[:query_target] = query.result[:target]
                end

        end

	class Donut_Chart
                attr_accessor :result, :query

                def initialize
			$global_count += 1
                        @result = {}
                        @result[:css_class] = nil
                        @result[:height] = nil
			@result[:interactive] = true
                        @result[:item_id] = "d#{$global_count}"
                        @result[:item_type] = "donut_chart"
                        @result[:options] = {}
                        @result[:options][:palette] = nil
                        @result[:options][:y1] = {}
                        @result[:options][:y1][:label] = nil
                        @result[:options][:y1][:max] = nil
                        @result[:options][:y1][:min] = nil
                        @result[:title] = ""
			@result[:thresholds] = nil
			@result[:style] = nil
			@result[:query] = nil
                end

                %w{css_class height interactive item_id title thresholds style}.each do |meth|
                        define_method meth, ->(value) {
                                @result[meth.to_sym] = value
                        }
                end

                %w{palette}.each do |meth|
                        define_method meth, ->(value) {
                                @result[:options][meth.to_sym] = value
                        }
                end

                %w{label max min}.each do |meth|
                        define_method meth, ->(value) {
                                @result[:options][:y1][meth.to_sym] = value
                        }
                end

                def query(&block)
                        query = Query.new
                        query.instance_eval(&block)
                        @result[:query] = query.result[:name]
                        @result[:query_target] = query.result[:target]
                end

        end

	class Query
		attr_accessor :result

		def initialize
			@result = {}
			@result[:name] = ""
			@result[:target] = ""
		end

		%w{name target}.each do |meth|
			define_method meth, ->(value) {
				@result[meth.to_sym] = value
			}
		end
	
	end

end

