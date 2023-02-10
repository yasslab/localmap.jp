#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'yaml'
require 'json'

if ARGV.length != 1
  puts "Usage: ./upsert_geojson.rb MINKEI_TARGET"
  puts " e.g.: ./upsert_geojson.rb takadanobaba"
  puts "       This above fetches Takadanobaba's geojson data to generate 馬場経マップ"
  puts ""
  exit(1)
end

GIVEN_AREA    = ARGV[0].downcase
TARGETS_YAML  = '_data/maps.yml'
ALLOWED_AREAS = YAML.unsafe_load_file(TARGETS_YAML, symbolize_names: true)
unless ALLOWED_AREAS.map{|h| h[:id]}.include? GIVEN_AREA
  puts "Sorry, the given area '#{GIVEN_AREA}' is not allowed to aggregate."
  puts "ALLOED_AREAS: " + ALLOWED_AREAS.map{|h| h[:id]}.join(', ')
  puts ""
  exit(1)
end
TARGET_AREA  = ALLOWED_AREAS.select{|area| area[:id] == GIVEN_AREA }.first

MARKERS_YAML = "_data/#{TARGET_AREA[:id]}.yml"
unless File.exist? MARKERS_YAML
  puts "No File Found: #{MARKERS_YAML}"
  puts "Did you exec? `$ ./upsert_markers.rb #{TARGET_AREA[:id]}`"
  puts
  exit(1)
end

marker_data = YAML.unsafe_load_file(MARKERS_YAML, symbolize_names: true)
features    = []
description = ''

# Prototype: https://github.com/yasslab/localmap.jp/pull/11
#dups_coords = marker_data.map{|m| [m[:lng], m[:lat]] }.tally.select{|k,v| v > 1}

marker_data.each do |marker|
  next if marker[:title].chomp.eql? '404_Not_Found'

  description = <<~DESCRIPTION
    <a target='_blank' rel='noopener' href='#{marker[:link]}'>
      <img src='#{marker[:image]}' alt='#{marker[:title]}' width='100%' loading='lazy' />
    </a>
    <a target='_blank' rel='noopener' href='#{marker[:link]}'>#{marker[:title]}</a>
    <small>(#{marker[:date]})</small>
    DESCRIPTION

  # Prototype: https://github.com/yasslab/localmap.jp/pull/11
  #if not dups_coords[[marker[:lng], marker[:lat]]].nil?
  #  marker[:lng] = (marker[:lng].floor(4).to_s + rand(100).to_s).to_f
  #  marker[:lat] = (marker[:lat].floor(4).to_s + rand(100).to_s).to_f
  #end

  features << {
    type: "Feature",
    geometry: {
      type: "Point",
      coordinates: [
        marker[:lng],
        marker[:lat],
      ],
    },
    properties: {
      'marker-size'   => 'small',
      #'marker-size'   => 'medium',
      'marker-symbol' => 'minkei',
      #'marker-color'  => 'rgba(45, 105, 176, 0.7)', # Minkei Blue
      'marker-color' => 'rgba(237, 208, 70, 0.8)',   # Minkei Yellow
      description: description.gsub("\n  ", '').gsub("\n", ''),
    }
  }
end

geojson = {
  "type": "FeatureCollection",
  "features": features
}

PRETTY_GEOJSON = JSON.pretty_generate(geojson)
File.open("_data/#{TARGET_AREA[:id]}.geojson", "w") do |file|
  file.write(PRETTY_GEOJSON)
  #JSON.dump(geojson, file)
end
