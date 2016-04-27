# encoding: utf-8

gem 'rails', '~> 4.2.0'

require File.expand_path('../../../shared', __FILE__)

Rails.application.routes.draw do
  get 'authors' => 'authors#index'
  get 'authors/:id' => 'authors#show'
  delete 'authors/:id' => 'authors#destroy'
  get 'authors/restricted' => 'authors#restricted'
  get 'authors/disallowed' => 'authors#disallowed'
end