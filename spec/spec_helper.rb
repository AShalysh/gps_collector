# frozen_string_literal: true

require 'rack/test'
require 'rack'
require 'sequel'
require_relative '../app'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.include Rack::Test::Methods
  config.around(:each) do |example|
    DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end

  # This method boots the app for the rack testings gem
  def app
    path = File.expand_path('../config.ru', File.dirname(__FILE__))
    @app ||= Rack::Builder.parse_file(path).first
  end
end
