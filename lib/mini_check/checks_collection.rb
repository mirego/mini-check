module MiniCheck
  class ChecksCollection < Array
    def to_hash
      Hash[map { |check| [check.name, check.to_hash] }]
    end

    def healthy?
      all?(&:healthy?)
    end

    def run
      each{|c| c.run }
    end

    def register name, &block
      self.<< Check.new(name, &block)
    end
  end
end
