module Measure
  class Context
    def initialize
      @units = {}
    end

    def context_eval
      instance_eval &proc
    end

    def unit(name)
      unless include? name
        @units[name] = Object.new
      end
      @units[name]
    end

    def include?(name)
      @units.has_key? name
    end
  end
end
