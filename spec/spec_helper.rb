# frozen_string_literal: true

require 'rack/test'
require 'rack'
require_relative '../app'

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Rack::Test::Methods

  # This method boots the app for the rack testings gem
  def app
    path = File.expand_path('../config.ru', File.dirname(__FILE__))
    @app ||= Rack::Builder.parse_file(path).first
  end
end
