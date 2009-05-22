require 'test_helper'
require 'json'

class ExecutorTest < Test::Unit::TestCase

  context "execute method" do

    setup do
      FakeWeb.allow_net_connect = false

      @username, @password = random_string, random_string
      @command, @options = random_string, random_hash
      @uri = build_uri(@command, @username, @password, @options)
    end

    should 'send a GET request to proper uri' do
      response = random_string
      FakeWeb.register_uri(:get, @uri, :string => response)
      TextMagic::API::Executor.execute(@command, @username, @password, @options)
    end

    should 'raise an error if the response contains error_code' do
      response = "{error_code:#{1 + rand(10)}}"
      FakeWeb.register_uri(:get, @uri, :string => response)
      lambda {
        TextMagic::API::Executor.execute(@command, @username, @password, @options)
      }.should raise_error(TextMagic::API::Error)
    end

    should 'return a hash with values in the response' do
      hash = random_hash
      FakeWeb.register_uri(:get, @uri, :string => hash.to_json)
      response = TextMagic::API::Executor.execute(@command, @username, @password, @options)
      response.should == hash
    end
  end
end
