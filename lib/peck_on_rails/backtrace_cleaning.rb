# encoding: utf-8

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
  end
end