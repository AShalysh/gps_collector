# frozen_string_literal: true

# This containes all main controller actions for app
class MainController < Controller
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
  # },
  #   "radius": {
  #     "length": 3000
  #   }
  # }
  def radius
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
    @content = [within_polygon.map { |point| to_geojson(point) }.to_json]
  end

  include ::MainBusinessLogic
end
