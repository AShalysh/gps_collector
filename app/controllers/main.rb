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
    @content = [{result: "#{points.size} points inserted successfully"}.to_json]
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

  private

  # Defining points by interating over the request params. 
  # If object type is a 'Point' then format it as a string for sql i.e. 'point(3.0 3.0)'
  # If the object is a 'GeometryCollection' then we iterate over the points under 'geometries'
  # and format them as ['point(1.0 2.0)', 'point(1.0 1.0)'].
  # Then we combine all the postgis elements together in a single array and flatten them so it is
  # just an array of point strings formatted for postgis
  # @return [Array<String>] - an array of point strings formatted for postGis i.e. ["point(1.0 2.0)", "point( 1.0, 1.0)"]
  def points_to_sql
    points = params.map do |hash|
      case hash['type']
      when 'Point' then point_to_sql(hash)
      when 'GeometryCollection' then hash['geometries'].map { |point| point_to_sql(point) }
      end
    end
    points.flatten
  end
  
  # Formating point into (for example "2.0 2.0")
  #
  # @param [Hash] point as geojson - i.e. { "type": "Point", "coordinates": [1.0, 1.0] }
  # @return [String] return point in postgis sql format - i.e. "point(1.0 1.0)"
  def point_to_sql(point)
    "point(#{point['coordinates'][0].to_f} #{point['coordinates'][1].to_f})"
  end

  # Formating polygon for postgis
  # geometry (from params) should be formatted   
  # {
  #   "type": "Polygon",
  #   "coordinates": [
  #     [1.0, 1.0],
  #     [2.0, 2.0],
  #     [3.0, 3.0],
  #     [4.0, 4.0],
  #     [1.0, 1.0]
  #   ]
  # }
  # @return [String] return polygon in postgis sql format - i.e.  "polygon(2.0 2.0, 1.0 1.0, 2.0 -1.0)"
  def polygon_to_sql
    "polygon((#{geometry['coordinates'].map { |point| "#{point[0].to_f} #{point[1].to_f}" }.join(', ')}))"
  end
  
  # SQL for radius, uses params["radius"] in meters
  # @see https://postgis.net/docs/ST_DWithin.html - Returns true if the geometries are within a given distance
  # @see https://postgis.net/docs/ST_X.html - used to get the x and y coordinate of the point for display purposes
  # @see https://postgis.net/docs/ST_GeomFromText.html - Constructs a PostGIS ST_Geometry object for point
  # from point string (i.e. point(1.0 1.0))
  # @return [Array<Hash>] DB result array of hashes with each hash being a row from the returned results
  # i.e. [{id: 1, longitude: 1.0, latitude: 1.0}, {id: 3, longitude: 2.0, latitude: 2.0}, ...]
  def within_radius    
    DB[<<~SQL]
      SELECT
        ST_X(points.point::geometry) AS longitude,
        ST_Y(points.point::geometry) AS latitude
      FROM points
      WHERE ST_DWithin(points.point, ST_GeomFromText('#{point_to_sql(geometry)}'), #{params['radius']})
    SQL
  end

  # SQL for poligon
  # @see https://postgis.net/docs/ST_Within.html - Returns true if the geometry point is within polygon (A within B)
  # @see https://postgis.net/docs/ST_X.html - used to get the x and y coordinate of the point for display purposes
  # @see https://postgis.net/docs/ST_GeomFromText.html - Constructs a PostGIS ST_Geometry object for polygon (4326 needed 
  # to force the correct SRID)
  # @return [Array<Hash>] DB result array of hashes with each hash being a row from the returned results
  # i.e. [{id: 1, longitude: 1.0, latitude: 1.0}, {id: 3, longitude: 2.0, latitude: 2.0}, ...]
  def within_polygon
    DB[<<~SQL]
      SELECT
        ST_X(points.point::geometry) AS longitude,
        ST_Y(points.point::geometry) AS latitude
      FROM points
      WHERE ST_Within(points.point::geometry, ST_GeomFromText('#{polygon_to_sql}', 4326))
    SQL
  end

  # @param [Hash] Single row result from database - i.e. {id: 1, longitude: 1.0, latitude: 1.0}
  # @return [Hash] Result hash formatted to geojson
  def to_geojson(point)
    {
      'type': 'Point',
      'coordinates': [point[:longitude], point[:latitude]]
    }
  end
  
  # @return [Hash] the geometry object from geojson params
  def geometry
    params['geometry']
  end
end
