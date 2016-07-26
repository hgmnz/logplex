require 'spec_helper'
require 'logplex/publisher'

describe Logplex::Publisher do
  describe '#publish' do
    before do
      Excon.defaults[:mock] = true
      Logplex.configure do |config|
        config.process = "postgres"
        config.host = "host"
      end
    end

    after do
      Excon.stubs.clear
    end

    context 'with a working logplex' do
      after do
        restore_default_config
      end

      it 'encodes a message and publishes it' do
        Excon.stub({ method: :post, password: "t.some-token", body: /message for you/ }, status: 200)
        message = 'I have a message for you'
        publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
        publisher.publish(message)
      end

      it 'sends many messages in one request when passed an array' do
        Excon.stub({ method: :post, password: "t.some-token", body: /here is another/ }, status: 200)
        expect(Excon).to receive(:post).once
        messages = ['I have a message for you', 'here is another', 'some final thoughts']

        publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')

        publisher.publish(messages)
      end

      it 'does the thing' do
        Excon.stub({ method: :post, password: "t.some-token", body: /hi\="there\"/ }, status: 200)
        message = { hi: 'there' }
        publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
        expect(publisher.publish(message)).to be_truthy
      end

      it 'returns true' do
        Excon.stub({ method: :post, password: "t.some-token" }, status: 200)
        message = 'I have a message for you'
        publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
        expect(publisher.publish(message)).to be_truthy
      end

      it "returns false when there's an auth error" do
        Excon.stub({ method: :post, password: "t.some-token" }, status: 401)
        message = 'I have a message for you'
        publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
        expect(publisher.publish(message)).to be_falsey
      end
    end

    context 'when the logplex service is acting up' do
      it 'returns false' do
        Excon.stub({ method: :post, password: "t.some-token" }, status: 500)
        publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
        expect(publisher.publish('hi')).to be_falsey
      end
    end

    it "handles timeouts" do
      expect(Excon).to receive(:post).and_raise(Timeout::Error)
      publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
      expect(publisher.publish('hi')).to be_falsey
    end
  end
end
