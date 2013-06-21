# encoding: utf-8

require 'active_support/testing/assertions'
require 'active_support/testing/deprecation'
require 'active_support/core_ext/kernel/reporting'
require 'active_support/deprecation'
require 'rails/backtrace_cleaner'

class Peck
  class Rails
    module BacktraceCleaning
      protected

      def clean_backtrace(backtrace)
        super Peck::Rails::BacktraceCleaning.backtrace_cleaner.clean(backtrace)
      end

      def self.backtrace_cleaner
        ::Rails.backtrace_cleaner
      end
    end

    class Context
      def self.init(context, context_type, subject)
        Peck.log("Peck::Rails::Context.init")
      end
    end

    class Helper
      def self.init(context, context_type, subject)
        if [:helper].include?(context_type)
          Peck.log("Peck::Rails::Helper.init")
          context.class_eval do
            include subject
          end
        end
      end
    end

    class Model
      def self.init(context, context_type, subject)
        if [:model, :controller, :helper].include?(context_type)
          Peck.log("Peck::Rails::Model.init")
          context.class_eval do
            include ::ActiveRecord::TestFixtures
            self.fixture_path = File.join(::Rails.root, 'test', 'fixtures')
            fixtures :all
            define_method(:method_name) { self.class.label }
          end
        end
      end
    end

    class Controller
      def self.init(context, context_type, subject)
        if context_type == :controller
          Peck.log("Peck::Rails::Controller.init")
          context.class_eval do
            attr_accessor :controller

            before do
              @routes = ::Rails.application.routes
            end

            def self.determine_default_controller_class(name)
              self._controller_class = Peck::Rails.subject(self)
            end

            include ::ActionController::TestCase::Behavior
            include ::Peck::Rails::Controller::Helpers
            extend ::Peck::Rails::Controller::Fixtures
          end
        end
      end

      # Stores expression to be evaluated later in the correct context
      class LazyValue
        def initialize(expression)
          @expression = expression
        end

        def to_param(spec)
          spec.instance_eval(@expression)
        end

        def inspect
          @expression
        end
      end

      module Fixtures
        # Returns true when the passed name is a known table, we assume known tables also have fixtures
        def known_fixture?(name)
          respond_to?(:fixture_table_names) && fixture_table_names.include?(name.to_s)
        end

        # Filter calls to fixture methods so we can use them in the context definition
        def method_missing(method, *arguments, &block)
          if known_fixture?(method)
            arguments = arguments.map { |a| a.inspect }
            ::Peck::Rails::Controller::LazyValue.new("#{method}(#{arguments.join(', ')})")
          else
            super
          end
        end
      end

      module Helpers
        def status
          Peck::Rails::Controller::Status.new(@response)
        end

        def templates
          # Force body to be read in case the template is being streamed
          response.body
          (@templates || @_templates).keys
        end

        def body
          Peck::Rails::Controller::Body.new(@response)
        end

        # Interpret the non-immediate values in params and replace them
        def immediate_values(params)
          result = {}
          params.each do |key, value|
            result[key] = case value
            when Hash
              immediate_values(value)
            when ::Peck::Rails::Controller::LazyValue
              value.to_param(self)
            when Proc
              value.call
            else
              value
            end
          end
          result
        end
      end

      class Status
        def initialize(response)
          @response = response
        end

        def ==(other)
          case other
          when Numeric
            @response.status == other
          else
            code = Rack::Utils::SYMBOL_TO_STATUS_CODE[other]
            @response.status === code
          end
        end

        def inspect
          "#<Peck::Rails::Controller::Status:#{@response.status}>"
        end
      end

      class Body
        def initialize(response)
          @response = response
        end

        def document
          if defined?(:Nokogiri)
            @document ||= Nokogiri::HTML.parse(@response.body)
          else
            raise RuntimeError, "Please install Nokogiri to use the CSS or Xpath matchers (gem install nokogiri)"
          end
        end

        def json
          if defined?(:JSON)
            @json ||= JSON.parse(@response.body)
          else
            raise RuntimeError, "Please install a JSON gem to use the json accessor (gem install json)"
          end
        end

        def match_css?(query)
          !document.css(query).empty?
        end

        def match_xpath?(query)
          !document.xpath(query).empty?
        end

        def blank?
          @response.body.blank?
        end

        def inspect
          "#<html body=\"#{@response.body}\">"
        end
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
      if subject < ActionController::Base
        :controller
      elsif subject < ActiveRecord::Base
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
      Peck.log("Using `#{context_type}' as context type for `#{subject.name}'")
      context_type
    end

    def self.init
      Peck.log("Setting up Peck::Rails")
      proc do |context|
        subject      = Peck::Rails.subject(context)
        context_type = Peck::Rails.context_type(context, subject)
        [
          Peck::Rails::Context,
          Peck::Rails::Helper,
          Peck::Rails::Model,
          Peck::Rails::Controller
        ].each do |klass|
          klass.send(:init, context, context_type, subject)
        end

        context.before do
          setup_fixtures if respond_to?(:setup_fixtures)
        end

        context.after do
          teardown_fixtures if respond_to?(:teardown_fixtures)
        end
      end
    end
  end
