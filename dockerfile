# ベースイメージとして公式のRubyイメージを使用
FROM ruby:3.2.6

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libsqlite3-dev \
        sqlite3 \
        cron \
        tesseract-ocr \
        libtesseract-dev \
        imagemagick && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Bundler と Whenever をインストール
RUN gem install bundler --no-document
RUN gem install whenever --no-document

# 作業ディレクトリを指定
WORKDIR /app

# OCRのmini~用に画像を一時保存するpathの権限を与える
RUN mkdir -p /app/tmp && chmod -R 777 /app/tmp

# この時点で、(dockerを実行する時点で)docker先コピーできるように先にローカルにgemfileを作っておく。
# そうすることで、再ビルドした時にこの過程をスキップできてビルド時間を減らせる。
COPY Gemfile Gemfile.lock ./

# プラットフォームを指定してBundlerをインストール
RUN bundle lock --add-platform x86_64-linux && \
    bundle install --jobs=4 --retry=3

# bundle installの後にcopyすることで、gemfileの変更がない限り、rebuildするときに依存関係の設定をキャッシュしているから飛ばせる。
# けど、gemfileの変更がある場合にのみ再ビルド
COPY . .

# wheneverでcronタスクを生成（config/schedule.rbが存在する前提）
RUN if [ -f config/schedule.rb ]; then whenever --update-crontab; fi

# ポート3000を公開
EXPOSE 3003

# アプリケーションの起動とcronサービスの開始
CMD ["sh", "-c", "service cron start && bin/rails db:migrate RAILS_ENV=production && rails server -b 0.0.0.0"]
