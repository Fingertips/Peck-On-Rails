# encoding: utf-8

require 'preamble'

describe Peck::Should::Specification do
  it "initializes a potential specification for checking if a resource is found" do
    spec = Peck::Should::Specification.new(self).find
    spec.negated.should == false
    spec.method.should == :status
    spec.expected.should == :ok
  end
end