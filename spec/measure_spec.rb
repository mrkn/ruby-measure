require File.join(File.dirname(__FILE__), 'spec_helper')
require 'measure'

describe Measure do
  before :each do
  end

  it 'has no units when nothing is defined' do
    Measure.num_units.should be_equal 0
    Measure.units.should be_empty
  end

  it 'has the [meter] after this is defined' do
    Measure.define_unit :meter, :length
    Measure.should have_unit :meter
    Measure.should be_defined :meter
  end

  it 'returns the number of defined units when call Measure.num_units' do
    Measure.define_unit :meter, :length
    Measure.define_unit :inch, :length
    Measure.num_units.should == 2
  end

  it 'raises Measure::UnitRedefinitionError ' +
    'when the [meter] is defined twice with different dimensions' do
    Measure.define_unit :meter, :length
    lambda { Measure.define_unit :meter, :length }.
      should_not raise_error(Measure::UnitRedefinitionError)
    lambda { Measure.define_unit :meter, :weight }.
      should raise_error(Measure::UnitRedefinitionError)
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
    Measure.compatible?(:meter, :inch).should be_true
    Measure.compatible?(:inch, :meter).should be_true
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

  it 'can define aliases' do
    Measure.define_unit :meter, :length
    Measure.define_alias :m, :meter
    Measure.should be_defined :m
    Measure.dimension(:m).should == :length

    Measure.define_unit :centimeter, :length
    lambda { Measure.define_alias :centimeter, :meter }.
      should raise_error(Measure::UnitRedefinitionError)

    Measure.define_conversion :meter, :centimeter => 100
    lambda { Measure(1, :m).as_centimeter }.
      should_not raise_error(StandardError)
  end

  it 'can perform multi-hop conversion' do
    Measure.define_unit :millimeter, :length
    Measure.define_unit :inch, :length
    Measure.define_unit :feet, :length
    Measure.define_conversion :inch, :millimeter => 25.4
    Measure.define_conversion :feet, :inch => 12.0
    Measure(1, :feet).as_millimeter.should be_close(Measure(12.0 * 25.4, :millimeter), 1e-9)
  end

  after :each do
    Measure.clear_units
  end
end

private

def set_equal?(a1, a2)
  (a1 - a2).empty?
end
