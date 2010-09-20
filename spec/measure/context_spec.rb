require_relative File.join('..', 'spec_helper')
require 'measure'

describe Measure::Context do
  before :each do
    @ctx = Measure::Context.new
  end

  it 'should create a new subclass of Measure::Unit by receiving def_unit message' do
    @ctx.def_unit :unit, :dim
    @ctx[:unit].should be_a_kind_of Measure::Unit
  end

  it 'should define a new unit u in a dimension d' +
    ' by receiving def_unit message with arguments (:u, :d)' do
    @ctx.def_unit :u, :d
    @ctx.should have_unit :u
    @ctx[:u].dimension.should == :d
  end

  it 'should define new units u11, u12, ..., u21, u22, ... in each dimension d1, d2, ...' +
    ' by receiving def_unit message with an argument' +
    ' { :d1 => [:u11, :u12, ...], :d2 => [:u21, :u22, ...] }' do
    @ctx.def_unit :d1 => [:u11, :u12, :u13], :d2 => [:u21, :u22, :u23]
    [1, 2].each {|d|
      dn = "d#{d}".intern
      [1, 2, 3].each {|u|
        un = "u#{d}#{u}".intern
        @ctx.should have_unit un
        @ctx[un].dimension.should == dn }}
  end

  it 'should define a conversion scheme' +
    ', which convert a unit a to b by scaling by factor 20' +
    ', by receiving def_conversion message with arguments' +
    ' (:a, {:b => 20})' do
    a = @ctx.def_unit :a, :dim
    b = @ctx.def_unit :b, :dim
    lambda { @ctx.def_conversion :a, { :b => 20 } }.should_not raise_error
    a.should be_compatible_with b
  end
end
