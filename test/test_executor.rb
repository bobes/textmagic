require "test_helper"

class ExecutorTest < Test::Unit::TestCase

  context "execute method" do

    setup do
      FakeWeb.allow_net_connect = false

      @username, @password = random_string, random_string
      @command, @options = random_string, random_hash
      @uri = "http://www.textmagic.com/app/api"
    end

    should "not send HTTP request without command" do
      TextMagic::API::Executor.expects(:post).never
      lambda {
        TextMagic::API::Executor.execute(nil, @username, @password, @options)
      }.should raise_error(TextMagic::API::Error)
    end

    should "not send HTTP request without username" do
      TextMagic::API::Executor.expects(:post).never
      lambda {
        TextMagic::API::Executor.execute(@command, nil, @password, @options)
      }.should raise_error(TextMagic::API::Error)
    end

    should "not send HTTP request without password" do
      TextMagic::API::Executor.expects(:post).never
      lambda {
        TextMagic::API::Executor.execute(@command, @username, nil, @options)
      }.should raise_error(TextMagic::API::Error)
    end

    should "send a POST request to proper uri" do
      response = random_string
      FakeWeb.register_uri(:post, @uri, :body => response)
      TextMagic::API::Executor.execute(@command, @username, @password, @options)
    end

    should "not send parameters with empty keys" do
      options_with_empty_values = @options.merge(nil => random_string, "" => random_string)
      @options.merge!(:username => @username, :password => @password, :cmd => @command)
      TextMagic::API::Executor.expects(:post).with("/api", :body => @options, :format => :json)
      TextMagic::API::Executor.execute(@command, @username, @password, options_with_empty_values)
    end

    should "not send parameters with empty values" do
      options_with_empty_values = @options.merge(random_string => nil, random_string => "")
      @options.merge!(:username => @username, :password => @password, :cmd => @command)
      TextMagic::API::Executor.expects(:post).with("/api", :body => @options, :format => :json)
      TextMagic::API::Executor.execute(@command, @username, @password, options_with_empty_values)
    end

    should "raise an error if the response contains error_code" do
      response = "{error_code:#{1 + rand(10)}}"
      FakeWeb.register_uri(:post, @uri, :body => response)
      lambda {
        TextMagic::API::Executor.execute(@command, @username, @password, @options)
      }.should raise_error(TextMagic::API::Error)
    end

    should "return a hash with values from the response" do
      hash = { "this" => "is", "just" => "a", "random" => "hash" }
      FakeWeb.register_uri(:post, @uri, :body => '{"this":"is","just":"a","random":"hash"}')
      response = TextMagic::API::Executor.execute(@command, @username, @password, @options)
      response.should == hash
    end
  end
end
