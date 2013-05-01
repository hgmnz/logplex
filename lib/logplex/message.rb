require 'valcro'
require 'time'
require 'logplex/configuration'

module Logplex
  class Message
    include Valcro

    # facility = local0, priority = info, RFC5452 encoded
    # syslog version 1
    FACILITY_AND_PRIORITY = '<134>1'.freeze

    FIELD_DISABLED = '-'.freeze

    def initialize(message, opts = {})
      @message   = message
      @token      = opts.fetch(:token)
      @time       = opts[:time] || DateTime.now
      @process    = opts[:process] || Logplex.configuration.process
      @host       = opts[:host] || Logplex.configuration.host
      @message_id = opts[:message_id] || FIELD_DISABLED
    end

    def syslog_frame
      temp = "#{FACILITY_AND_PRIORITY} #{formatted_time} #{@host} #{@token} #{@process} #{@message_id} #{FIELD_DISABLED} #{@message}"
      length = temp.length
      "#{length} #{temp}"
    end

    def validate
      super
      errors.add(:message, "too long") if @message.length > 10240
      errors.add(:process, "can't be nil") if @process.nil?
      errors.add(:host, "can't be nil") if @host.nil?
    end

  private
    def formatted_time
      case @time.class
      when String
        DateTime.parse(@time).rfc3339
      else
        @time.to_datetime.rfc3339
      end
    end
  end
end
