#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'mechanize'

if ARGV.length < 1 || ARGV.length > 2
  puts "Usage: ./upsert_markers.rb MINKEI_TARGET"
  puts " e.g.: ./upsert_markers.rb takadanobaba [TARGET_ARTICLE_ID]"
  puts "       This above fetches Takadanobaba's map data to generate 馬場経マップ"
  puts "       If given TARGET_ARTICLE_ID, this script updates the article only for patch."
  puts ""
  exit(1)
end

GIVEN_AREA    = ARGV[0].downcase
IS_PATCH_MODE = !ARGV[1].nil?
PATCHING_ID   = ARGV[1].to_i
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
BASE_LAT     = TARGET_AREA[:lat].to_f
BASE_LNG     = TARGET_AREA[:lng].to_f
BASE_DATE    = '2000-01-23'
BASE_LOGO    = TARGET_AREA[:logo]
MAX_GET_REQS = 20

# NOTE: If no data found, then YAML.unsafe_load_file() returns 'false'.
MARKERS_YAML = "#{TARGET_AREA[:name]}.yml"
FileUtils.touch MARKERS_YAML
existing_markers = YAML.unsafe_load_file(MARKERS_YAML, symbolize_names: true) ?
                   YAML.unsafe_load_file(MARKERS_YAML, symbolize_names: true) : []

class Array
  def pluck(id)
    return false if self.empty?
    self.find{|marker| marker[:id] == id}
  end
end

# Start fetching articles from allowed and targeted Minkei papers
mechanize                  = Mechanize.new
mechanize.user_agent_alias = 'Windows Chrome'
latest_article = mechanize.get(BASE_URL).search('div.main a').attribute('href').value.split('/').last
count_request  = 0
debug_mode     = false
(1..).each do |id|
  if IS_PATCH_MODE
    break if id > latest_article.to_i # Break if reached to latest article number
    next unless id == PATCHING_ID
    puts 'Patching article below ...' + PATCHING_ID.to_s
    puts '[BEFORE]'
    puts existing_markers.pluck(PATCHING_ID).to_yaml
    puts
    puts '[AFTER]'
  else
    next (puts "Skipped: #{id}") if existing_markers.pluck(id) # Skip if target marker already exists
    break(puts "Reached to Max") if (count_request += 1) > MAX_GET_REQS # Break if reached to max reqs
    break(puts "Reached to End") if id > latest_article.to_i # Break if reached to latest article number
  end

  begin
    html  = mechanize.get(BASE_URL + '/mapnews/' + id.to_s)
  rescue Mechanize::ResponseCodeError => error
    # 該当記事が削除されていたり、存在しない場合がある。
    # その場合は 404 ページが表示されるので、html には nil が代入される。
    # （以降は /404.html にリダイレクトされる処理がキャッシュされる。）

    puts "ERROR: #{error.response_code} - #{BASE_URL}/mapnews/#{id.to_s}" if debug_mode
  end

  # mapnews から取得できた位置情報を YAML ファイルに格納する
  if html && !html.search('time').text.empty?
    date    = html.search('time').text
    link    = html.search('li.send a').attribute('href').value
    title   = html.search('h1').last.text
    image   = html.at('meta[property="og:image"]').attributes['content'].value.gsub('mapnews','headline')
    lat,lng = html.search('p#mapLink a').attribute('href').value.split('?q=').last.split(',')
    puts "[#{id.to_s.rjust(4, '0')}] #{title}" unless IS_PATCH_MODE
    #puts existing_markers.pluck(id)

    #puts existing_markers.count{|m| m[:id] == PATCHING_ID} if IS_PATCH_MODE
    existing_markers.delete_if {|m| m[:id] == PATCHING_ID}  if IS_PATCH_MODE

    # 一部の記事には位置情報が無い mapnews もある。
    # 無ければデフォルトの位置情報を YAML ファイルに追記する。
    existing_markers
      .push(
        id:    id,
        src:   BASE_URL + '/mapnews/' + id.to_s,
        lat:   lat.nil? ? BASE_LAT : lat.to_f,
        lng:   lng.nil? ? BASE_LNG : lng.to_f,
        link:  link,
        date:  date,
        image: image,
        title: title,
      )
  else
    # 該当記事が削除されていた場合や、HTTP Request に失敗した場合は、
    # 当該記事にデフォルト値を入力して、スキップ。次の記事に進む。
    puts "[#{id.to_s.rjust(4, '0')}] 404 Not Found (ERROR)"

    if debug_mode
      puts 'Please investigate why no map data found in this process.'
      puts
      puts '[DEBUG INFO]' # Dump current marker data
      puts "- id:    #{id}"
      puts "  src:   #{BASE_URL + '/mapnews/' + id.to_s}"
      puts "  lat:   #{BASE_LAT}"
      puts "  lng:   #{BASE_LNG}"
      puts "  link:  #{BASE_URL}"
      puts "  date:  #{BASE_DATE}"
      puts "  image: #{BASE_LOGO}"
      puts "  title: 404_Not_Found"
      puts
    end

    existing_markers
      .push(
        id:    id,
        src:   BASE_URL + '/mapnews/' + id.to_s,
        lat:   BASE_LAT,
        lng:   BASE_LNG,
        link:  BASE_URL,
        date:  BASE_DATE,
        image: BASE_LOGO,
        title: '404_Not_Found',
      )

    #break # 失敗した時点で処理を止めたい場合はココで break する
  end

  #puts existing_markers
end

puts existing_markers.pluck(PATCHING_ID).to_yaml if IS_PATCH_MODE

YAML.dump(
     existing_markers.sort_by {|marker| marker[:id] }.reverse,
     File.open(MARKERS_YAML, 'w'))

# NOTE: Correct or debug YAML data here whenever you want.
#descending_result = YAML.unsafe_load_file(MARKERS_YAML).sort_by{ |marker| marker['id'] }.reverse
#descending_result = descending_result.each do |marker|
#  marker['title'].chomp!
#end
