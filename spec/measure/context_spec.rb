require_relative File.join('..', 'spec_helper')
require 'measure'

module Measure
  describe Context do
    describe "#context_eval" do
      specify "the passing block should be evaluated in subject's instance context" do
        evaluated = false
        inside_self = nil
        subject.context_eval {
          evaluated = true
          inside_self = self
        }
        subject.should == inside_self
        evaluated.should be_true
      end
    end
  end

  describe "#unit" do
    context "with a symbol" do
      subject { Context.new }
      it "should define a new unit whose name is the passing symbol" do
        subject.unit :new_unit
        subject.should be_include(:new_unit)
      end
    end
  end

  describe "#include?" do
    context "just created" do
      subject { Context.new }
      it "should be false for any arguments" do
        subject.should_not be_include(:unit)
      end
    end
  end
end
