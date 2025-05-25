source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.6"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '8.0.0'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem 'sqlite3', '>= 2.1'


# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.4'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails", "~> 1.1"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
#passwordをhash化するためのgem
gem "bcrypt", "~> 3.1.7"
#↑の依存gem
gem 'stringio', '3.0.4'

#外部APIと通信するためのツール。HTTPクライアントライブラリ。(mailgunで使用)
gem "rest-client"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

#.com/{@user.name}⭐️
gem 'friendly_id', '~> 5.5.0'

#userの登録画面にカレンダーを実装する。
gem 'simple_calendar'

gem "ruby-openai"

#.envを読み込むため
gem 'dotenv-rails', groups: [:development]

# x card
gem 'meta-tags'

#写真から文字認識(OCR optical character recognition)
gem "rtesseract"

# OCRの処理前に画像の精度を上げる
gem "mini_magick"

#action_textの画像処理(https://railsguides.jp/v7.0/active_storage_overview.html#%E8%A6%81%E4%BB%B6)
gem "image_processing", ">= 1.2"


#gem 'webpacker'これは使わずに、railsのimport mapsを使う。(node.jsのimportみたいなやつ。デプロイに手間がかからないから。)

#自分でユーザー登録を理解するために手動で実装していく。
#gem 'devise'

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"

end