end

class Peck
  class Should
    class ResponseRequirement < Peck::Should::Proxy
      SUPPORTED_VERBS = [:get, :post, :put, :delete, :options]

      attr_accessor :method, :exception, :expected

      def define_specification(verb, action, params={})
        _method = self.method
        _negated = self.negated
        _expected = self.expected
        _exception = self.exception
        context.it(description(verb, action, params)) do
          begin
            send(verb, action, immediate_values(params))
          rescue => raised_exception
            if _negated
              raised_exception.should.be.kind_of(_exception)
            else
              raised_exception.should.not.be.kind_of(_exception)
            end
          else
            if _negated
              send(_method).should.not == _expected
            else
              send(_method).should == _expected
            end
          end
        end
      end

      def method_missing(method, *attributes, &block)
        verb = method.to_sym
        if self.class.supported_verbs.include?(verb)
          define_specification(verb, *attributes)
        else
          super
        end
      end

      def self.supported_verbs
        SUPPORTED_VERBS
      end
    end

    class RequireLogin < ResponseRequirement
      def description(verb, action, params={})
        description = []
        description << "should not" if (negated == false)
        description << "#{verb.upcase}s `#{action}' without logging in"
        description << "#{params.inspect}" unless params.blank?
        description.join(' ')
      end
    end

    class Disallow < ResponseRequirement
      def description(verb, action, params={})
        description = ["should"]
        description << "not" if (negated == false)
        description << "be allowed to #{verb.upcase}s `#{action}'"
        description << "#{params.inspect}" unless params.blank?
        description.join(' ')
      end
    end

    class Response < ResponseRequirement
      attr_accessor :verb_description

      def description(verb, action, params={})
        description = ["should"]
        description << "not" if (negated == false)
        description << "#{verb_description} `#{action}'"
        description << "#{params.inspect}" unless params.blank?
        description.join(' ')
      end
    end

    class Specification
      def require_login
        requirement = RequireLogin.new(context)
        requirement.negated = @negated
        requirement.method = :login_required?
        requirement.expected = true
        requirement
      end

      def disallow
        requirement = Disallow.new(context)
        requirement.negated = @negated
        requirement.method = :disallowed?
        requirement.expected = true
        requirement
      end

      def allow
        requirement = Disallow.new(context)
        requirement.negated = @negated
        requirement.method = :allowed?
        requirement.expected = true
        requirement
      end

      def find
        requirement = Response.new(context)
        requirement.negated = @negated
        requirement.verb_description = 'find'
        requirement.method = :status
        if @negated
          requirement.expected = :not_found
          requirement.exception = ActiveRecord::RecordNotFound
        else
          requirement.expected = :ok
        end
        requirement
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

class Peck
  class Should
    def validate_with(attribute, value)
      message = "Expected #{!@negated ? 'no' : ''}errors on #{attribute.inspect} with value `#{value.inspect}' after validation"

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

Peck::Context.once(&Peck::Rails.init)
