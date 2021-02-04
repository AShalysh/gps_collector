class Controller
  attr_reader :name, :action
  attr_accessor :status, :headers, :content

  # Initialize name and action

  # @param [String] name Inputs the name
  # @param [String] action Inputs the action name
  def initialize(name: nil, action: nil)
    @name = name
    @action = action
  end

  def call
    send(action) # "polygon"
    self.status = 200
    self.headers = { 'Content-Type' => 'text/html' }
    self.content = @content
    self
  end

  def not_found
    self.status = 404
    self.headers = {}
    self.content = ['Nothing found']
    self
  end

  def internal_error
    self.status = 500
    self.headers = {}
    self.content = ['Internal error']
    self
  end
end
