module MiniCheck
  class Check
    attr_accessor :name
    attr_accessor :healthy
    attr_accessor :action
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
      begin
        self.healthy = action.call
        self.exception = nil
      rescue Exception => e
        self.healthy = false
        self.exception = e
      end
    end

    def to_hash
      {}.tap do |h|
        h[:healthy] = healthy?
        h[:error] = {message: exception.message, stack: exception.backtrace} if exception
      end
    end

    private

    def set_attributes args = {}
      args.each do |k,v|
        send("#{k}=", v)
      end
    end
  end
end
