# = Measure
#
# Author::    Kenta Murata
# Copyright:: Copyright (C) 2008 Kenta Murata
# License::   LGPL version 3.0

class Measure
  class UnitRedefinitionError < StandardError; end
  class InvalidUnitError < StandardError; end
  class CompatibilityError < StandardError; end

  @@units = []
  @@dimension_map = {}
  @@conversion_map = {}
  @@alias_map = {}

  class << self
    def conversion_map
      @@conversion_map
    end

    def has_unit?(unit)
      unit = resolve_alias unit
      return @@units.include? unit
    end
    alias defined? has_unit?

    def compatible?(u1, u2)
      u1 = resolve_alias u1
      raise InvalidUnitError, "unknown unit: #{u1}" unless self.defined? u1
      u2 = resolve_alias u2
      raise InvalidUnitError, "unknown unit: #{u2}" unless self.defined? u2
      return true if u1 == u2
      return true if @@conversion_map.has_key? u1 and @@conversion_map[u1].has_key? u2
      return true if @@conversion_map.has_key? u2 and @@conversion_map[u2].has_key? u1
      return false
    end

    def clear_units
      @@units.clear
      @@dimension_map.clear
      @@conversion_map.clear
      @@alias_map.clear
      return nil
    end

    def units(dimension=nil)
      return @@units.dup if dimension.nil?
      @@dimension_map.select {|k, v| v == dimension }.collect{|k, v| k }
    end

    def num_units
      return @@units.length
    end

    def define_unit(unit, dimension=1)
      if @@units.include?(unit)
        if self.dimension(unit) != dimension
          raise UnitRedefinitionError, "unit [#{unit}] is already defined"
        end
      else
        @@units << unit
        @@dimension_map[unit] = dimension
      end
    end

    def define_alias(unit, base)
      if self.defined?(unit)
        raise UnitRedefinitionError, "unit [#{unit}] is already defined"
      end
      raise InvalidUnitError, "unknown unit: #{base}" unless self.defined? base
      @@alias_map[unit] = base
    end

    def define_conversion(base, conversion)
      base = resolve_alias base
      raise InvalidUnitError, "unknown unit: #{base}" unless self.defined? base
      @@conversion_map[base] ||= {}
      conversion.each {|unit, factor|
        unit = resolve_alias unit
        raise InvalidUnitError, "unknown unit: #{unit}" unless self.defined? unit
        @@conversion_map[base][unit] = factor
      }
      return nil
    end

    def dimension(unit)
      return @@dimension_map[resolve_alias unit]
    end
    alias dim dimension

    def resolve_alias(unit)
      while @@alias_map.has_key? unit
        unit = @@alias_map[unit]
      end
      return unit
    end

    def find_multi_hop_conversion(u1, u2)
      visited = []
      queue = [[u1]]
      while route = queue.shift
        next if visited.include? route.last
        visited.push route.last
        return route if route.last == u2
        neighbors(route.last).each{|u|
          queue.push(route + [u]) unless visited.include? u }
      end
      return nil
    end

#     def encode_dimension(dim)
#       case dim
#       when Symbol
#         return dim.to_s
#       else
#         units = dim.sort {|a, b| a[1] <=> b[1] }.reverse
#         nums = []
#         units.select {|u, e| e > 0 }.each {|u, e| nums << "#{u}^#{e}" }
#         dens = []
#         units.select {|u, e| e < 0 }.each {|u, e| dens << "#{u}^#{-e}" }
#         return nums.join(' ') + ' / ' + dens.join(' ')
#       end
#     end

    private

    def neighbors(unit)
      res = []
      if @@conversion_map.has_key?(unit)
        res += @@conversion_map[unit].keys
      end
      @@conversion_map.each {|k, v| res << k if v.has_key? unit }
      return res
    end
  end # class << self

  def initialize(value, unit)
    @value, @unit = value, unit
    return nil
  end

  attr_reader :value, :unit

  def <(other)
    case other
    when Measure
      if self.unit == other.unit
        return self.value < other.value
      else
        return self < other.convert(self.value)
      end
    when Numeric
      return self.value < other
    else
      raise ArgumentError, 'unable to compare with #{other.inspect}'
    end
  end

  def >(other)
    case other
    when Measure
      if self.unit == other.unit
        return self.value > other.value
      else
        return self > other.convert(self.value)
      end
    when Numeric
      return self.value > other
    else
      raise ArgumentError, 'unable to compare with #{other.inspect}'
    end
  end

  def ==(other)
    return self.value == other.value if self.unit == other.unit
    if Measure.compatible? self.unit, other.unit
      return self == other.convert(self.unit)
    elsif Measure.compatible? other.unit, self.unit
      return self.convert(other.unit) == other
    else
      return false
    end
  end

  def +(other)
    case other
    when Measure
      if self.unit == other.unit
        return Measure(self.value + other.value, self.unit)
      elsif Measure.dim(self.unit) == Measure.dim(other.unit)
        return Measure(self.value + other.convert(self.unit).value, self.unit)
      else
        raise TypeError, "incompatible dimensions: " +
          "#{Measure.dim(self.unit)} and #{Measure.dim(other.unit)}"
      end
    when Numeric
      return Measure(self.value + other, self.unit)
    else
      check_coercable other
      a, b = other.coerce self
      return a + b
    end
  end

  def -(other)
    case other
    when Measure
      if self.unit == other.unit
        return Measure(self.value - other.value, self.unit)
      elsif Measure.dim(self.unit) == Measure.dim(other.unit)
        return Measure(self.value - other.convert(self.unit).value, self.unit)
      else
        raise TypeError, "incompatible dimensions: " +
          "#{Measure.dim(self.unit)} and #{Measure.dim(other.unit)}"
      end
    when Numeric
      return Measure(self.value - other, self.unit)
    else
      check_coerecable other
      a, b = other.coerce self
      return a - b
    end
  end

  def *(other)
    case other
    when Measure
      # TODO: dimension
      return other * self.value if self.unit == 1
      raise NotImplementedError, "this feature has not implemented yet"
