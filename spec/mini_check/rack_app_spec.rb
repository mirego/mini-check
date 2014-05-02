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
        expect(checks).to receive(:run)
        do_request
      end

      it 'has status 200 when checks are healthy' do
        allow(checks).to receive(:healthy?).and_return(true)
        do_request
        expect(status).to eq(200)
      end

      it 'has status 500 when checks are failing' do
        allow(checks).to receive(:healthy?).and_return(false)
        do_request
        expect(status).to eq(500)
      end
    end

    describe 'rack integration' do
      describe 'mounted with cascade' do
        let(:check_app){ MiniCheck::RackApp.new path: '/health'}
        let(:host_app){ lambda{|env| [host_app_status, {}, host_app_body] } }
        let(:host_app_status){ 201 }
        let(:host_app_body){ 'Host app talking' }

        let(:app) do
          rack_app = Rack::Cascade.new([check_app, host_app])
          Rack::Builder.new do
            run rack_app
          end
        end

        it 'mini_check replies if the request matches' do
          get '/health'
          expect(last_response.status).to eq(check_app.send(:status))
          expect(last_response.body).to eq(check_app.send(:body))
        end

        it 'host_app replies if the request doesn\'t match' do
          get '/somehting_else'
          expect(last_response.status).to eq(host_app_status)
          expect(last_response.body).to eq(host_app_body)
        end
      end

      describe 'mounted as a middleware' do
        let(:check_app){ MiniCheck::RackApp.new path: '/health'}
        let(:host_app){ lambda{|env| [host_app_status, {}, host_app_body] } }
        let(:host_app_status){ 201 }
        let(:host_app_body){ 'Host app talking' }

        let(:app) do
          rack_app = Rack::Builder.new
          rack_app.use check_app
          rack_app.run host_app
          rack_app
        end

        it 'mini_check replies if the request matches' do
          get '/health'
          expect(last_response.status).to eq(check_app.send(:status))
          expect(last_response.body).to eq(check_app.send(:body))
        end

        it 'host_app replies if the request doesn\'t match' do
          get '/somehting_else'
          expect(last_response.status).to eq(host_app_status)
          expect(last_response.body).to eq(host_app_body)
        end
      end
    end
  end

  describe 'new' do
    let(:host_app){ double('host_app') }

    it 'returns a copy of itself' do
      copy = subject.new(host_app)
      expect(copy).not_to be(subject)
      expect(copy).to be_a(MiniCheck::RackApp)
    end

    it 'sets host_app as the argument on the copy, not itself' do
      copy = subject.new(host_app)
      expect(copy.send(:host_app)).to be(host_app)
      expect(subject.send(:host_app)).not_to be(host_app)
    end

    it 'sets its checks to the copy' do
      copy = subject.new(host_app)
      expect(copy.checks).to be(subject.checks)
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
