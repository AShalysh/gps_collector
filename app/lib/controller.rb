# frozen_string_literal: true

# Defining base Controller
class Controller
  attr_reader :name, :action
  attr_accessor :status, :headers, :content

  # Initialize name and action
  #
  # @param [String] name Inputs the name
  # @param [String] action Inputs the action name
  def initialize(name: nil, action: nil)
    @name = name
    @action = action
  end

  # This runs the specified in action method in MainController (for example, 'polygon'),
  # sets new status, headers and content to itself
  #
  # @return [Object] self
  def call
    send(action)
    self.status = 200
    self.headers = { 'Content-Type' => 'text/html' }
    self.content = @content
    self
  end

  # This runs if key in Controller was not found,
  # sets new status, headers and content to itself
  #
  # @return [Object] self
  def not_found
    self.status = 404
    self.headers = {}
    self.content = ['Nothing found']
    self
  end

  # This runs if there is an internal error in Controller,
  # sets new status, headers and content to itself
  #
  # @return [Object] self
  def internal_error
    self.status = 500
    self.headers = {}
    self.content = ['Internal error']
    self
  end
end
