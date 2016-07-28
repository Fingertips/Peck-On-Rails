# encoding: utf-8

$:.unshift File.expand_path("../../lib", __FILE__)

require 'peck/flavors/vanilla'

# A quick hack to turn off the backtrace cleaner
class Peck
  class Notifiers
    class Base
      def clean_backtrace(backtrace)
        backtrace
      end
    end
  end
end

require 'peck_on_rails'
require 'rails'
require 'active_record'
require 'action_controller'
require 'rack/test'

puts "Running on Rails #{Rails.version}"

module Rails
  class << self
    undef :root
    def root
      File.expand_path('../implementation', __FILE__)
    end
  end
end

module Vanilla
  class Application < Rails::Application
    config.eager_load = false
    config.secret_key_base = 'test'
    config.active_support.deprecation = :stderr
  end
end

Vanilla::Application.initialize!

Dir.glob(File.expand_path('../implementation/**/*.rb', __FILE__)).each do |lib|
  require lib
end

ActionController::Base.view_paths = File.join(Rails.root, 'app/views')

class FakeContext
  attr_accessor :description
  def initialize(attributes={})
    attributes.each { |k,v| send("#{k}=", v) }
  end
end
