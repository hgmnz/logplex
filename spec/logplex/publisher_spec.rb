require 'spec_helper'
require 'sham_rack'
require 'logplex/publisher'
require 'support/fake_logplex'

describe Logplex::Publisher do
  describe '#publish' do
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

      it 'does the thing' do
        FakeLogplex.register_token('t.some-token')

        message = { hi: 'there' }
        publisher = Logplex::Publisher.new('t.some-token', 'https://logplex.example.com')
        publisher.publish(message)

        expect(FakeLogplex).to have_received_message('hi="there"')
      end

      it 'returns true' do
        FakeLogplex.register_token('t.some-token')

        message = 'I have a message for you'
        publisher = Logplex::Publisher.new('t.some-token', 'https://logplex.example.com')
        expect(publisher.publish(message)).to be_true
      end

      it "returns false when there's an auth error" do
        message = 'I have a message for you'
        publisher = Logplex::Publisher.new('t.some-token', 'https://logplex.example.com')
        expect(publisher.publish(message)).to be_false
      end
    end

    context 'when the logplex service is acting up' do
      before do
        ShamRack.at('logplex.example.com', 443) do
          [500, {}, []]
        end
      end

      after { ShamRack.unmount_all }

      it 'returns false' do
        publisher = Logplex::Publisher.new('t.some-token', 'https://logplex.example.com')
        expect(publisher.publish('hi')).to be_false
      end
    end

    it "handles timeouts" do
      RestClient.stub(:post).and_raise Timeout::Error
      publisher = Logplex::Publisher.new('t.some-token', 'https://logplex.example.com')
      expect(publisher.publish('hi')).to be_false
    end
  end
end
