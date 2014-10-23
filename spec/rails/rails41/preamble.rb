# encoding: utf-8

gem 'rails', '~> 4.1.0'

require File.expand_path('../../../shared', __FILE__)

Rails.application.routes.draw do
  get 'authors' => 'authors#index'
  get 'authors/:id' => 'authors#show'
  get 'authors/restricted' => 'authors#restricted'
  get 'authors/disallowed' => 'authors#disallowed'
end

