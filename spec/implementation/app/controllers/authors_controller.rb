# encoding: utf-8

class AuthorsController < ActionController::Base
  include Rails.application.routes.url_helpers

  def index
    head :ok
  end

  def restricted
    head :unauthorized
  end

  def disallowed
    head :forbidden
  end
end
