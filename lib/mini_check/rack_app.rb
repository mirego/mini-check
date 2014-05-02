module MiniCheck
  class RackApp
    attr_accessor :checks
    attr_accessor :path

    def initialize args = {}
      set_attributes args
    end

    def checks
      @checks ||= ChecksCollection.new
    end

    def call env
      case "#{env['REQUEST_METHOD']} #{env['PATH_INFO']}"
      when "GET #{path}"
        checks.run
        [status, headers, [body]]
      else
        host_app.call(env)
      end
    end

    def register name, &block
      checks.register name, &block
    end

    def new(app)
      copy = self.dup
      copy.host_app = app
      copy
    end

    private

    def set_attributes args = {}
      args.each do |k,v|
        send("#{k}=", v)
      end
    end

    def headers
      {'Content-Type' => 'application/json'}
    end

    def body
      checks.to_hash.to_json
    end

    def status
      checks.healthy? ? 200 : 500
    end

    protected

    attr_accessor :host_app

    def host_app
      @host_app ||= lambda{|env|  [404, {}, []]}
    end
  end
end
