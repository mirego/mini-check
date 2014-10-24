require_relative '../helper'
require 'rack/test'

describe MiniCheck::VersionRackApp do
  include Rack::Test::Methods

  subject{ MiniCheck::VersionRackApp.new path: '/version', build_file: './spec/support/build.yml', name: "Paquito"}
  let(:version_hash) { {"Application Name" => "Paquito"} }
  let(:version_text) { "Application Name=Paquito" }
  let(:app){ subject }

  def status
    last_response.status
  end

  def headers
    last_response.headers
  end

  def body
    last_response.body
  end

  def body_json
    JSON.parse(body)
  end

  describe :call do
    it 'returns status, headers, body' do
      get '/'
      expect(status).to be_a(Fixnum)
      expect(headers).to be_a(Hash)
      expect(body).to be_a(String)
    end

    context 'unknown path' do
      it 'returns status 404 when no host app is given' do
        get '/blahblah'
        expect(status).to eq(404)
      end

      it 'delegates to the host app if given' do
        app.send(:host_app=, lambda{|env| [999, {}, []] })
        get '/blahblah'
        expect(status).to eq(999)
      end
    end

    context 'unknown verb' do
      it 'returns status 404' do
        post '/version'
        expect(status).to eq(404)
      end
    end

    context 'GET /version.json' do
      def do_request
        get '/version.json'
      end

      it 'returns status 200' do
        do_request
        expect(status).to eq(200)
      end

      it 'returns content type json' do
        do_request
        expect(headers['Content-Type']).to eq('application/json')
      end

      it 'returns JSON body' do
        do_request
        expect(JSON.parse(body)).to eq(version_hash)
      end
    end
    
    context 'GET /version' do
      def do_request
        get '/version'
      end

      it 'returns status 200' do
        do_request
        expect(status).to eq(200)
      end

      it 'returns content type plain text' do
        do_request
        expect(headers['Content-Type']).to eq('text/plain')
      end

      it 'returns text body' do
        do_request
        expect(body).to eq(version_text)
      end
    end
  end
end
