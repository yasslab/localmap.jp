#!/usr/bin/env ruby
require 'yaml'
require 'json'

if ARGV.length != 1
  puts "Usage: ./build_page.rb MINKEI_TARGET"
  puts " e.g.: ./build_page.rb takadanobaba"
  puts "       This builds /takadanobaba page with GeoJSON compaction."
  puts ""
  exit(1)
end

GIVEN_AREA    = ARGV[0].downcase
TARGETS_YAML  = '_data/maps.yml'
ALLOWED_AREAS = YAML.unsafe_load_file(TARGETS_YAML, symbolize_names: true)
unless ALLOWED_AREAS.map{|h| h[:id]}.include? GIVEN_AREA
  puts "Sorry, the given area '#{GIVEN_AREA}' is not allowed to build."
  puts "ALLOED_AREAS: " + ALLOWED_AREAS.map{|h| h[:id]}.join(', ')
  puts ""
  exit(1)
end
TARGET_AREA = ALLOWED_AREAS.select{|area| area[:id] == GIVEN_AREA }.first

# Build page and post it to '_posts/' directory
File.open("./_posts/2023-02-01-#{TARGET_AREA[:id]}.md", 'w') do |file|
  TARGET_PAGE = <<~MARKDOWN
    ---
    layout: map
    permalink: /#{TARGET_AREA[:id]}
    ---
  MARKDOWN

  file.write(TARGET_PAGE)
end

# Compact GeoJSON for better loading by web browser
geojson = JSON.load(File.read "_data/#{TARGET_AREA[:id]}.geojson")
File.open("./public/#{TARGET_AREA[:id]}.min.geojson", 'w') do |file|
  JSON.dump(geojson, file)
end
