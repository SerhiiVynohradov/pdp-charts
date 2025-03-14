require 'support/simplecov'

require 'capybara/rspec'
require 'rspec/retry'
require 'capybara-screenshot/rspec'
require 'capybara/email/rspec'
require 'factory_bot'
require 'shoulda-matchers'

CHROME_DOWNLOAD_DIR = "#{Dir.pwd}/tmp/chrome_downloads_#{Random.rand(99999)}".freeze

RSpec.configure do |config|
  config.verbose_retry = true
  config.display_try_failure_messages = true
  config.example_status_persistence_file_path = "tmp/rspec_examples#{ENV['CI_NODE_INDEX'].to_i}.txt"

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.bisect_runner = :shell

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # helpers for view components
  config.include Capybara::RSpecMatchers, type: :component
end
