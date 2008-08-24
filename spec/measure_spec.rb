require File.join(File.dirname(__FILE__), 'spec_helper')
require 'measure'

describe Measure, 'with five pre-defined units in order to unit management' do
  before :each do
    # Pre-define the following conversion scheme
    #
    #      2     5      10
    #  a <--- b ---> c <--- d
    #         |
    #         `----> e
    #           10
    #
    Measure.define_unit :a, :test
    Measure.define_unit :b, :test
    Measure.define_unit :c, :test
    Measure.define_unit :d, :test
    Measure.define_unit :e, :test
    Measure.define_conversion :b, :a => 2
    Measure.define_conversion :b, :c => 5
    Measure.define_conversion :b, :e => 10
    Measure.define_conversion :d, :c => 10
  end

  it 'has five units' do
    Measure.num_units.should == 5
  end

  it 'has defined units and has not undefined units' do
    Measure.should have_unit :a
    Measure.should have_unit :b
    Measure.should have_unit :c
    Measure.should have_unit :d
    Measure.should have_unit :e
    Measure.should_not have_unit :f
    Measure.should_not have_unit :g
    Measure.should_not have_unit :h
  end

  it 'can define an unit which has not been defined yet' do
    lambda { Measure.define_unit :f, :test }.
      should_not raise_error Exception
  end

  it 'can undefine a unit which has been already defined' do
    Measure.define_unit :f, :test
    Measure.should have_unit :f
    lambda { Measure.undefine_unit :f }.
      should_not raise_error Exception
    Measure.should_not have_unit :f
  end

  it 'raises UnitRedefinitionError' +
    ' when an unit is about to be redefined as a different dimension' do
    lambda { Measure.define_unit :a, :other }.
      should raise_error Measure::UnitRedefinitionError
  end

  it 'does not raise UnitRedefinitionError' +
    ' when an unit is about to be redefined as a same dimension' do
    lambda { Measure.define_unit :a, :test }.
      should_not raise_error Measure::UnitRedefinitionError
  end

  it 'can define and undefine aliases' do
    lambda { Measure.define_alias :alias_a, :a }.
      should_not raise_error Exception
    Measure.should have_unit :alias_a
    lambda { Measure.undefine_unit :alias_a }.
      should_not raise_error Exception
    Measure.should_not have_unit :alias_a
  end

  it 'raises UnitRedefinitionError when the unit is redefined as an alias' do
    lambda { Measure.define_alias :b, :a }.
      should raise_error Measure::UnitRedefinitionError
  end

  it 'can define a scheme of conversion from an alias' do
    Measure.define_alias :alias_a, :a
    lambda { Measure.define_conversion :alias_a, :b => 10 }.
      should_not raise_error Exception
    Measure.should be_direct_compatible :alias_a, :b
  end

  it 'can convert between two connected units' +
    ' through multiple direct conversions' do
    Measure.find_conversion_route(:a, :d).should_not be_nil
    Measure.find_conversion_route(:d, :e).should_not be_nil
  end

  it 'can define conversion by a Proc' do
    Measure.define_unit :f, :test
    lambda { Measure.define_conversion :f, :a => lambda {|x| x + 2 } }.
      should_not raise_error Exception
  end

  it 'can not convert commutatively by a Proc ' do
    Measure.define_unit :f, :test
    lambda { Measure.define_conversion :f, :a => lambda {|x| x + 2 } }.
      should_not raise_error Exception
    Measure.should be_direct_compatible :f, :a
    Measure.should_not be_direct_compatible :a, :f
  end

  it 'can not find conversion route include inverse of a Proc ' do
    Measure.define_unit :f, :test
    lambda { Measure.define_conversion :f, :a => lambda {|x| x + 2 } }.
      should_not raise_error Exception
    #
    #            2      5     10
    # f ===> a <--- b ---> c <--- d
    #               |
    #               `----> e
    #                 10
    #
    #  ===> : incommutative conversion
    Measure.should be_direct_compatible :f, :a
    Measure.should_not be_direct_compatible :a, :f
    Measure.find_conversion_route(:f, :d).should_not be_nil
    Measure.find_conversion_route(:d, :f).should be_nil
  end

  after :each do
    Measure.clear_units
  end
end

describe Measure, 'with no pre-defined units' do
  before :each do
    Measure.clear_units
  end

  it 'has no units when nothing is defined' do
    Measure.num_units.should be_equal 0
    Measure.units.should be_empty
  end

  it 'returns length units when call units(:length)' do
    length_units = [:meter, :feet, :inch]
    length_units.each {|u| Measure.define_unit u, :length }
    Measure.define_unit :kilogram, :weight
    Measure.define_unit :second, :time
    set_equal?(Measure.units(:length), length_units).should be_true
  end

  it 'raises Measure::InvalidUnitError when conversion is defined with undefined unit' do
    Measure.define_unit :meter, :length
    lambda { Measure.define_conversion :inch, :meter => 1/0.254 }.
      should raise_error(Measure::InvalidUnitError)
    lambda { Measure.define_conversion :meter, :inch => 1/0.254 }.
      should raise_error(Measure::InvalidUnitError)
  end

  it 'has commutative compatibility' do
    Measure.define_unit :meter, :length
    Measure.define_unit :inch, :length
    Measure.define_conversion :meter, :inch => 0.254
    Measure.should be_direct_compatible :meter, :inch
    Measure.should be_direct_compatible :inch, :meter
  end

  it 'can convert meter to centimeter after define_conversion(:meter, :centimeter => 100)' do
    Measure.define_unit :meter, :length
    Measure.define_unit :centimeter, :length
    Measure.define_conversion :meter, :centimeter => 100
    (Measure(1, :meter).as_centimeter).should == Measure(100, :centimeter)
    (Measure(1, :centimeter).as_meter).should == Measure(0.01, :meter)
  end

  it 'can convert to string' do
    Measure.define_unit :meter, :length
    Measure(1, :meter).to_s.should == '1 [meter]'
  end

  it 'can perform multi-hop conversion' do
    Measure.define_unit :millimeter, :length
    Measure.define_unit :inch, :length
    Measure.define_unit :feet, :length
    Measure.define_conversion :inch, :millimeter => 25.4
    Measure.define_conversion :feet, :inch => 12.0
    Measure(1, :feet).as_millimeter.should be_close(Measure(12.0 * 25.4, :millimeter), 1e-9)
  end

  it 'can convert by a Proc' do
    Measure.define_unit :deg_c, :temperature
    Measure.define_unit :deg_f, :temperature
    Measure.define_conversion :deg_f, :deg_c => lambda {|x| 5.0*(x - 32)/9.0 }
    Measure.define_conversion :deg_c, :deg_f => lambda {|x| 9.0*x/5.0 + 32 }
    Measure.should be_direct_compatible :deg_f, :deg_c
    Measure.should be_direct_compatible :deg_c, :deg_f
    lambda { Measure(40, :deg_c).as_deg_f }.should_not raise_error Exception
  end

  it 'coerce a Number to a Measure with unit 1' do
    Measure.define_unit :a, :test
    Measure(1, :a).coerce(10)[0].unit.should == 1
  end

  it 'can multiply any units by unit 1' do
    Measure.define_unit :a, :test
    lambda { Measure(1, :a) * Measure(1, 1) }.
      should_not raise_error Exception
    lambda { Measure(1, 1) * Measure(1, :a) }.
      should_not raise_error Exception
  end

  after :each do
  end
end

private

def set_equal?(a1, a2)
  (a1 - a2).empty?
end
