# frozen_string_literal: true

# This containes all main controller actions for app
class MainController < Controller
  def create
    @content = ['points']
  end

  def radius
    @content = ['Radius']
  end

  def polygon
    @content = ['Polygon']
  end
end
