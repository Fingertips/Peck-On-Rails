# encoding: utf-8

require 'preamble'

describe Peck::Should::Specification do
  before do
    @spec = Peck::Should::Specification.new(self)
  end

  describe "initializes a potential specification for checking if a resource" do
    it "requires a login" do
      rec = @spec.require_login
      rec.negated.should == false
      rec.method.should == :login_required?
      rec.expected.should == true
    end

    it "does not require a login" do
      rec = @spec.not.require_login
      rec.negated.should == true
      rec.method.should == :login_required?
      rec.expected.should == true
    end

    it "is found" do
      rec = @spec.find
      rec.negated.should == false
      rec.method.should == :status
      rec.expected.should == :ok
    end

    it "is not found" do
      rec = @spec.not.find
      rec.negated.should == true
      rec.method.should == :status
      rec.expected.should == :not_found
    end
  end
end