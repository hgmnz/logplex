require 'spec_helper'
require 'logplex/message'

describe Logplex::Message do
  it 'fills out fields of a syslog message' do
    message = Logplex::Message.new(
      'my message here',
      token: 't.some-token',
      time: DateTime.parse("1980-08-23 05:31 00:00"),
      process: 'heroku-postgres',
      host: 'some-host',
      message_id: '1'
    )

    expect(message.syslog_encode).to eq(
      "89 <134>1 1980-08-23T05:31:00+00:00 some-host t.some-token heroku-postgres 1 my message here"
    )
  end

  it 'is invalid for messages longer than 10240 bytes' do
    short = Logplex::Message.new('a' * 10240, token: 'foo')
    long = Logplex::Message.new('a' * 10241, token: 'foo')
    short.validate
    long.validate

    expect(short.valid?).to be_true
    expect(long.valid?).to be_false
  end
end
