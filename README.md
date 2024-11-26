[![Build & Test](https://github.com/yasslab/localmap.jp/actions/workflows/test.yml/badge.svg)](https://github.com/yasslab/localmap.jp/actions/workflows/test.yml) [![Daily Update](https://github.com/yasslab/localmap.jp/actions/workflows/scheduler_daily.yml/badge.svg)](https://github.com/yasslab/localmap.jp/actions/workflows/scheduler_daily.yml)

# 📍 LocalMap.jp - 地図で振り返る、地域の出来事
[<img alt='Cover Image' src='https://github.com/yasslab/localmap.jp/blob/main/images/catch.jpg?raw=true' width='100%'>](https://localmap.jp)

[📍 LocalMap.jp](https://localmap.jp) とは、みんなの経済新聞ネットワークの各地域で配信されたニュース記事をプロットした地図です。

地図上のアイコンをクリックすると、その場所で起こった出来事の記事が読めます。

<img alt='Demo' src='https://github.com/yasslab/localmap.jp/blob/main/images/demo.gif?raw=true' width='100%'>

<!--
https://user-images.githubusercontent.com/155807/216297592-119bf7b5-6a09-4460-b026-954a7a249ce4.mp4
-->

詳細は [LocalMap.jp](https://localmap.jp/) のWebサイトからご確認いただけます。

**[→ LocalMap.jp を見る](https://localmap.jp/)**

<br>

## 📝 経済新聞の追加・確認方法

1. [`_data/maps.yml`](https://github.com/yasslab/localmap.jp/blob/main/_data/maps.yml) に以下の情報を追加する。追加場所は[全国地方公共団体コード](https://www.soumu.go.jp/denshijiti/code.html)に準拠する

  ```
  # 以下は高田馬場経済新聞のデータ例
  - area:    高田馬場     # 管轄地域名
    title:   馬場経       # タイトル名 (省略化。省略した場合は「area 名 + 経済新聞」がタイトルになる)
    pref:    東京         # 都道府県名
    twitter: baba_keizai  # SNS アカウント (省略化)
    id:   takadanobaba    # サブドメイン名。takadanobaba.keizai.biz なら takadanobaba が ID になります
    lat:  35.7120933      # ページ表示時の最初の緯度（Google Maps などでも確認が可能）
    lng:  139.7047394     # ページ表示時の最初の軽度
    zoom: 14              # ページ表示時の最初の拡大率
    logo: /images/takadanobaba.png # サムネイル画像が表示されなかった場合のデフォルト画像（記事削除の場合など）
   ```

2. 事前に掲載許諾または掲載依頼をいただいたら、以下のスクリプトを実行し、引数に上記の ID を渡す。

   ```
   # 実行例（高田馬場経済新聞の場合。１実行につき最大２０記事まで）
   $ ./upsert_markers.rb takadanobaba

   # 実行例（許諾をいただいたメディアの記事を一括で追加したい場合）
   $ while true; do ./upsert_markers.rb takadanobaba; done
   ```

3. 追加したメディアが表示されたかどうかを確認し、最初の緯度・軽度・拡大率などを調整する

   ```
   # Ruby の実行環境を用意後、以下を実行
   $ bundle install
   $ bundle exec jekyll serve
   ```

4. 問題なければコミットし、プルリクエストなどにする

   - 例: [:world_map:️ Add 高松経済新聞 to localmap.jp #22](https://github.com/yasslab/localmap.jp/pull/22)

5. マージ後、本番環境にデプロイされたら、[localmap.jp](https://localmap.jp/) で確認する

   [![高田馬場経済新聞の表示例](https://github.com/yasslab/localmap.jp/blob/main/images/cover.png?raw=true)](https://localmap.jp/)

トップページおよび個別ページが無事表示されたら、追加完了です！✅✨

<br>

## 💎 Code

Source codes written in [Ruby](https://www.ruby-lang.org/) (ending with `*.rb` and `Gemfile[.lock]`) and [index.html](https://github.com/yasslab/localmap.jp/blob/main/index.html), developed by [@YassLab](https://github.com/yasslab) team, are published under [The MIT License](https://github.com/yasslab/localmap.jp/blob/main/LICENSE.md).

Other files, like [🎨 Design](#-design) and [🗺  Map](#-map) data, follow the copyrights below.

<br>

## 🎨 Design

- [Bootstrap](https://getbootstrap.com/): Twitter, Inc. & The Bootstrap Authors ([LICENSE](https://github.com/twbs/bootstrap/blob/v4.5.3/LICENSE))
- [Chulapa](https://github.com/dieghernan/chulapa): [@dieghernan](https://github.com/dieghernan) ([LICENSE](https://github.com/dieghernan/chulapa/blob/master/LICENSE))
- [Font Awesome](https://fontawesome.com): Fonticons, Inc. ([LICENSE](https://fontawesome.com/license))

<br>

## 🗺 Map

- [GSI Japan](https://www.gsi.go.jp/)
- [Geolonia](https://geolonia.com/)
- [OpenStreetMap](https://www.openstreetmap.org/)

<br>

## 📰 Articles

Articles and eye-catch images are owned by [each information provider](https://localmap.jp/#area).

<br>

## 📍 Organized by

- 運営: [高田馬場経済新聞](https://takadanobaba.keizai.biz/)
- 開発: [@YassLab](https://github.com/yasslab) Inc.

<a href='https://takadanobaba.keizai.biz/'>
  <img alt='高田馬場経済新聞' src='https://github.com/yasslab/localmap.jp/blob/main/images/babakei.jpg?raw=true' width='100%'>
</a>
