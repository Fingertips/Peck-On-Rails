# encoding: utf-8

require 'preamble'

describe Author do
  it "has the correct fixture path configured" do
    fixture_path.should.eql(File.expand_path('../implementation/test/fixtures', __FILE__))
  end

  it "returns the model name for the context" do
    method_name.should.eql("Author")
  end
end