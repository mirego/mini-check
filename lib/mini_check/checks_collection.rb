module MiniCheck
  class ChecksCollection < Array
    def to_hash
      resp = {}
      each.map do |check|
        resp[check.name] = check.to_hash
      end

      resp
    end

    def healthy?
      !detect{|c| !c.healthy? }
    end

    def run
      each{|c| c.run }
    end
    
    def register name, &block
      self.<< Check.new(name, &block)
    end
  end
end
