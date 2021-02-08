# GPS COLLECTOR APP

This app does the following:

1) `POST` - Accepts GeoJSON point(s) to be inserted into a database table
   params: Array of GeoJSON Point objects or Geometry collection

Request example:
```
POST /points HTTP/1.1
Host: localhost:9292
Content-Type: application/json
Content-Length: 305

[
  {
    "type": "Point",
    "coordinates": [1.0, 1.0]
  },
  {
    "type": "GeometryCollection",
    "geometries": [
        {
           "type": "Point",
           "coordinates": [1.0, 1.0]
        },
        {
           "type": "Point",
           "coordinates": [2.0, 2.0]
        }
      ]
   }
]
```

Response:
```
{
    "result": "3 points inserted successfully"
}
```



2) `GET` - Responds w/GeoJSON point(s) within a radius around a point
   params: GeoJSON Point and integer radius in feet/meters

Request example:
```
GET /radius HTTP/1.1
Host: localhost:9292
Content-Type: application/json
Content-Length: 142

{
  "geometry": {
      "type": "Point",
      "coordinates": [
          1.0,
          1.0
      ]
  },
  "radius": 157000
}
```

Response:
```
[
  {
      "type": "Point",
      "coordinates": [
          1.0,
          1.0
      ]
  },
  {
      "type": "Point",
      "coordinates": [
          1.0,
          1.0
      ]
  },
  {
      "type": "Point",
      "coordinates": [
          2.0,
          2.0
      ]
  }
]
```



3) `GET` - Responds w/GeoJSON point(s) within a geographical polygon
   params: GeoJSON Polygon with no holes

Request example:
```
GET /polygon HTTP/1.1
Host: localhost:9292
Content-Type: application/json
Content-Length: 168

{
  "geometry":
  {
    "type": "Polygon",
    "coordinates": [
      [2.0, 2.0],
      [2.0, -2.0],
      [-2.0, -2.0],
      [-2.0, 2.0],
      [2.0, 2.0]
    ]
  }
}
```

Response:
```
[
  {
      "type": "Point",
      "coordinates": [
          1.0,
          1.0
      ]
  },
  {
      "type": "Point",
      "coordinates": [
          1.0,
          1.0
      ]
  }
]
```

## Getting Started

Download `docker-compose` along wtih `docker`. If on mac, use `brew` with --cask option to make sure GUI of docker is installed with docker otherwise docker won't work.

Run `docker-compose up -d db` to download docker image and run it.

Verify that docker is running by excuting `docker ps`

Next, run `bundle install` and then `bundle exec rackup` to start rack server. It will automatically run migrations so that a `points` table is created for you. If you need to drop the table, run `rake db:drop`.


## Running tests

This app uses rspec, simply run `rspec` to verify that tests are passing

## Linting

Run `rubocop` to verify that code "linted".

## Documentation

Run `yard doc` to update any documentation changes, all docs contained with `doc` folder

## Notes

There is no standardised way to do a GET request with a body ([see](https://stackoverflow.com/questions/62376667/send-json-body-with-http-get-request)), so I have defined how my app will interpret a GET request with a body.