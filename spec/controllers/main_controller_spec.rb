# frozen_string_literal: true

describe MainController do
  # Clear database before running tests
  before { DB[:points].delete }

  context 'post to /points' do
    describe '#points' do
      subject { post '/points', params.to_json, { 'CONTENT_TYPE' => 'application/json' } }
      before { subject }

      shared_examples 'it creates points' do |number_of_points|
        it { expect(last_response.status).to eq 201 }
        it {
          expect(JSON.parse(last_response.body)).to eq(
            { 'result' => "#{number_of_points} points inserted successfully" }
          )
        }
      end

      context 'only points as params' do
        let(:params) do
          [
            {
              'type': 'Point',
              'coordinates': [1.0, 1.0]
            },
            {
              'type': 'Point',
              'coordinates': [2.0, 2.0]
            }
          ]
        end
        it_behaves_like('it creates points', 2)
      end

      context 'only geometry collections as params' do
        let(:params) do
          [
            {
              "type": 'GeometryCollection',
              "geometries": [
                {
                  "type": 'Point',
                  "coordinates": [1.0, 1.0]
                },
                {
                  "type": 'Point',
                  "coordinates": [2.0, 2.0]
                }
              ]
            },
            {
              "type": 'GeometryCollection',
              "geometries": [
                {
                  "type": 'Point',
                  "coordinates": [2.0, -2.0]
                },
                {
                  "type": 'Point',
                  "coordinates": [1.0, -1.0]
                }
              ]
            }
          ]
        end
        it_behaves_like('it creates points', 4)
      end

      context 'mix of geometry collections and points as params' do
        let(:params) do
          [
            {
              'type': 'Point',
              'coordinates': [1.0, 1.0]
            },
            {
              "type": 'GeometryCollection',
              "geometries": [
                {
                  "type": 'Point',
                  "coordinates": [1.0, 1.0]
                },
                {
                  "type": 'Point',
                  "coordinates": [2.0, 2.0]
                }
              ]
            },
            {
              'type': 'Point',
              'coordinates': [2.0, 2.0]
            }
          ]
        end
        it_behaves_like('it creates points', 4)
      end

      context 'invalid params catch' do
        let(:params) do
          [
            {
              'type': 'WRONG',
              'coordinates': [1.0, 1.0]
            },
            {
              'type': 'Point',
              'coordinates': [2.0, 2.0]
            }
          ]
        end
        it { expect(last_response.status).to eq 422 }
        it {
          expect(JSON.parse(last_response.body)).to eq(
            { 'error' => 'Params are not correct' }
          )
        }
      end
    end
  end

  context 'get to /radius' do
    describe '#radius' do
      shared_examples 'it finds points in radius' do |result|
        it { expect(last_response.status).to eq 200 }
        it { expect(JSON.parse(last_response.body)).to eq(result) }
      end

      before do
        # Set some dummy data
        DB[:points].insert(point: 'point(1.0 1.0)')
        DB[:points].insert(point: 'point(2.0 2.0)')

        # Force params as rspec is not setting request.body with body of request
        MainController.any_instance.stub(:params).and_return(JSON.parse(params.to_json))

        # Set headers
        header = { 'CONTENT_TYPE' => 'application/json' }
        get '/radius', params.to_json, header
      end

      context 'Return points if both points within radius' do
        let(:params) do
          {
            'geometry': {
              'type': 'Point',
              'coordinates': [
                2.0,
                2.0
              ]
            },
            'radius': 157_000
          }
        end

        it_behaves_like('it finds points in radius', [
                          { 'coordinates' => [1.0, 1.0], 'type' => 'Point' },
                          { 'coordinates' => [2.0, 2.0], 'type' => 'Point' }
                        ])
      end

      context 'Return point if one point within radius' do
        let(:params) do
          {
            'geometry': {
              'type': 'Point',
              'coordinates': [
                2.0,
                2.0
              ]
            },
            'radius': 156_000
          }
        end

        it_behaves_like('it finds points in radius', [
                          { 'coordinates' => [2.0, 2.0], 'type' => 'Point' }
                        ])
      end

      context 'Get radius if no points within radius' do
        let(:params) do
          {
            'geometry': {
              'type': 'Point',
              'coordinates': [
                5.0,
                5.0
              ]
            },
            'radius': 156_000
          }
        end

        it_behaves_like('it finds points in radius', [])
      end

      context 'invalid params catch' do
        let(:params) do
          {
            'geometry': {
              'type': 'Point',
              'coordinates': [
                5.0,
                5.0
              ]
            },
            'WRONG': 156_000
          }
        end

        it { expect(last_response.status).to eq 422 }
        it {
          expect(JSON.parse(last_response.body)).to eq(
            { 'error' => 'Params are not correct' }
          )
        }
      end
    end
  end

  context 'get to /polygon' do
    describe '#polygon' do
      shared_examples 'it finds points in polygon' do |result|
        it { expect(last_response.status).to eq 200 }
        it { expect(JSON.parse(last_response.body)).to eq(result) }
      end

      before do
        # Set some dummy data
        DB[:points].insert(point: 'point(1.0 1.0)')
        DB[:points].insert(point: 'point(2.0 2.0)')

        # Force params as rspec is not setting request.body with body of request
        MainController.any_instance.stub(:params).and_return(JSON.parse(params.to_json))

        # Set headers
        header = { 'CONTENT_TYPE' => 'application/json' }
        get '/polygon', params.to_json, header
      end

      context 'Return points if both points within polygon' do
        let(:params) do
          {
            "geometry":
            {
              "type": 'Polygon',
              "coordinates": [
                [3.0, 3.0],
                [3.0, -3.0],
                [-3.0, -3.0],
                [-3.0, 3.0],
                [3.0, 3.0]
              ]
            }
          }
        end

        it_behaves_like('it finds points in polygon', [
                          { 'coordinates' => [1.0, 1.0], 'type' => 'Point' },
                          { 'coordinates' => [2.0, 2.0], 'type' => 'Point' }
                        ])
      end

      context 'Return point if one point within polygon' do
        let(:params) do
          {
            "geometry":
            {
              "type": 'Polygon',
              "coordinates": [
                [2.0, 2.0],
                [2.0, -2.0],
                [-2.0, -2.0],
                [-2.0, 2.0],
                [2.0, 2.0]
              ]
            }
          }
        end

        it_behaves_like('it finds points in polygon', [
                          { 'coordinates' => [1.0, 1.0], 'type' => 'Point' }
                        ])
      end

      context 'Return no points if no points within polygon' do
        let(:params) do
          {
            "geometry":
            {
              "type": 'Polygon',
              "coordinates": [
                [1.0, 1.0],
                [1.0, -1.0],
                [-1.0, -1.0],
                [-1.0, 1.0],
                [1.0, 1.0]
              ]
            }
          }
        end

        it_behaves_like('it finds points in polygon', [])
      end

      context 'invalid params catch' do
        let(:params) do
          {
            "geometry":
            {
              "type": 'WRONG',
              "coordinates": [
                [1.0, 1.0],
                [1.0, -1.0],
                [-1.0, -1.0],
                [-1.0, 1.0],
                [1.0, 1.0]
              ]
            }
          }
        end

        it { expect(last_response.status).to eq 422 }
        it {
          expect(JSON.parse(last_response.body)).to eq(
            { 'error' => 'Params are not correct' }
          )
        }
      end
    end
  end

  context 'get to /points' do
    let(:response) { get '/points' }
    it { expect(response.status).to eq 404 }
    it { expect(response.body).to include 'Nothing found' }
  end

  context 'return 404 when page is not found' do
    let(:response) { get '/' }
    it { expect(response.status).to eq 404 }
    it { expect(response.body).to include 'Nothing found' }
  end
end
