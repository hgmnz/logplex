module Logplex
  class Configuration
    attr_accessor :logplex_url,
      :process,
      :host

    def initialize
      @logplex_url = 'https://east.logplex.io'
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
