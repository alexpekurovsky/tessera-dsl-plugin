#!/usr/bin/env ruby

require_relative 'lib/tessera-dsl.rb'
require_relative 'lib/tessera-api.rb'

tessera = TesseraAPI.new


input = ""
Dir['input/*.dsl'].each do |file|
	input += File.read(file)
end
eval(input)
@output.each do |dashboard|
	filters = tessera.create_filter(dashboard)
	tessera.update_dashboard(dashboard, filters)
end

