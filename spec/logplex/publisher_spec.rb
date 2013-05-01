require 'spec_helper'
require 'sham_rack'
require 'logplex/publisher'
require 'support/fake_logplex'

describe Logplex::Publisher, '#publish' do
  before do
    ShamRack.mount(FakeLogplex.new, 'logplex.example.com', 443)

    Logplex.configure do |config|
      config.process = "postgres"
      config.host = "host"
    end
  end

  after do
    ShamRack.unmount_all
    FakeLogplex.clear!
    restore_default_config
  end

  it 'encodes a message and publishes it' do
    FakeLogplex.register_token('t.some-token')

    message = 'I have a message for you'
    publisher = Logplex::Publisher.new('t.some-token', 'https://logplex.example.com')
    publisher.publish(message)

    expect(FakeLogplex).to have_received_message(message)
  end

  it 'sends many messages in one request when passed an array' do
    FakeLogplex.register_token('t.some-token')
    messages = ['I have a message for you', 'here is another', 'some final thoughts']

    publisher = Logplex::Publisher.new('t.some-token', 'https://logplex.example.com')

    publisher.publish(messages)

    messages.each do |message|
      expect(FakeLogplex).to have_received_message(message)
    end

    expect(FakeLogplex.requests_received).to eq(1)
  end
end
