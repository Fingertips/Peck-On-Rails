# encoding: utf-8

class AuthorsController < ActionController::Base
  include Rails.application.routes.url_helpers

  def index
    render :nothing => true
  end

  def restricted
    render :nothing => true, :status => 401
  end

  def disallowed
    render :nothing => true, :status => 403
  end
end
