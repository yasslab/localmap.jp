#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'mechanize'

if ARGV.length != 1
  puts "Usage: ./upsert_markers.rb MINKEI_TARGET"
  puts " e.g.: ./upsert_markers.rb takadanobaba"
  puts "       This above fetches Takadanobaba's map data to generate 馬場経マップ"
  puts ""
  exit(1)
end

GIVEN_AREA    = ARGV[0].downcase
TARGETS_YAML  = 'targets.yml'
ALLOWED_AREAS = YAML.unsafe_load_file(TARGETS_YAML, symbolize_names: true)
unless ALLOWED_AREAS.map{|h| h[:name]}.include? GIVEN_AREA
  puts "Sorry, the given area '#{GIVEN_AREA}' is not allowed to aggregate."
  puts "ALLOED_AREAS: " + ALLOWED_AREAS.map{|h| h[:name]}.join(', ')
  puts ""
  exit(1)
end
TARGET_AREA  = ALLOWED_AREAS.select{|area| area[:name] == GIVEN_AREA }.first

BASE_URL     = "https://#{TARGET_AREA[:name]}.keizai.biz"
BASE_LAT     = TARGET_AREA[:lat].to_s
BASE_LNG     = TARGET_AREA[:lng].to_s
BASE_DATE    = '2000-01-23'
BASE_LOGO    = TARGET_AREA[:logo]
MAX_GET_REQS = 20

# NOTE: If no data found, then YAML.unsafe_load_file() returns 'false'.
MARKERS_YAML = "#{TARGET_AREA[:name]}.yml"
FileUtils.touch MARKERS_YAML
existing_marker_ids = YAML.unsafe_load_file(MARKERS_YAML) ?
                      YAML.unsafe_load_file(MARKERS_YAML).map{|h| h['id']} :
                      [0]
upserted_marker_data = File.read(MARKERS_YAML)

# Start fetching articles from allowed and targeted Minkei papers
mechanize                  = Mechanize.new
mechanize.user_agent_alias = 'Windows Chrome'
latest_article = mechanize.get(BASE_URL).search('div.main a').attribute('href').value.split('/').last
count_request  = 0
(1..).each do |id|
  next (puts "Skipped: #{id}") if existing_marker_ids.include? id # Skip if already fetched marker datum
  break(puts "Reached to End") if id > latest_article.to_i # Break if reached to latest article's number
  break(puts "Reached to Max") if (count_request += 1) > MAX_GET_REQS # Break if reached to the max reqs

  begin
    html  = mechanize.get(BASE_URL + '/mapnews/' + id.to_s)
  rescue Mechanize::ResponseCodeError => error
    # 該当記事が無い場合は 404 で処理が止まり、html には nil が代入され、
    # 以降は /404.html ページにリダイレクトされる処理がキャッシュされる。
    # ただし最新の記事番号以降にはアクセスしないためココに入ることはない（はず）。
    puts 'ERROR: ' + error.response_code + ' - ' + BASE_URL + '/mapnews/' + id.to_s
    break
  end

  # mapnews から取得できた位置情報を YAML ファイルに格納する
  if html && !html.search('time').text.empty?
    date    = html.search('time').text
    link    = html.search('li.send a').attribute('href').value
    title   = html.search('h1').last.text
    image   = html.at('meta[property="og:image"]').attributes['content'].value.gsub('mapnews','headline')
    lat,lng = html.search('p#mapLink a').attribute('href').value[31..].split(',')
    puts "[#{id.to_s.rjust(4, '0')}] #{title}"

    # 一部の記事には位置情報が無い mapnews もある。
    # 無ければデフォルトの位置情報を YAML ファイルに追記する。
    upserted_marker_data << <<~NEW_MARKER
      - id:    #{id}
        src:   #{BASE_URL + '/mapnews/' + id.to_s}
        lat:   #{lat.nil? ? BASE_LAT + ' # NOT_FOUND' : lat }
        lng:   #{lng.nil? ? BASE_LNG + ' # NOT_FOUND' : lng }
        link:  #{link}
        date:  #{date}
        image: #{image}
        title: |-
          #{title}
      NEW_MARKER
  else
    # 例外処理: ネット環境が不調だったり、HTTP Request に失敗した場合など
    puts "[#{id.to_s.rjust(4, '0')}] 404 Not Found (ERROR)"
    puts 'Please investigate why no map data found in this process.'
    puts
    puts '[DEBUG INFO]' # This corresponds to 'upserted_marker_data << <<~NEW_MARKER' above.
    puts "- id:    #{id}"
    puts "  src:   #{BASE_URL + '/mapnews/' + id.to_s}"
    puts "  lat:   #{BASE_LAT}"
    puts "  lng:   #{BASE_LNG}"
    puts "  link:  #{BASE_URL}"
    puts "  date:  #{BASE_DATE}"
    puts "  image: #{BASE_LOGO}"
    puts "  title: 404_Not_Found"
    puts

    break
  end

  #puts upserted_marker_data
end

descending_result = YAML.unsafe_load(upserted_marker_data).sort_by{ |marker| marker['id'] }.reverse

# NOTE: Correct or debug YAML data here whenever you want.
#descending_result = YAML.unsafe_load_file(MARKERS_YAML).sort_by{ |marker| marker['id'] }.reverse
#descending_result = descending_result.each do |marker|
#  marker['title'].chomp!
#end

YAML.dump(descending_result, File.open(MARKERS_YAML, 'w')) unless upserted_marker_data.empty?
