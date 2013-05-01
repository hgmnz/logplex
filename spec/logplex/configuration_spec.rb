require 'spec_helper'
require 'logplex/configuration'

describe Logplex::Configuration, 'defaults' do
  it 'defaults to the production heroku logplex url' do
    Logplex.configure { |config| }

    expect(
      Logplex.configuration.logplex_url
    ).to eq('https://east.logplex.io')
  end
end
