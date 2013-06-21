# encoding: utf-8

$:.unshift File.expand_path("../../lib", __FILE__)

require 'peck/flavors/vanilla'
require 'peck_on_rails'

require 'rails'
require 'active_record'
require 'action_controller'

Dir.glob(File.expand_path('../implementation/**/*.rb', __FILE__)).each do |lib|
  require lib
end

module Rails
  class FakeRouteSet
    def extra_keys(params)
      params
    end
  end

  class FakeApplication
    def routes
      @routes ||= Rails::FakeRouteSet.new
    end

    def env_config
      {}
    end
  end

  def self.root
    File.expand_path('../implementation', __FILE__)
  end

  def self.application
    @application ||= Rails::FakeApplication.new
  end
end

ActionController::Base.view_paths = File.join(Rails.root, 'app/views')

class FakeContext
  attr_accessor :description
  def initialize(attributes={})
    attributes.each { |k,v| send("#{k}=", v) }
  end
end

