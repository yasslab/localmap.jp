require 'minitest/autorun'
require 'json'
require 'yaml'

# 馬場経ラジオの回を、関連する記事のマーカーに表示できているかを確かめる。
class UpsertGeojsonTest < Minitest::Test
  AREA     = 'takadanobaba'
  RADIO    = "_data/#{AREA}_radio.yml"
  OUTPUTS  = ["public/#{AREA}.geojson", "public/#{AREA}.min.geojson"]

  def test_対応表の記事のマーカーに馬場経ラジオへのリンクが付く
    descriptions = generate_descriptions

    # その194「こはぜ珈琲」スペシャル → こはぜ珈琲早稲田店の講談会の記事
    assert_includes descriptions[1714], "href='https://www.youtube.com/watch?v=q4wml9QQ-8I'"
    assert_includes descriptions[1714], '「こはぜ珈琲」スペシャル'
  end

  def test_記事とラジオは見た目で区別できる
    desc = generate_descriptions[1714]

    # 記事には「記事を読む」、ラジオにはサムネイルと「ラジオで聴く」が付く
    assert_match(%r{<div class='lm-article'><span class='lm-label lm-label-article'>📰 記事を読む</span>}, desc)
    assert_match(%r{<a class='lm-radio' [^>]*href='https://www.youtube.com/watch\?v=q4wml9QQ-8I'>}, desc)
    assert_includes desc, "<img src='https://i.ytimg.com/vi/q4wml9QQ-8I/mqdefault.jpg'"
    assert_includes desc, '🎙️ ラジオで聴く'
  end

  def test_ラジオの題名は定型部分を省いて短く見せる
    descriptions = generate_descriptions

    # 雑談: 「今宵もゆるりと高田馬場から雑談」と【#馬場経ラジオ】を省く
    assert_includes descriptions[1714], "<span class='lm-radio-title'>雑談 その194　「こはぜ珈琲」スペシャル</span>"
    # 朗読: 題名は記事と同じなので、朗読であることと朗読者だけを見せる
    assert_includes descriptions[1588], "<span class='lm-radio-title'>記事の朗読（朗読：小野里 茉莉）</span>"
  end

  def test_題名の引用符はエスケープして属性や本文を壊さない
    descriptions = generate_descriptions

    # 朗読「早大近くにセレクトショップ「qqn's ROBE」…」の題名には ' が入る
    assert_includes descriptions[1588], 'qqn&#39;s ROBE'
    refute_includes descriptions[1588], "qqn's ROBE」　「地元に明るさ届けられるように」（朗読"
  end

  def test_関連する回が無いマーカーは今までどおり
    descriptions = generate_descriptions

    linked = radio.flat_map { |r| r[:articles] }
    id, desc = descriptions.find { |i, _| !linked.include?(i) }
    refute_nil id
    refute_includes desc, 'youtube.com'
    refute_includes desc, 'lm-'
  end

  def test_対応表の記事と動画のIDは実在する形をしている
    article_ids = YAML.unsafe_load_file("_data/#{AREA}.yml", symbolize_names: true).map { |a| a[:id] }

    radio.each do |r|
      assert_match(/\A[\w-]{11}\z/, r[:video])
      refute_empty r[:title].to_s
      refute_empty r[:articles]
      r[:articles].each { |i| assert_includes article_ids, i, "#{r[:video]} の記事 #{i} が無い" }
    end
    assert_equal radio.size, radio.map { |r| r[:video] }.uniq.size, '同じ動画が重複している'
  end

  private

  def radio
    YAML.unsafe_load_file(RADIO, symbolize_names: true)
  end

  # 生成物（gitignore 済み）を書き換えるので、終わったら元に戻す
  def generate_descriptions
    before = OUTPUTS.to_h { |f| [f, File.exist?(f) ? File.read(f) : nil] }
    system('ruby', 'upsert_geojson.rb', AREA, out: File::NULL, exception: true)
    features = JSON.parse(File.read(OUTPUTS.first))['features']
    features.to_h do |f|
      desc = f['properties']['description']
      [desc[%r{/headline/(\d+)/}, 1].to_i, desc]
    end
  ensure
    before&.each { |f, body| body ? File.write(f, body) : File.delete(f) }
  end
end
