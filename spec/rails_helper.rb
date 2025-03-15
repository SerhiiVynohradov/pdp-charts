require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'devise'
require 'rspec/wait'
require 'factory_bot'
require 'shoulda-matchers'

Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Rails.root.glob('spec/models/shared_examples/**/*.rb').each {|f| require f}
Rails.root.glob('spec/requests/shared_examples/**/*.rb').each {|f| require f}

RSpec.configure do |config|
  Capybara.app_host = 'http://localhost'
  Capybara.always_include_port = true
  # default timeout
  Net::HTTP.default_read_timeout = 10
  Capybara.default_max_wait_time = 10

  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Rails.application.routes.url_helpers
  config.include FactoryBot::Syntax::Methods
  config.include ApplicationHelper

  config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]

  config.before(:each, type: :system) do
		driven_by(:rack_test)
	end

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.around(:each) do |example|
    attempts = 3

    begin
      example.run
    rescue Net::ReadTimeout => e
      attempts -= 1
      if attempts > 0
        puts "Поймали Net::ReadTimeout, пробуем ещё раз (осталось попыток: #{attempts})"
        retry
      else
        raise e
      end
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.after(:each, type: :feature) do
    FileUtils.rm_rf(Dir.glob("#{CHROME_DOWNLOAD_DIR}/*"))
  end
end

RSpec.configure do |config|
  config.include Warden::Test::Helpers
end
