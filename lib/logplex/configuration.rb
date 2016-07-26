module Logplex
  class Configuration
    attr_accessor :logplex_url,
                  :process,
                  :host,
                  :publish_timeout

    def initialize
      @logplex_url     = 'https://east.logplex.io'
      @host            = 'localhost'
      @publish_timeout = 1
    end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
