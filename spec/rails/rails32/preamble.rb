# encoding: utf-8

gem 'rails', '~> 3.2.0'
gem 'i18n', '~> 0.6.0'

require File.expand_path('../../../shared', __FILE__)

Vanilla::Application.routes.draw do
  get 'authors', :to => 'authors#index'
  get 'authors/:id', :to => 'authors#show'
  get 'authors/restricted', :to => 'authors#restricted'
  get 'authors/disallowed', :to => 'authors#disallowed'
end