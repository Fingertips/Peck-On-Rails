class Peck
  class Rails
    class Model
      def self.init(context, context_type, subject)
        if [:model, :controller, :helper].include?(context_type)
          Peck.log("Peck::Rails::Model.init")
          context.class_eval do
            if defined?(::ActiveRecord)
              include ::ActiveRecord::TestFixtures
            end
            self.fixture_path = File.join(::Rails.root, 'test', 'fixtures')
            fixtures :all
            define_method(:method_name) { self.class.label }
          end
        end
      end
    end
  end
end