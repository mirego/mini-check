require 'benchmark'

module MiniCheck
  class Check
    attr_accessor :name
    attr_accessor :healthy
    attr_accessor :action
    attr_accessor :time
    attr_accessor :exception

    def initialize args = {}, &block
      args = {name: args} if !args.is_a?(Hash)
      args[:action] = block if block_given?

      set_attributes args
    end

    def healthy?
      !!healthy
    end

    def run
      self.time = Benchmark.measure do
        begin
          do_run
          self.exception = nil
        rescue Exception => e
          self.healthy = false
          self.exception = e
        end
      end.real
    end

    def to_hash
      {}.tap do |h|
        h[:healthy] = healthy?
        h[:time] = time
        h[:error] = error_hash if exception
      end
    end

    private

    def do_run
      self.healthy = action.call
    end

    def error_hash
      {
        message: exception.message,
        stack: exception.backtrace
      }
    end

    def set_attributes args = {}
      args.each do |k,v|
        send("#{k}=", v)
      end
    end
  end
end
