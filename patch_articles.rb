#!/usr/bin/env ruby

# Load and patch articles listed in patch_articles.txt file.
TARGET_URLS = IO.readlines('./patch_articles.txt')
TARGET_URLS.each do |url|
  next unless url.start_with?('http')

  # Sample URL: https://takadanobaba.keizai.biz/headline/944/
  # Sample URL: https://takadanobaba.keizai.biz/mapnews/944/
  elements = url.split('/').delete_if{|s| s.empty? or s.nil? or s == "\n"}
  # => ["https:", "takadanobaba.keizai.biz", "headline", "944"]
  #        0                   1                 2         3
  target_article_id   = elements[-1]
  target_article_area = elements[ 1].split('.').first
  #puts target_article_id

  puts "$ ruby upsert_markers.rb #{target_article_area} #{target_article_id}"
  system "ruby upsert_markers.rb #{target_article_area} #{target_article_id}"
end

