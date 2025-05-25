# # Puma can serve each request in a thread from an internal thread pool.
# # The `threads` method setting takes two numbers: a minimum and maximum.
# # Any libraries that use thread pools should be configured to match
# # the maximum value specified for Puma. Default is set to 5 threads for minimum
# # and maximum; this matches the default thread size of Active Record.
# #
# max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
# min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
# threads min_threads_count, max_threads_count

# # Specifies the `worker_timeout` threshold that Puma will use to wait before
# # terminating a worker in development environments.
# #
# worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# # Specifies the `port` that Puma will listen on to receive requests; default is 3000.
# #
# #port ENV.fetch("PORT") { 3000 }
# port ENV.fetch("PORT") { 4000 }#render(https://render.com/docs/web-services?_gl=1*1ov27j7*_gcl_au*NTY1Mjk5NTc0LjE3MzI3OTI0Njk.*_ga*MTkyMTUxOTczOS4xNzMyNzkyNDY5*_ga_QK9L9QJC5N*MTczMzA2MDg2MC4xMC4wLjE3MzMwNjA4OTYuMjQuMC4w#port-binding)


# # Specifies the `environment` that Puma will run in.
# #
# environment ENV.fetch("RAILS_ENV") { "development" }

# # Specifies the `pidfile` that Puma will use.
# pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# # Specifies the number of `workers` to boot in clustered mode.
# # Workers are forked web server processes. If using threads and workers together
# # the concurrency of the application would be max `threads` * `workers`.
# # Workers do not work on JRuby or Windows (both of which do not support
# # processes).
# #
# # workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# # Use the `preload_app!` method when specifying a `workers` number.
# # This directive tells Puma to first boot the application and load code
# # before forking the application. This takes advantage of Copy On Write
# # process behavior so workers use less memory.
# #
# # preload_app!

# # Allow puma to be restarted by `bin/rails restart` command.
# plugin :tmp_restart


# ### heroku setting ###
# workers Integer(ENV['WEB_CONCURRENCY'] || 2)
# threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
# threads threads_count, threads_count

# preload_app!

# # Support IPv6 by binding to host `::` instead of `0.0.0.0`
# port(ENV['PORT'] || 3000, "::")
# rackup      DefaultRackup if defined?(DefaultRackup)
# environment ENV['RACK_ENV'] || 'development'

# on_worker_boot do
#   # Worker-specific setup for Rails 4.1 to 5.2, after 5.2 it's not needed
#   # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
#   ActiveRecord::Base.establish_connection
# end

# config/puma.rb

# デフォルトポートは10000だが、RenderのPORT環境変数に従う
port ENV.fetch("PORT") { 3001 }
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3001)}" # 0.0.0.0で外部からのアクセスを許可
# スレッド数の設定 (適宜調整)
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
threads threads_count, threads_count

# 環境設定
environment ENV.fetch("RAILS_ENV") { "development" }

# ワーカー数の設定 (HerokuやRenderの無料プランでは1に設定)
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# ワーカープロセスのプリロード (必要に応じて)
preload_app!

on_worker_boot do
  # 必要に応じてデータベース接続を再確立
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# PIDファイルの設定 (任意)
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Bindアドレスを指定 (RenderはIPv6もサポート)
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3001)}"
