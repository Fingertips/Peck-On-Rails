# encoding: utf-8

require 'preamble'

describe AuthorsController do
  it "has the correct routes configured" do
    @routes.should.be.kind_of(ActionDispatch::Routing::RouteSet)
  end

  it "has the right controller class configured" do
    _controller_class.should.eql(AuthorsController)
  end

  if Rails.version >= "5.0.0"
    it "raises an exception when none of the template instance variables are defined" do
      lambda do
        templates
      end.should.raise(NoMethodError)
    end
  else
    it "returns an empty array when nothing was rendered" do
      templates.should.eql []
    end

    it "returns the path to the template when something was rendered" do
      get :name, id: 12
      templates.should.eql %w(authors/name)
    end
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

  if Rails.version >= "5.0.0"
    should.not.find.get :show, params: { id: 12 }
  else
    should.not.find.get :show, id: 12
  end
end
