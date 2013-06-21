# encoding: utf-8

require File.expand_path('../preamble', __FILE__)

describe Author do
  it "has the correct fixture path configured" do
    fixture_path.should == File.expand_path('../implementation/test/fixtures', __FILE__)
  end

  it "returns the model name for the context" do
    method_name.should == "Author"
  end
end