# encoding: utf-8

require 'preamble'

describe Peck::Rails do
  before do
    @subject = Author
  end

  it "is properly loaded and defined" do
    Peck::Rails.should.be.kind_of?(Class)
  end

  it "returns the subject of a context" do
    context = FakeContext.new(:description => [@subject])
    Peck::Rails.subject(context).should.eql(@subject)

    context = FakeContext.new(:description => ["A", @subject])
    Peck::Rails.subject(context).should.eql(@subject)

    context = FakeContext.new(:description => ["Any plain object"])
    Peck::Rails.subject(context).should.be.nil
  end

  it "returns the proper context type for a subject" do
    context = FakeContext.new(:description => [@subject])
    Peck::Rails.context_type(context, @subject).should.eql(:model)

    context = FakeContext.new(:description => ["Any plain object"])
    Peck::Rails.context_type(context, nil).should.eql(:plain)
  end
end