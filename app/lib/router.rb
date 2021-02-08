# frozen_string_literal: true

# Defining router
class Router
  attr_reader :routes, :request

  # Initialize routes
  #
  # @param [Hash] routes from routes.yml
  def initialize(routes)
    @routes = routes
  end

  # Method produces the key (for example - 'GET /polygon') as a combination of
  # http REQUEST_METHOD (for example - 'GET') and PATH_INFO (for example - '/polygon')
  # If the key exists in the routes then use the corresponding string value (for example 'main#polygon')
  # as a param in the method create_controller. At the end it calls method 'call' in controller.rb
  # @param [Hash] env from rack
  # @see http://rubydoc.info/github/rack/rack/master/file/SPEC for specification of env
  def resolve(env)
    @request = Rack::Request.new(env)
    method = env['REQUEST_METHOD']
    path = env['PATH_INFO']
    key = "#{method} #{path}"
    do_action(key)
  rescue StandardError => e
    puts e.message
    puts e.backtrace
    Controller.new.internal_error
  end

  private

  # Checking if the key exists in the routes
  #
  # @param [String] key "#{method} #{path}"
  # @return [String] key "#{method} #{path}" or not_found
  def do_action(key)
    if routes.key?(key)
      value = routes[key]
      create_controller(value).call
    else
      Controller.new.not_found
    end
  end

  # Method makes a controller instance. It splits controller name and action, for example '["main", "polygon"]'
  # then creates an instance of controller (for example 'MainController')
  #
  # @param [String] ctrl_action that is controller name and action split by a '#' (for example "main#polygon")
  # @return [Controller] new controller
  def create_controller(ctrl_action)
    ctrl_name, action_name = ctrl_action.split('#')
    klass = Object.const_get "#{ctrl_name.capitalize}Controller"
    klass.new(name: ctrl_name, action: action_name.to_sym, request: request)
  end
end
