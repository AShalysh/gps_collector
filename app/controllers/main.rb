# frozen_string_literal: true

# This containes all main controller actions for app
class MainController < Controller
  include ::MainBusinessLogic

  # Does point insertion in DB, @content is set to number of points inserted
  # Expected request params looks like:
  # [
  #   {
  #     "type": "GeometryCollection",
  #     "geometries": [
  #         {
  #            "type": "Point",
  #            "coordinates": [1.0, 2.0]
  #         },
  #         {
  #            "type": "Point",
  #            "coordinates": [1.0, 1.0]
  #         }
  #       ]
  #    },
  #   {
  #     "type": "Point",
  #     "coordinates": [3.0, 3.0]
  #   }
  # ]
  def create
    validate_points_input
    points = points_to_sql
    DB.transaction do
      points.each do |point|
        DB[:points].insert(point: point)
      end
    end
    @status = 201
    @content = [{ result: "#{points.size} points inserted successfully" }.to_json]
  end

  # Getting points within radius
  # Expected request params looks like:
  # {
  #   "geometry": {
  #     "type": "Point",
  #     "coordinates": [3.0, 3.0]
  #   },
  #   "radius": 3000
  # }
  def radius
    validate_radius_input
    @content = [within_radius.map { |point| to_geojson(point) }.to_json]
  end

  # Getting points within poligon
  # Expected request params looks like:
  #   {
  #     "geometry": {
  #       "type": "Polygon",
  #       "coordinates": [[
  #           [1.0, 1.0],
  #           [2.0, 2.0],
  #           [3.0, 3.0],
  #           [4.0, 4.0],
  #           [1.0, 1.0]
  #         ]]
  #     }
  # }
  def polygon
    validate_polygon_input
    @content = [within_polygon.map { |point| to_geojson(point) }.to_json]
  end  

  # Validates points params
  def validate_points_input
    if !params.kind_of?(Array) || (params.reject {|geom| ["Point", "GeometryCollection"].include?(geom["type"]) }.count > 0)
      raise ArgumentError.new("Params are not correct") 
    end
  end

  # Validates radius params
  def validate_radius_input
    if !params.kind_of?(Hash) || !params["geometry"] || geometry["type"] != "Point" || !params["radius"] || !geometry["coordinates"].kind_of?(Array)
      raise ArgumentError.new("Params are not correct")
    end
  end

  # Validates polygon params
  def validate_polygon_input
    if !params.kind_of?(Hash) || !params["geometry"] || geometry["type"] != "Polygon" || !geometry["coordinates"].kind_of?(Array)
      raise ArgumentError.new("Params are not correct")
    end
  end


end
