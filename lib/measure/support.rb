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
        if MeasureSupport.enable?
          return Measure.new(self, name) if Measure.has_unit?(name)
        end
        return measure_support_saved_method_missing(name, *args)
      end
    }
  end
end

class << Measure
  def short_form
    begin
      MeasureSupport.enable
      return yield
    ensure
      MeasureSupport.disable
    end
  end

  def enable_short_form
    MeasureSupport.enable
  end

  def disable_short_form
    MeasureSupport.disable
  end
end

class Integer
  include MeasureSupport
end

class Float
  include MeasureSupport
end
