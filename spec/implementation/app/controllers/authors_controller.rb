# encoding: utf-8

class AuthorsController < ActionController::Base
  include Rails.application.routes.url_helpers

  def index
    render :nothing => true
  end
end
