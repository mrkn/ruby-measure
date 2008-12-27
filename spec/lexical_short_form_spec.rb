require File.join(File.dirname(__FILE__), 'spec_helper')
require 'measure'
require 'measure/support'

describe Measure, 'with lexical short form support' do
  before :all do
    Measure.def_unit :a, :test
    Measure.def_unit :b, :test
    Measure.def_conversion :a, :b => 10
  end

  it 'allows us to use short form in a block' do
    lambda {
      Measure.form { 1.a }
    }.should_not raise_error(Exception)
    lambda {
      Measure.form { 1.a.as_b }
    }.should_not raise_error(Exception)
  end

  it 'does not allow us to use short form out of a block' do
    lambda {
      out_of_block = lambda { 1.a }
      Measure.form {
        in_block = lambda { 1.a }
        STDERR.puts "ahi: #{caller[0,2].inspect}"
        out_of_block[]
        in_block[]
      }
    }.should raise_error(NoMethodError)
  end
end
