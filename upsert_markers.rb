#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

MARKERS_YAML = 'markers.yaml'
BASE_URL     = 'https://takadanobaba.keizai.biz/mapnews/'
CASE_LAT     = '35.7120933'
CASE_LNG     = '139.7047394'
MAX_GET_REQS = 20
#BASE_MAP    = 'https://maps.google.com/maps?q='

require 'mechanize'
mechanize = Mechanize.new
mechanize.user_agent_alias = 'Windows Chrome'
existing_marker_ids = YAML.unsafe_load_file(MARKERS_YAML) ?
                      YAML.unsafe_load_file(MARKERS_YAML).map{|h| h['id']} :
                      [0]
upserted_marker_data = File.read('markers.yaml')

count_request = 0
(1..1000).each do |id|
  next  if existing_marker_ids.include? id
  break if (count_request += 1) > MAX_GET_REQS # Restrict max GET requests to send

  begin
    html  = mechanize.get(BASE_URL + id.to_s)
  rescue Mechanize::ResponseCodeError => error
    puts 'ERROR: ' + error.response_code + ' - ' + BASE_URL + id.to_s
  end

  if html.search('time').text.empty? == false
    date    = html.search('time').text
    link    = html.search('li.send a').attribute('href').value
    title   = html.search('h1').last.text
    image   = html.at('meta[property="og:image"]').attributes['content'].value.gsub('mapnews','headline')
    lat,lng = html.search('p#mapLink a').attribute('href').value[31..].split(',')
    puts "[#{id.to_s.rjust(4, '0')}] #{title}"

    # 位置情報が抜けている場合は CASE Shinjuku の位置情報を入力
    upserted_marker_data << <<~NEW_MARKER
      - id:    #{id}
        lat:   #{lat.nil? ? CASE_LAT + ' # NOT_FOUND' : lat }
        lng:   #{lng.nil? ? CASE_LNG + ' # NOT_FOUND' : lng }
        link:  #{link}
        date:  #{date}
        image: #{image}
        title: |
          #{title}
      NEW_MARKER
  else
    puts "[#{id.to_s.rjust(4, '0')}] 404 Not Found"
    upserted_marker_data << <<~NEW_MARKER
      - id:    #{id}
        lat:   #{CASE_LAT}
        lng:   #{CASE_LNG}
        link:  https://takadanobaba.keizai.biz/
        date:  2000-01-23
        image: https://images.keizai.biz/img/logo/takadanobaba_keizai.png
        title: |
          404_Not_Found
      NEW_MARKER
  end

  #puts upserted_marker_data
end

descending_result = YAML.unsafe_load(upserted_marker_data).sort_by{ |marker| marker['id'] }.reverse

YAML.dump(descending_result, File.open(MARKERS_YAML, 'w')) unless upserted_marker_data.empty?
