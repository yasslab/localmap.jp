#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'json'
require 'mechanize'

BASE_URL = 'https://takadanobaba.keizai.biz/mapnews/'
#BASE_MAP = 'https://maps.google.com/maps?q='
agent = Mechanize.new

features = []
skipped_ids = [958]
#article_ids = [1000,997,996,993,987,984,979,977,970,964] # for debugging
#article_ids.each do |id|
(900..1000).each do |id|
  next if skipped_ids.include? id
  sleep(10) if id % 11 == 0 # Add interbal to fetch for servers

  html  = agent.get(BASE_URL + id.to_s)
  date  = html.search('time').text
  link  = html.search('li.send a').attribute('href').value
  title = html.search('h1').last.text
  #lng,lat = html.search('p#mapLink a').attribute('href').value.delete(BASE_MAP).split(',')
  lat,lng = html.search('p#mapLink a').attribute('href').value[31..].split(',')
  p "[#{id}] #{title} "

  #binding.irb
  #exit

  features << {
    type: "Feature",
    geometry: {
      type: "Point",
      coordinates: [lng, lat]
    },
    properties: {
      'marker-size'   => 'small',
      'marker-color'  => 'rgba(45, 105, 176, 0.7)', # BabaKeizai Blue
      'marker-symbol' => 'minkei',
      #'marker-color' => 'rgba(237, 208, 70, 0.8)', # BabaKeizai Yellow
      description: "<a target='_blank' rel='noopener' href='#{link}'>#{title}</a> <small>(#{date})</small>"
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

