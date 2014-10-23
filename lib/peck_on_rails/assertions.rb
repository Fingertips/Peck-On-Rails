class Peck
  class Should
    class ResponseRequirement < Peck::Should::Proxy
      SUPPORTED_VERBS = [:get, :post, :put, :delete, :options]

      attr_accessor :method, :allowed_exceptions, :expected

      def define_specification(verb, action, params={})
        _method = self.method
        _negated = self.negated
        _expected = self.expected
        _allowed_exceptions = self.allowed_exceptions
        context.it(description(verb, action, params)) do
          begin
            send(verb, action, immediate_values(params))
          rescue => raised_exception
            if _allowed_exceptions
              _allowed_exceptions.any? { |exception| raised_exception.should.be.kind_of(exception) }
              true.should == true # Force the expectations counter
            else
              raise
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
      def self.allowed_exceptions
        allowed_exceptions = []
        if defined?(ActiveRecord)
          allowed_exceptions << ActiveRecord::RecordNotFound
        end
        if defined?(AbstractController)
          allowed_exceptions << AbstractController::ActionNotFound
        end
        allowed_exceptions
      end
      ALLOWED_EXCEPTIONS = allowed_exceptions
      
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
        requirement.verb_description = 'find'
        requirement.method = :status
        if @negated
          requirement.expected = :not_found
          requirement.allowed_exceptions = ALLOWED_EXCEPTIONS
        else
          requirement.expected = :ok
        end
        requirement
      end
    end

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