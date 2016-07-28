# encoding: utf-8

require 'preamble'

describe Peck::Rails::BacktraceCleaning do
  DEFAULT_CLEANER_RE = /^default/

  def clean_backtrace(backtrace)
    backtrace.reject do |line|
      line =~ DEFAULT_CLEANER_RE
    end
  end

  include Peck::Rails::BacktraceCleaning

  it "overrides the backtrace cleaner method in Peck to include Rails' backtrace cleaner" do
    clean_backtrace([
      "default - line 1",
      "default - line 2",
      "other stuff"
    ]).should.eql([
      "other stuff"
    ])
  end
end