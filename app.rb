# frozen_string_literal: true

require 'yaml'
ROUTES = YAML.load(File.read(File.join(File.dirname(__FILE__), 'app', 'routes.yml')))
Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each { |file| require file }
Dir[File.join(File.dirname(__FILE__), 'app', '**', '*.rb')].each { |file| require file }

class App
  attr_reader :router

  # The method is used to initialize router with routes
  def initialize
    @router = Router.new(ROUTES)
  end

  # The method takes env to get to the right controller via router
  #
  # @param [Hash] env from rack
  # @see http://rubydoc.info/github/rack/rack/master/file/SPEC for specification of env
  def call(env)
    result = router.resolve(env) # MainController (status headers and content set to something)
    [result.status, result.headers, result.content]
  end
end
