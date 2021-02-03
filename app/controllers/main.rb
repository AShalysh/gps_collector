class MainController < Controller
  def create
    @content = ["points"]
  end

  def show
    @content = ["show"]
  end  

  def radius
    @content = ["Radius"]
  end
  
  def polygon
    @content = ["Polygon"]
  end
end