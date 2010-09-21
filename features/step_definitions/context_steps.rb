require 'measure'

Given /^a context without any predefined units$/ do
  @context = Measure::Context.new
end


When /^I pass the block for defining two units, :meter and :inch, to the context_eval method of the context$/ do |string|
  @context.context_eval do
    eval(string, binding)
  end
end

Then /^the units :meter and :inch is defined$/ do
  @context.should be_include(:meter)
  @context.should be_include(:inch)
end
