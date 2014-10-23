
# encoding: utf-8

class Peck
  class Rails
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
  end
end