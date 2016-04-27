# encoding: utf-8

require 'preamble'

describe AuthorsController do
  it "has the correct routes configured" do
    @routes.should.be.kind_of(ActionDispatch::Routing::RouteSet)
  end

  it "has the right controller class configured" do
    _controller_class.should == AuthorsController
  end
end

describe AuthorsController, "concerning controller-specific requirements" do
  def login_required?
    @response.status == 401
  end

  def allowed?
    @response.status == 200
  end

  def disallowed?
    @response.status == 403
  end

  should.not.require_login.get :index
  should.require_login.get :restricted

  should.allow.get :index
  should.not.allow.get :disallowed

  should.disallow.get :disallowed
  should.not.disallow.get :index

  should.find.get :index
  should.not.find.get :show, id: 12

  should.redirect.delete :destroy, id: 12
end
