# encoding: utf-8

require 'active_support/testing/assertions'
require 'active_support/testing/deprecation'
require 'active_support/core_ext/kernel/reporting'
require 'active_support/deprecation'
require 'rails/backtrace_cleaner'

require 'peck_on_rails/assertions'
require 'peck_on_rails/backtrace_cleaning'
require 'peck_on_rails/controller'
require 'peck_on_rails/helper'
require 'peck_on_rails/model'

class Peck
  class Rails
    def self.dev_null
      @dev_null ||= File.open('/dev/null', 'w')
    end

    def self.silence
      stdout, stderr = $stdout, $stderr
      $stdout, $stderr = dev_null, dev_null
      begin
        yield
      ensure
        $stdout, $stderr = stdout, stderr
      end
    end

    def self.subject(context)
      context.description.find { |a| a.is_a?(Module) }
    end

    def self.context_type_for_description(context, subject)
      context.description.find do |subject|
        subject.is_a?(Symbol)
      end
    end

    HELPER_RE = /Helper$/

    def self.context_type_for_subject(context, subject)
      if subject.nil?
        :plain
      elsif defined?(ActionController) && subject < ActionController::Base
        :controller
      elsif defined?(ActiveRecord) && subject < ActiveRecord::Base
        :model
      elsif subject.name =~ HELPER_RE
        :helper
      else
        :plain
      end
    end

    def self.context_type(context, subject)
      context_type =
        context_type_for_description(context, subject) ||
        context_type_for_subject(context, subject)
      Peck.log("Using `#{context_type}' as context type for `#{subject.respond_to?(:name) ? subject.name : subject}'")
      context_type
    end

    def self.init
      if defined?(ActiveRecord)
        Peck.log("Migrate database if necessary")
        ActiveRecord::Migration.load_schema_if_pending!
      end
      Peck.log("Setting up Peck::Rails")
      proc do |context|
        subject      = Peck::Rails.subject(context)
        context_type = Peck::Rails.context_type(context, subject)
        [
          Peck::Rails::Helper,
          Peck::Rails::Model,
          Peck::Rails::Controller
        ].each do |klass|
          klass.send(:init, context, context_type, subject)
        end

        context.before do
          if respond_to?(:setup_fixtures)
            begin
              setup_fixtures
            rescue ActiveRecord::ConnectionNotEstablished
            end
          end
        end

        context.after do
          if respond_to?(:teardown_fixtures)
            begin
              teardown_fixtures
            rescue ActiveRecord::ConnectionNotEstablished
            end
          end
        end
      end
    end
  end
end

class Peck
  class Notifiers
    class Base
      include Peck::Rails::BacktraceCleaning
    end
  end
end

Peck::Context.once(&Peck::Rails.init)
