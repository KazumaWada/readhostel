require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    #rails5以降、libは自動で読み込まれなくなったから。(OCR用)
    config.autoload_paths << Rails.root.join('lib')

    #Railsのではなく、指定した404errors/not_foundを返すようにする。
    config.exceptions_app = self.routes

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    #render対策hostを無効化
    config.hosts.clear
    config.middleware.delete ActionDispatch::HostAuthorization
  end
end
