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

    describe "#unit" do
      context "just created" do
        it "should not raise error calling with :xyz" do
          lambda { subject.unit :xyz }.should_not raise_error
        end
      end

      context "after defining an unit :xyz" do
        it "should not raise error calling with :xyz" do
          lambda { subject.unit :xyz }.should_not raise_error
        end
      end
    end

    describe "#include?" do
      context "just created" do
        it { should_not be_include(:xyz) }
      end

      context "after defining an unit :xyz" do
        before(:each) { subject.unit :xyz }
        it { should be_include(:xyz) }
      end
    end
  end
end
