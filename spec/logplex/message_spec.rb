require 'spec_helper'
require 'logplex/message'

describe Logplex::Message do
  before { Logplex.configure { |conf| } }
  it 'fills out fields of a syslog message' do
    message = Logplex::Message.new(
      'my message here',
      token: 't.some-token',
      time: DateTime.parse("1980-08-23 05:31 00:00"),
      process: 'heroku-postgres',
      host: 'some-host',
      message_id: '1'
    )

    expect(message.syslog_frame).to eq(
      "91 <134>1 1980-08-23T05:31:00+00:00 some-host t.some-token heroku-postgres 1 - my message here"
    )
  end

  it 'is invalid for messages longer than 10240 bytes' do
    short = Logplex::Message.new('a' * 10240, token:   'foo',
                                              process: 'proc',
                                              host:    'host')
    long  = Logplex::Message.new('a' * 10241, token: 'foo',
                                              process: 'proc',
                                              host:    'host')
    short.validate
    long.validate

    expect(short.valid?).to be_true
    expect(long.valid?).to be_false
  end

  it 'is invalid with no process or host' do
    message = Logplex::Message.new("a message", token: 't.some-token')
    message.validate

    expect(message.valid?).to be_false
    expect(message.errors[:process]).to eq ["can't be nil"]
    expect(message.errors[:host]).to eq ["can't be nil"]
  end
end