#       if self.unit == other.unit
#         return Measure(self.value * other.value, self.unit)
#       elsif Measure.dim(self.unit) == Measure.dim(other.unit)
#         return Measure(self.value - other.convert(self.unit).value, self.unit)
#       else
#         return Measure(self.value * other.convert(self.unit).value, self.unit)
#       end
    when Numeric
      return Measure(self.value * other, self.unit)
    else
      check_coercable other
      a, b = other.coerce self
      return a * b
    end
  end

  def /(other)
    case other
    when Measure
      # TODO: dimension
      raise NotImplementedError, "this feature has not implemented yet"
#       if self.unit == other.unit
#         return Measure(self.value / other.value, self.unit)
#       else
#         return Measure(self.value / other.convert(self.unit).value, self.unit)
#       end
    when Numeric
      return Measure(self.value / other, self.unit)
    else
      check_coercable other
      a, b = other.coerce self
      return a / b
    end
  end

  def coerce(other)
    case other
    when Numeric
      return [Measure(other, 1), self]
    else
      raise TypeError, "#{other.class} can't convert into #{self.class}"
    end
  end

  def abs
    return Measure(self.value.abs, self.unit)
  end

  def to_s
    return "#{self.value} [#{self.unit}]"
  end

  def to_i
    return self.value.to_i
  end

  def to_f
    return self.value.to_f
  end

  def to_a
    return [self.value, self.unit]
  end

  def convert(unit)
    return self if unit == self.unit
    to_unit = Measure.resolve_alias unit
    raise InvalidUnitError, "unknown unit: #{unit}" unless Measure.defined? unit
    from_unit = Measure.resolve_alias self.unit
    if Measure.compatible? from_unit, to_unit
      # direct conversion
      if @@conversion_map.has_key? from_unit and @@conversion_map[from_unit].has_key? to_unit
        value = self.value * @@conversion_map[from_unit][to_unit]
      else
        value = self.value / @@conversion_map[to_unit][from_unit].to_f
      end
    elsif route = Measure.find_multi_hop_conversion(from_unit, to_unit)
      u1 = route.shift
      value = self.value
      while u2 = route.shift
        if @@conversion_map.has_key? u1 and @@conversion_map[u1].has_key? u2
          value *= @@conversion_map[u1][u2]
        else
          value /= @@conversion_map[u2][u1].to_f
        end
        u1 = u2
      end
    else
      raise CompatibilityError, "units not compatible: #{self.unit} and #{unit}"
    end
    # Second 
    return Measure.new(value, unit)
  end

  alias saved_method_missing method_missing
  private_methods :saved_method_missing

  def method_missing(name, *args)
    if /^as_(\w+)/.match(name.to_s)
      unit = $1.to_sym
      return convert(unit)
    end
    return saved_method_missing(name, *args)
  end

  private

  def check_coercable(other)
    unless other.respond_to? :coerce
      raise TypeError, "#{other.class} can't be coerced into #{self.class}"
    end
  end
end

def Measure(value, unit=1)
  return Measure.new(value, unit)
end
