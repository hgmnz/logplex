require 'spec_helper'
require 'sham_rack'
require 'logplex/consumer'
require 'support/fake_logplex'

describe Logplex::Consumer, '#consume' do
  before do
    Logplex.configure do |config|
      config.process = "postgres"
      config.host = "host"
    end
  end

  context 'with a working logplex' do
    before do
      ShamRack.mount(FakeLogplex.new, 'logplex.example.com', 443)
    end

    after do
      ShamRack.unmount_all
      FakeLogplex.clear!
      restore_default_config
    end

    it 'consume a message and returns it' do
      FakeLogplex.register_token('t.some-token')

      consumer = Logplex::Consumer.new('t.some-token', 1, 'https://logplex.example.com')
      log = consumer.consume{ |l| break l }

      expect(log.message).to eq("test message 1")
      expect(log.process).to eq("console.1")
      expect(log.source).to eq("app")
      expect(log.time).to eq("2012-12-10T03:00:48Z+00:00")
    end
  end
end