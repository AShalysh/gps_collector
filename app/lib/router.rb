class Router
  attr_reader :routes

  # Initialize routes
  #
  # @param [Hash] routes from routes.yml
  def initialize(routes)
    @routes = routes
  end
  
  # Method produces the key (for example - 'GET /polygon') as a combination of
  # http REQUEST_METHOD (for example - 'GET') and PATH_INFO (for example - '/polygon')
  # If the key exists in the routes then use the corresponding string value (for example 'main#polygon') as a param in the
  # method create_controller. At the end it calls method 'call' in controller.rb
  # @param [Hash] env from rack
  # @see http://rubydoc.info/github/rack/rack/master/file/SPEC for specification of env
  def resolve(env)
    method = env['REQUEST_METHOD']
    path = env['PATH_INFO']
    key = "#{method} #{path}"

    if routes.key?(key)
      value = routes[key]
      create_controller(value).call
    else
      Controller.new.not_found
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace
    Controller.new.internal_error
  end

  # Method makes a controller instance. It splits controller name and action, for example '["main", "polygon"]'
  # then creates an instance of controller (for example 'MainController')
  #
  # @param [String] ctrl_action that is controller name and action split by a '#' (for example "main#polygon")
  # @return [Controller] new controller
  private def create_controller(ctrl_action)
    ctrl_name, action_name = ctrl_action.split('#')
    klass = Object.const_get "#{ctrl_name.capitalize}Controller"
    klass.new(name: ctrl_name, action: action_name.to_sym)
  end
end
