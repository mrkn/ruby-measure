# Author::    Kenta Murata
# Copyright:: Copyright (C) 2008 Kenta Murata
# License::   LGPL version 3.0

module MeasureSupport
  def self.enable?
    Thread.current[:measure_support_enabled]
  end

  def self.enable
    Thread.current[:measure_support_enabled] = true
  end

  def self.disable
    Thread.current[:measure_support_enabled] = false
  end

  def self.included(mod)
    mod.module_eval %Q{
      alias measure_support_saved_method_missing method_missing
      private_methods :measure_support_saved_method_missing

      def method_missing(name, *args)
        # STDERR.puts "support(\#\{name\}): \#\{caller[0,4].inspect\}"
        if MeasureSupport.enable?
          return Measure.new(self, name) if Measure.has_unit?(name)
        end
        return measure_support_saved_method_missing(name, *args)
      end
    }
  end
end

class << Measure
  def with_short_form
    begin
      MeasureSupport.enable
      # STDERR.puts "Measure.form: #{caller[0,2].inspect}"
      return yield
    ensure
      MeasureSupport.disable
    end
  end

  alias form with_short_form
end

class Integer
  include MeasureSupport
end

class Float
  include MeasureSupport
end
