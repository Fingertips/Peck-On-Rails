# Peck On Rails

Peck-On-Rails is an extension for Peck to make testing Rails easier.

[![Build Status](https://secure.travis-ci.org/Fingertips/Peck-On-Rails.png?branch=master)](http://travis-ci.org/Fingertips/Peck)

## Getting Started

You can install Peck-On-Rails as a gem. Note that the Peck dependency will automatically be fulfilled.

    $ gem install peck-on-rails
    
You can also add it to your Rails application's `Gemfile`.

    group :test do
      gem 'peck-on-rails'
    end

To use it in your Rails application, create or edit a file named `test/test_helper.rb`;

    ENV["RAILS_ENV"] ||= "test"
    require File.expand_path('../../config/environment', __FILE__)
    
    require 'peck/flavors/vanilla'
    require 'peck_on_rails'

You can read more about Peck formatting and flavors in [Peck's documentation](https://github.com/Fingertips/Peck).

Don't forget to require your test helper in your test files. We like to require relative to the file so you can use Ruby to run the tests.

    require File.expand_path('../../test_helper', __FILE__)
    
    describe AuthorsController do
      should.find.get :index
    end

Now just run your test:

    $ ruby test/functional/authors_controller_test.rb
    .
    1 spec, 0 failures, finished in 0.13 seconds.

Alternatively Peck has a CLI tool to run tests for you:

    $ peck test/models/book_test.rb
    .
    1 spec, 0 failures, finished in 0.0 seconds.

## Test types

Peck-On-Rails automatically supports model, controller, and helper specs. By default it figures out what kind of test your writing by the class found in the context. For example, POR will assume you're operating on an Active Record model when Book inherits from `ActiveRecord::Base`.

    describe "A new", Book do
      it "does not have any pages" do
        book = Book.new
        book.pages.count.should.eql(0)
      end
    end

If POR has trouble figuring out what you're doing, you can force it:

    describe Candle, :model do
    end

Supported types are `:model`, `:controller`, and `:helper`.

## Model specs

POR loads fixtures for `:model` type tests. It also does this for `:controller` and `:helper` tests by the way. This also means it doesn't load fixtures for library specs.

There is one little matcher that you get in your model specs: a validation matcher.

    describe Book do
      it "requires a title" do
        book = Book.new

        book.should.not.validate_with(:title, nil)
        book.should.not.validate_with(:title, '')

        book.should.validate_with(:title, 'The Fault in Our Stars')
      end
    end

Note that this matcher is a bit dirty as it changes your instance:

    describe Book do
      it "requires a title" do
        book = Book.new
        book.should.not.validate_with(:title, nil)
        p book.errors.full_messages
      end
    end

## Helper specs

In `:helper` specs you automatically get your helper module included.

    describe BooksHelper do
      it "formats titles" do
        book = Book.new(title: 'Little Pinguin', :number = 12)
        format_book_title(book).should.eql("12. Little Pinguin")
      end
    end

## Controller specs

For controller specs you get a `@controller` instance, a `controller` accessor, routing, and some nifty helpers.

    describe "On the", BooksController, "a visitor" do
      it "sees an overview of recent books" do
        get :index
        status.should.eql(:ok)
        templates.should.include 'books/index'
        body.should.match_css 'h1' # Only possible when Nokogiri is installed
        body.should.match_xpath '//h1' # Only possible when Nokogiri is installed
        body.document # Returns the Nokogiri Document
      end

      it "sees and overview of recent books in JSON" do
        get :index, :format => 'json'
        body.should.not.be.blank
        body.json.keys.should.include 'books'
      end
    end

On top of that you get some macro's to generate specs which will test basic functions of the controller.

    describe "On the", Manage::BooksController, "a visitor" do
      should.require_login :index
    end
   
    describe "On the", Manage::BooksController, "a regular member" do
      should.disallow :index
    end
   
    describe "On the", Manage::BooksController, "an admin" do
      should.find :index
    end

These generated specs assume there are three methods defined on the spec: `login_required?`, `disallowed?`, and `allowed?`. We usually define them as follows:

    module TestHelper
      module Authentication
        def login_required?
          if @request.format == 'text/html'
            @response.location == new_session_url
          else
            @response.status == 401
          end
        end

        def allowed?
          @response.status == 200
        end
        
        def disallowed?
          @response.status == 403
        end
      end
    end
    
    # Auto include these methods on all `:controller` context instances.
    Peck::Context.once do |context|
      case context_type
      when :controller
        extend TestHelper::Authentication
      end
    end

## Writing matchers

Right now you have to open up the `Peck::Should` class to do this:

    class Peck
      class Should
        def validate_with(attribute, value)
          message = "Expected #{!@negated ? 'no' : ''}errors on" +
            " #{attribute.inspect} with value `#{value.inspect}' after validation"

          @this.send("#{attribute}=", value)
          @this.valid?
          if @this.errors[attribute].kind_of?(Array)
            satisfy(message) { @this.errors[attribute].empty? }
          else
            satisfy(message) { @this.errors[attribute].nil? }
          end
        end
      end
    end

## Adding before or after methods for all specs

You can use Peck's callback which is ran for each context once:

    Peck::Context.once do |context|
      class_eval do
        before do
          FileUtils.rm_rf(my_nice_directory)
          FileUtils.mkdir_p(my_nice_directory)
        end
      end
    end
