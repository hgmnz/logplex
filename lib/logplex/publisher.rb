# encoding: UTF-8
require 'base64'
require 'restclient'
require 'logplex/message'

module Logplex
  class Publisher
    def initialize(token, logplex_url=nil)
      @token       = token
      @logplex_url = logplex_url || 'https://east.logplex.io'
    end

    def publish(messages, opts={})
      messages = Array(messages).dup
      messages.map! { |m| Message.new(m, opts.merge(token: @token)) }
      messages.each(&:validate)
      if messages.inject(true) { |accum, m| m.valid? }
        api_post(
          messages.map(&:syslog_frame).join('')
        )
      end
    end

  private
    def api_post(message)
      auth_token = Base64.encode64("token:#{@token}")
      auth = "Basic #{auth_token}"
      RestClient.post("#{@logplex_url}/logs", message,
                      content_type: 'application/logplex-1',
                      content_length: message.length,
                      authorization: auth)
    end
  end
end
