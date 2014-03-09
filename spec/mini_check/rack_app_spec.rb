require_relative '../helper'
require 'rack/test'

describe MiniCheck::RackApp do
  include Rack::Test::Methods

  subject{ MiniCheck::RackApp.new checks: checks, path: '/health'}
  let(:app){ subject }
  let(:checks_hash){ {'my_check' => {'health' => true}} }
  let(:checks){ double(:healthy? => true, :to_hash => checks_hash, :<< => true, :run => true) }

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
      it 'returns status 404' do
        get '/blahblah'
        expect(status).to eq(404)
      end
    end

    context 'unknown verb' do
      it 'returns status 404' do
        post '/health'
        expect(status).to eq(404)
      end
    end

    context 'GET /health' do
      def do_request
        get '/health'
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
        expect(JSON.parse(body)).to eq(checks_hash)
      end

      it 'calls run on the checks' do
        expect(checks).to receive(:run).and_return(true)
        do_request
      end

      it 'returns each check' do
        expect(checks).to receive(:healthy?).and_return(true)
        do_request
      end

      it 'has status 500 when one check is failing' do
        expect(checks).to receive(:healthy?).and_return(true)
        do_request
      end
    end
  end

  describe 'register' do
    it 'forwards to checks' do
      name = 'asd'
      block = proc{}
      expect(checks).to receive(:register).with(name, &block)
      subject.register(name, &block)
    end
  end

  ## MOCKS ##
  
  describe 'checks' do
    subject{ checks }
    it_behaves_like 'checks collection'
  end
end
