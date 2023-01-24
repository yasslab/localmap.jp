#!/usr/bin/env ruby
require 'yaml'
require 'json'

if ARGV.length != 1
  puts "Usage: ./compact_geojson.rb MINKEI_TARGET"
  puts " e.g.: ./compact_geojson.rb takadanobaba"
  puts "       This above compacts Takadanobaba's geojson data for better loadin."
  puts ""
  exit(1)
end

GIVEN_AREA    = ARGV[0].downcase
TARGETS_YAML  = '_data/targets.yml'
ALLOWED_AREAS = YAML.unsafe_load_file(TARGETS_YAML, symbolize_names: true)
unless ALLOWED_AREAS.map{|h| h[:id]}.include? GIVEN_AREA
  puts "Sorry, the given area '#{GIVEN_AREA}' is not allowed to aggregate."
  puts "ALLOED_AREAS: " + ALLOWED_AREAS.map{|h| h[:id]}.join(', ')
  puts ""
  exit(1)
end
TARGET_AREA = ALLOWED_AREAS.select{|area| area[:id] == GIVEN_AREA }.first

# Just compact it for better loading by Computer
geojson = JSON.load(File.read "_data/#{TARGET_AREA[:id]}.geojson")
File.open("#{TARGET_AREA[:id]}.min.geojson", 'w') do |file|
  JSON.dump(geojson, file)
end
