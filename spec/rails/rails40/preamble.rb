# encoding: utf-8

gem 'rails', '~> 4.0.0'

require File.expand_path('../../../shared', __FILE__)

Vanilla::Application.routes.draw do
  get 'authors', :to => 'authors#index'
  get 'authors/:id', :to => 'authors#show'
  delete 'authors/:id', :to => 'authors#destroy'
  get 'authors/restricted', :to => 'authors#restricted'
  get 'authors/disallowed', :to => 'authors#disallowed'
end