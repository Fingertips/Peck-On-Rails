# encoding: utf-8

require File.expand_path('../preamble', __FILE__)

class Author < ActiveRecord::Base
end

describe Peck::Rails do
  before do
    @subject = Author
  end

  it "returns the subject of a context" do
    context = describe(@subject) {}
    Peck::Rails.subject(context).should == @subject

    context = describe("A", @subject) {}
    Peck::Rails.subject(context).should == @subject
  end

  it "returns the proper context type for a subject" do
    context = describe(@subject) {}
    Peck::Rails.context_type(context, @subject).should == :model
  end
end