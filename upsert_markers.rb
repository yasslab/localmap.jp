#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

MARKERS_YAML = 'markers.yaml'
BASE_URL     = 'https://takadanobaba.keizai.biz/mapnews/'
#BASE_MAP    = 'https://maps.google.com/maps?q='

require 'mechanize'
mechanize                  = Mechanize.new
mechanize.user_agent_alias = 'Windows Chrome'
existing_marker_ids = YAML.unsafe_load_file(MARKERS_YAML) ?
                      YAML.unsafe_load_file(MARKERS_YAML).map{|h| h['id']} :
                      [0]
upserted_marker_data = File.read('markers.yaml')

(1..35).each do |id|
  next if existing_marker_ids.include? id

  begin
    html  = mechanize.get(BASE_URL + id.to_s)
  rescue Mechanize::ResponseCodeError => error
    puts 'ERROR: ' + error.response_code
  end

  if html.search('time').text.empty? == false
    date  = html.search('time').text
    link  = html.search('li.send a').attribute('href').value
    title = html.search('h1').last.text
    lat,lng = html.search('p#mapLink a').attribute('href').value[31..].split(',')
    puts format("[%04d] #{title}", id)

    upserted_marker_data << <<~NEW_MARKER
    - id:    #{id}
      link:  #{link}
      date:  #{date}
      title: '#{title}'
      lat:   #{lat}
      lng:   #{lng}
    NEW_MARKER
  else
    puts "[#{id.to_s.rjust(4, '0')}] 404 Not Found"
    upserted_marker_data << <<~NEW_MARKER
    - id:    #{id}
      link:  https://takadanobaba.keizai.biz/
      date:  2000-01-23
      title: 404_Not_Found
      lat:   35.7120933
      lng:   139.7047394
    NEW_MARKER
  end

  #puts upserted_marker_data
end

IO.write(MARKERS_YAML, upserted_marker_data) unless upserted_marker_data.empty?
