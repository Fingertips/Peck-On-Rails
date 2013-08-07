# encoding: utf-8

require 'preamble'

describe AuthorsController do
  it "has the correct routes configured" do
    @routes.should.be.kind_of(ActionDispatch::Routing::RouteSet)
  end

  it "has the right controller class configured" do
    _controller_class.should == AuthorsController
  end

  should.find.get :index
  should.not.find.get :show
end
