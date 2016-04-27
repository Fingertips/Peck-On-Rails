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

      def redirect
        requirement = Response.new(context)
        requirement.verb_description = 'redirect'
        requirement.method = :status
        if @negated
          requirement.expected = :ok
        else
          requirement.expected = :found
        end
        requirement
      end
    end

    def equal_record_set(*others)
      left = @this.flatten
      right = others.flatten

      message = "Expected the record set to be #{!@negated ? 'equal' : 'unequal'}: #{left.map(&:id).inspect} - #{right.map(&:id).inspect}"
      satisfy(message) { Set.new(left) == Set.new(right) }
    end

    def equal_record_array(*others)
      left = @this.flatten
      right = others.flatten

      message = "Expected the array of records to be #{!@negated ? 'equal' : 'unequal'}: #{left.map(&:id).inspect} - #{right.map(&:id).inspect}"
      satisfy(message) { left == right }
    end

    def equal_set(*others)
      left = @this.flatten
      right = others.flatten

      message = "Expected sets to be #{!@negated ? 'equal' : 'unequal'}: #{left.inspect} - #{right.inspect}"
      satisfy(message) { Set.new(left) == Set.new(right) }
    end

    def equal_keys(other)
      left = @this.keys.map(&:to_s).sort
      right = other.map(&:to_s).sort

      missing_from_left = left - right
      missing_from_right = right - left
      message = "Expected the object to #{!@negated ? 'have' : 'not have'} the same keys:\n#{left.inspect}\n#{right.inspect}\n>>> #{missing_from_left.inspect}\n<<< #{missing_from_right.inspect}"
      satisfy(message) { left == right }
    end

    def redirect_to(somewhere)
      message = "Expected to redirect to `#{somewhere}'"
      response = @this.send(:response)
      satisfy(message) { [301, 302].include?(response.status.to_i) && response.location == somewhere }
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