class Peck
  class Rails
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

            Peck::Rails.silence do
              include ::ActionController::TestCase::Behavior
            end
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
          if defined?(Nokogiri)
            @document ||= Nokogiri::HTML.parse(@response.body)
          else
            raise RuntimeError, "Please install Nokogiri to use the CSS or Xpath matchers (gem install nokogiri)"
          end
        end

        def json
          if defined?(JSON)
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
  end
end