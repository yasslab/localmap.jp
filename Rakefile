task default: 'test'
MAPS_YAML = '_data/maps.yml'

desc 'Upsert markers by fetching map data'
task :upsert_markers do
  YAML.unsafe_load_file(MAPS_YAML, symbolize_names: true).each do |map|
    ruby "upsert_markers.rb #{map[:id]}"
  end
end

desc 'Generate geojson by loading YAML data'
task :upsert_geojson do
  YAML.unsafe_load_file(MAPS_YAML, symbolize_names: true).each do |map|
    ruby "upsert_geojson.rb #{map[:id]}"
  end
end

desc 'Compact GeoJson to be browser-friendly'
task :compact_geojson do
  YAML.unsafe_load_file(MAPS_YAML, symbolize_names: true).each do |map|
    ruby "compact_geojson.rb #{map[:id]}"
  end
end

# cf. GitHub - gjtorikian/html-proofer
# https://github.com/gjtorikian/html-proofer
require 'html-proofer'
desc 'Test static pages by HTML Proofer'
task test: [:build] do
  options = {
    checks: ['Links', 'Images', 'Scripts', 'OpenGraph', 'Favicon'],
    allow_hash_href:  true,
    disable_external: true,
    enforce_https:    true,

    #ignore_status_codes: [0, 500, 999],
  }

  HTMLProofer.check_directory('_site', options).run
end

desc 'Build static pages by Jekyll'
task build: [:clean] do
  system 'JEKYLL_END=production bundle exec jekyll build' unless ENV['SKIP_BUILD'] == 'true'
end

desc 'Clean static pages by Jekyll'
task :clean do
  system 'JEKYLL_END=production bundle exec jekyll clean' unless ENV['SKIP_BUILD'] == 'true'
end
