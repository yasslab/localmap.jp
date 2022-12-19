#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'json'
require 'csv'

posts = CSV.parse(File.read("posts.csv"), headers: true)

features = []
posts.each do |post|
  features << {
    "type" => "Feature",
    "geometry" => {
      "type" => "Point",
      "coordinates" => [post["lng"], post["lat"]]
    },
    "properties" => {
      "marker-size" => "large",
      "description" => "<a target='_blank' href='#{post['url']}'>#{post['title']}</a>"
    }
  }
end

geojson = {
  "type": "FeatureCollection",
  "features": features
}

File.open("posts.geojson", "w") do |file|
  JSON.dump(geojson, file)
end
