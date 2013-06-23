require 'json'
require 'valcro'
require 'logplex/log'

module Logplex
  class Consumer
    def initialize(token, channel, logplex_url=nil)
      @token = token
      @channel = channel || 1
      @logplex_url = logplex_url || Logplex.configuration.logplex_url
    end

    def consume(&block)
      stream do |response|
        response.read_body do |log|
          yield Log.parse(log)
        end
      end
    end

    private
    def auth
      auth_token = Base64.encode64("token:#{@token}")
      "Basic #{auth_token}"
    end

    def session
      response = RestClient.post("#{@logplex_url}/v2/sessions", {channel: @channel}, authorization: auth)
      JSON.parse(response)['url']
    end

    def stream(&block)
      RestClient::Request.execute(method: :get, url: "#{@logplex_url}#{session}",  raw_response: true, block_response: block, headers: {Authorization: auth})
    end
  end
end