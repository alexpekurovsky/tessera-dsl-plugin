#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'time'

class Hash
  def diff(other)
    (self.keys + other.keys).uniq.inject({}) do |memo, key|
      unless self[key] == other[key]
        if self[key].kind_of?(Hash) &&  other[key].kind_of?(Hash)
          memo[key] = self[key].diff(other[key])
        else
          memo[key] = [self[key], other[key]] 
        end
      end
      memo
    end
  end
end

class TesseraAPI
	attr_accessor :config, :filter

	def initialize(configfile = 'etc/tessera-dsl.conf')
		@config = {}
		IO.foreach(configfile) do |line|
			line.chomp!
			key, value = line.split("=", 2)
			@config[key.strip.to_sym] = value.strip
		end
	end

	def send_request (method, url, data = nil)
		uri = URI.parse(@config[:tessera_url] + url)
		http = Net::HTTP.new(uri.host)
		request = eval("Net::HTTP::#{method.capitalize}.new('#{uri.request_uri}')")
		if data
			request.initialize_http_header({'Content-Type' =>'application/json'})
			request.body = data.to_json
		end
		response = http.request(request)
		json = JSON.parse(response.body, {:symbolize_names => true})
		json
	end

	def get_dashboard (id = nil)
		dashboard = send_request("get", "/api/dashboard/" + (!id.nil? ? id.to_s : ""))
		if id
			dashboard[:definition] = send_request("get", "/api/dashboard/" + id.to_s + "/definition")
		end
		dashboard
	end

	def method_missing(meth, *args, &block)
		if meth.to_s =~ /^get_dashboard_by_(.+)$/
			run_get_dashboard_by_method($1, *args, &block)
		else
			super
		end
	end

	def run_get_dashboard_by_method(attrs, *args, &block)
		attrs = attrs.split('_and_')
		conditions = Hash[attrs.zip args.flatten]
		conditions = Hash[conditions.map { |k,v| [k.to_sym, v] }]
		dashboards = get_dashboard
		dashboard = dashboards.select { |d| d.merge(conditions) == d }
		if !dashboard.empty?
			dashboard = get_dashboard(dashboard.first[:id])
			dashboard[:conditions] = conditions
			dashboard
		else
			return nil
		end
	end

	def create_filter(json)
		@filter = []
		attrs = @config[:identity].split('_and_')
		attrs.each do |attr|
			@filter.push(json[attr.to_sym])
		end
		@filter
	end

	def update_dashboard(data, *args)
		dashboard = self.send("get_dashboard_by_#{self.config[:identity]}", args.flatten)
		if dashboard
			id = dashboard[:id]
			conditions = dashboard[:conditions]
			dashboard.delete(:conditions)
			%w{creation_date definition_href href id last_modified_date view_href}.each do |param|
				data[param.to_sym] = dashboard[param.to_sym]
			end
			%w{dashboard_href href}.each do |param|
				data[:definition][param.to_sym] = dashboard[:definition][param.to_sym]
			end
			dashboard[:tags].each do |tag|
				tag.delete(:count)
				tag.delete(:id)
			end
			dashboard[:tags] = dashboard[:tags].map{ |t| t.values }.flatten
			if data.diff(dashboard) == {}
				puts "No update is required for #{conditions.to_s}"
			else
				puts "Updating #{conditions.to_s}"
				data[:last_modified_date] = Time.now.utc.iso8601(6) 
				send_request("put", "/api/dashboard/" + id.to_s, data)
				send_request("put", "/api/dashboard/" + id.to_s + "/definition", data[:definition])
			end
		else
			create_dashboard(data)
		end 
	end

	def create_dashboard(data)
		puts "Dashboard not found. Creating new one."
		data[:creation_date] = Time.now.utc.iso8601(6)
		send_request("post", "/api/dashboard/", data)
	end
end

