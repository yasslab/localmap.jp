#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rss'
require 'yaml'
require 'mechanize'

BASE_URL = 'https://takadanobaba.keizai.biz/mapnews/'
agent = Mechanize.new

1.times do |n|
  result  = agent.get(BASE_URL + (900 + n).to_s)
  binding.irb
end

