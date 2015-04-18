ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/test_unit'
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

module ActiveSupport
  class TestCase
    include Devise::TestHelpers

    teardown do
      DatabaseCleaner.clean
    end
  end
end
