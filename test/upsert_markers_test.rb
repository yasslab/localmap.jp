require 'minitest/autorun'
require 'mechanize'
require 'yaml'

# みんなの経済新聞のサイトから取得できない時の upsert_markers.rb の振る舞いを確かめる。
# ネットワークには出ず、Mechanize#get が返す応答を差し替える。
class UpsertMarkersTest < Minitest::Test
  AREA = 'fukushima'

  def test_メンテナンス中の地域は警告を出して飛ばし既存のマーカーを残す
    before = File.read("_data/#{AREA}.yml")

    # maintenance.html へ転送され、その先が 404 を返す（2026年10月22日の福島経済新聞）
    error = nil
    out, _ = capture_io do
      error = assert_raises(SystemExit) { run_script(failing_with: '/maintenance.html', status: '404') }
    end

    assert error.success?, 'メンテナンス中は失敗にせず、ほかの地域の更新を続ける'
    assert_match(/::warning::.*#{AREA}.*メンテナンス/, out)
    assert_equal before, File.read("_data/#{AREA}.yml")
  end

  def test_メンテナンス以外の取得の失敗は今までどおり落とす
    assert_raises(Mechanize::ResponseCodeError) { run_script(failing_with: '/', status: '500') }
  end

  private

  def run_script(failing_with:, status:)
    original = Mechanize.instance_method(:get)
    Mechanize.define_method(:get) do |*|
      uri = URI("https://#{AREA}.keizai.biz#{failing_with}")
      raise Mechanize::ResponseCodeError.new(Mechanize::Page.new(uri, { 'content-type' => 'text/html' }, '', status, self))
    end
    ARGV.replace([AREA])
    load File.expand_path('../upsert_markers.rb', __dir__)
  ensure
    Mechanize.define_method(:get, original)
  end
end
