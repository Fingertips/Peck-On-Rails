# encoding: utf-8

$:.unshift File.expand_path("../../lib", __FILE__)

require 'peck/flavors/vanilla'
require 'peck_on_rails'

require 'rails'
require 'active_record'
require 'action_controller'

class Author < ActiveRecord::Base
  self.abstract_class = true
end

class FakeContext
  attr_accessor :description
  def initialize(attributes={})
    attributes.each { |k,v| send("#{k}=", v) }
  end
end

