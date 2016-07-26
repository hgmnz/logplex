# encoding: UTF-8
require 'base64'
require 'restclient'
require 'logplex/message'
require 'timeout'

module Logplex
  class Publisher
    PUBLISH_ERRORS = [RestClient::InternalServerError,
                      RestClient::Unauthorized,
                      Timeout::Error].freeze

    def initialize(token, logplex_url=nil)
      @token       = token
      @logplex_url = logplex_url || Logplex.configuration.logplex_url
    end

    def publish(messages, opts={})
      message_list = messages.dup
      unless messages.is_a? Array
        message_list = [message_list]
      end
      message_list.map! { |m| Message.new(m, opts.merge(token: @token)) }
      message_list.each(&:validate)
      if message_list.inject(true) { |accum, m| m.valid? }
        begin
          Timeout.timeout(Logplex.configuration.publish_timeout) do
            api_post(message_list.map(&:syslog_frame).join(''))
            true
          end
        rescue *PUBLISH_ERRORS
          false
        end
      end
    end

    private

    def api_post(message)
      auth_token = Base64.encode64("token:#{@token}")
      auth = "Basic #{auth_token}"
      RestClient.post(logplex_url, message,
                      content_type: 'application/logplex-1',
                      content_length: message.length,
                      authorization: auth)
    end
  end
end
