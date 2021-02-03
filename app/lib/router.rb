class Router
  attr_reader :routes

  def initialize(routes)
    @routes = routes
  end

  def resolve(env)
    method = env['REQUEST_METHOD'] # 'GET'
    path = env['PATH_INFO'] # '/polygon'
    key = "#{method} #{path}" # "GET /polygon"

    if routes.key?(key)
      ctrl(routes[key]).call
    else
      Controller.new.not_found
    end
  rescue Exception => error
    puts error.message
    puts error.backtrace
    Controller.new.internal_error
  end

  # This makes a controller instance
  private def ctrl(string) #"main#polygon"
    ctrl_name, action_name = string.split('#') #["main", "polygon"]
    klass = Object.const_get "#{ctrl_name.capitalize}Controller" # MainController
    klass.new(name: ctrl_name, action: action_name.to_sym)
  end
end