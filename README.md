# Peck On Rails

Peck-On-Rails is an extension for Peck to make testing Rails easier.

[![Build Status](https://secure.travis-ci.org/Fingertips/Peck-On-Rails.png?branch=master)](http://travis-ci.org/Fingertips/Peck)

## Getting Started

You can install Peck On Rails as a gem.

    $ gem install peck-on-rails
    
Or add it to your Rails application's `Gemfile`.

    gem 'peck-on-rails'

Then, to use it in your Rails application, create a file named `test/test_helper.rb`;

    ENV["RAILS_ENV"] ||= "test"
    require File.expand_path('../../config/environment', __FILE__)
    
    require 'peck/flavors/vanilla'
    require 'peck_on_rails'

Don't forget to require your test helper in your test files;

    require File.expand_path('../../test_helper', __FILE__)
    
    describe AuthorsController do
      should.find.get :index
    end

Now just run your test;

    $ ruby test/functional/authors_controller_test.rb
    .
    1 spec, 0 failures, finished in 0.13 seconds.
