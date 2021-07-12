# encoding: UTF-8
require 'excon'
require 'logplex/message'
require 'timeout'

module Logplex
  class Publisher
    PUBLISH_ERRORS = [Excon::Errors::InternalServerError,
                      Excon::Errors::Unauthorized,
                      Timeout::Error].freeze

    def initialize(logplex_url = nil)
      @logplex_url = logplex_url || Logplex.configuration.logplex_url
      @token = URI(@logplex_url).password || Logplex.configuration.app_name
    end

    def publish(messages, opts={})
      message_list = messages.dup
      unless messages.is_a? Array
        message_list = [message_list]
      end
      message_list.map! { |m| Message.new(m, { app_name: @token }.merge(opts)) }
      message_list.each(&:validate)
      if message_list.inject(true) { |accum, m| m.valid? }
        begin
          Timeout.timeout(Logplex.configuration.publish_timeout) do
            api_post(message_list.map(&:syslog_frame).join(''), message_list.length)
            true
          end
        rescue *PUBLISH_ERRORS
          false
        end
      end
    end

    private

    def api_post(message, number_messages)
      Excon.post(@logplex_url, body: message, headers: {
        "Content-Type" => 'application/logplex-1',
        "Content-Length" => message.length,
        "Logplex-Msg-Count" => number_messages
      }, expects: [200, 204])
    end
  end
end
