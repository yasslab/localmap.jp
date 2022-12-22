#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'yaml'
require 'json'

MARKERS_YAML = 'markers.yaml'
marker_data  = YAML.unsafe_load_file(MARKERS_YAML, symbolize_names: true)

features    = []
marker_data.each do |marker|
  next if marker[:title].chomp.eql? '404_Not_Found'

  features << {
    type: "Feature",
    geometry: {
      type: "Point",
      coordinates: [marker[:lng], marker[:lat]]
    },
    properties: {
      'marker-size'   => 'small',
      #'marker-size'   => 'medium',
      'marker-symbol' => 'minkei',
      #'marker-color'  => 'rgba(45, 105, 176, 0.7)', # BabaKeizai Blue
      'marker-color' => 'rgba(237, 208, 70, 0.8)', # BabaKeizai Yellow
      description: <<~DESCRIPTION
        <a target='_blank' rel='noopener' href='#{marker[:link]}'>
          <img src='#{marker[:image]}' alt='#{marker[:title]}'
               width='100%' loading='lazy' />
        </a>
        <a target='_blank' rel='noopener' href='#{marker[:link]}'>#{marker[:title]}</a>
        <small>(#{marker[:date]})</small>
      DESCRIPTION
    }
  }
end

geojson = {
  "type": "FeatureCollection",
  "features": features
}

File.open("markers.geojson", "w") do |file|
  JSON.dump(geojson, file)
end

