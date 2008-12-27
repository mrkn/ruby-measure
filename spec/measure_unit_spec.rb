require File.join(File.dirname(__FILE__), 'spec_helper')
require 'measure'

describe Measure::Unit do
  before :each do
    @ctx = Measure::Context.new
  end

  it 'should define a new conversion scheme' +
    'which convert to b by scaling by factor 20, c by a proc, and so on,' +
    ', by receiving def_conversion message with a hash argument' +
    ' {:b => 20, :c => lambda {|a| ...}, ... }' do
    a = @ctx.def_unit :a, :dim
    b = @ctx.def_unit :b, :dim
    c = @ctx.def_unit :c, :dim
    a.def_conversion :b => 20, :c => lambda {|a| a + 2}
  end

  it 'commutative compatible with an unit' +
    ' when the conversion to the unit by a factor' do
    a = @ctx.def_unit :a, :dim
    b = @ctx.def_unit :b, :dim
    a.def_coversion :b => 20
    a.should be_compatible_with b
    b.should be_compatible_with a
  end

  it 'noncommutative compatible with an unit' +
    ' when the conversion to the unit by a proc' do
    a = @ctx.def_unit :a, :dim
    c = @ctx.def_unit :c, :dim
    a.def_coversion :c => lambda{|a| a + 1}
    a.should be_compatible_with c
    c.should_not be_compatible_with a
  end
end
