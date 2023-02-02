#!/usr/bin/env ruby
require 'yaml'
require 'json'

# Plugin to add environment variables to the `site` object in Liquid templates
# https://gist.github.com/nicolashery/5756478
module Jekyll
  class EnvironmentVariables < Generator
    def generate(site)
      site.config['env'] = {}
      site.config['env']['GEOLONIA_API_KEY'] = ENV['GEOLONIA_API_KEY'] || 'YOUR-API-KEY'
      site.config['env']['JEKYLL_ENV']       = ENV['JEKYLL_ENV']       || 'development'
      # Add other environment variables to `site.config` here...
    end
  end
end

# Startup scripts when exec `jekyll [serve|build]`
Jekyll::Hooks.register :site, :after_init do |page|
  # Build pages with GeoJSON compcation
  system "bundle exec rake build_pages"
end
