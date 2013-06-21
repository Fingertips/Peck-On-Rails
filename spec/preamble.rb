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
  def self.root
    File.expand_path('../implementation', __FILE__)
  end
end

class FakeContext
  attr_accessor :description
  def initialize(attributes={})
    attributes.each { |k,v| send("#{k}=", v) }
  end
end

