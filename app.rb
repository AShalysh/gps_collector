# frozen_string_literal: true

require 'yaml'
require 'byebug'
ROUTES = YAML.safe_load(File.read(File.join(File.dirname(__FILE__), 'app', 'routes.yml')))

db_config_file = File.join(File.dirname(__FILE__), 'app', 'database.yml')
if File.exist?(db_config_file)
  config = YAML.safe_load(File.read(db_config_file))
  DB = Sequel.connect(config)
  Sequel.extension :migration
end

Dir[File.join(File.dirname(__FILE__), 'app', 'lib', '*.rb')].sort.each { |file| require file }
Dir[File.join(File.dirname(__FILE__), 'app', '**', '*.rb')].sort.each { |file| require file }

Sequel::Migrator.run(DB, File.join(File.dirname(__FILE__), 'app', 'db', 'migrations')) if DB

# This runs our App
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
