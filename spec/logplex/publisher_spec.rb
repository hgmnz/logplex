require 'spec_helper'
require 'sham_rack'
require 'logplex/publisher'
require 'support/fake_logplex'

describe Logplex::Publisher, '#publish' do
  before do
    host = URI.parse('https://logplex.example.com').hostname
    ShamRack.mount(FakeLogplex.new, host, 443)
  end

  after do
    ShamRack.unmount_all
    FakeLogplex.clear!
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
