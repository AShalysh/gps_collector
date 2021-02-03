describe App do
  context 'get to /polygon' do
    let(:response) { get '/polygon' }
    it { expect(response.status).to eq 200 }
    it { expect(response.body).to include 'Polygon' }
  end

  context 'get to /radius' do
    let(:response) { get '/radius' }
    it { expect(response.status).to eq 200 }
    it { expect(response.body).to include 'Radius' }
  end

  context 'post to /points' do
    let(:response) { post '/points' }
    it { expect(response.status).to eq 200 }
    it { expect(response.body).to include 'points' }
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
