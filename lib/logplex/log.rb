require "logfmt"

module Logplex
  class Log
    include Valcro

    RE_LOG = /^(?<time>[^ ]*) (?<source>[^\[]*)\[(?<process>[^\]]*)\]: (?<message>.*)$/

    attr_reader :message, :time, :source, :process

    def initialize(message, opts = {})
      @message = message
      @source = opts[:source] || "app"
      @process = opts[:process] || Logplex.configuration.process
      @time = opts[:time] || DateTime.now
    end

    def self.parse(log)
      RE_LOG.match(log) do |m|
        self.new m[:message], m
      end
    end

    def logfmt
      Logfmt.parse(@message)
    end

    def validate
      super
      errors.add(:source, "can't be nil") if @source.nil?
      errors.add(:time, "can't be nil") if @time.nil?
      errors.add(:message, "too long") if @message.length > 10240
      errors.add(:process, "can't be nil") if @process.nil?
    end
  end
end