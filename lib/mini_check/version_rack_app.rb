require 'yaml'

module MiniCheck
  class VersionRackApp
    attr_accessor :path, :build_file

    REQUEST_METHOD = 'REQUEST_METHOD'.freeze
    PATH_INFO = 'PATH_INFO'.freeze
    APP_KEY = 'Application Name'.freeze
    JSON_HEADERS = {'Content-Type' => 'application/json'}.freeze
    PLAIN_HEADERS = {'Content-Type' => 'text/plain'}.freeze

    def initialize args = {}
      set_attributes args
    end

    def metadata
      @metadata ||= Hash.new
    end

    def call env
      case "#{env[REQUEST_METHOD]} #{env[PATH_INFO]}"
      when "GET #{path}.json"
        JsonResponse.render(output_hash)
      when "GET #{path}"
        PlainTextResponse.render(output_hash)
      else
        host_app.call(env)
      end
    end

    def new(app)
      copy = self.dup
      copy.host_app = app
      copy
    end


    private

    def name= name
      metadata[APP_KEY] = name
    end

    def set_attributes args = {}
      args.each do |k,v|
        send("#{k}=", v)
      end
    end

    def output_hash
      metadata.merge(file_hash)
    end

    def file_hash
      if (content = file_content(build_file)).instance_of?(Hash)
        content
      else
        content = raw_file_content(build_file).split("\n")
        Hash[content.map{ |pair| pair.split("=") }]
      end
    rescue => ex
      { error: ex.message }
    end

    def self.file_content(build_file)
      @file_content ||= YAML.load_file(build_file)
    end

    def self.raw_file_content(build_file)
      @raw_file_content ||= IO.read(build_file)
    end

    def file_content(build_file)
      self.class.file_content(build_file)
    end

    def raw_file_content(build_file)
      self.class.raw_file_content(build_file)
    end

    protected

    attr_accessor :host_app

    def host_app
      @host_app ||= lambda { |env|  [404, {}, []] }
    end


    class JsonResponse
      def self.render hash
        [200, JSON_HEADERS, [hash.to_json]]
      end
    end

    class PlainTextResponse
      def self.render hash
        [200, PLAIN_HEADERS, [parse(hash)]]
      end

      private

      def self.parse hash
        hash.map{ |key,value| "#{key}=#{value}" }.join("\n")
      end
    end
  end
end