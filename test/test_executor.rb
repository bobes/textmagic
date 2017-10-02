require "test_helper"

describe "Executor" do

  describe "execute method" do

    before do
      @username, @password = random_string, random_string
      @command, @options = random_string, random_hash
      @uri = "https://www.textmagic.com/app/api"
    end

    it "should not send HTTP request without command" do
      assert_raises TextMagic::API::Error do
        TextMagic::API::Executor.execute(nil, @username, @password, @options)
      end
    end

    it "should not send HTTP request without username" do
      TextMagic::API::Executor.expects(:post).never
      assert_raises(TextMagic::API::Error) { TextMagic::API::Executor.execute(@command, nil, @password, @options) }
    end

    it "should not send HTTP request without password" do
      TextMagic::API::Executor.expects(:post).never
      assert_raises TextMagic::API::Error do
        TextMagic::API::Executor.execute(@command, @username, nil, @options)
      end
    end

    it "should send a POST request to proper uri" do
      WebMock.stub_request(:post, @uri).to_return(status: 200, body: "{}")
      TextMagic::API::Executor.execute(@command, @username, @password, @options)
    end

    it "should not send parameters with nil keys" do
      options_with_empty_values = @options.merge(nil => random_string)
      @options.merge!(:username => @username, :password => @password, :cmd => @command)
      WebMock.
        stub_request(:post, @uri).
        with(body: @options).
        to_return(status: 200, body: "", headers: {})
      TextMagic::API::Executor.execute(@command, @username, @password, options_with_empty_values)
    end

    it "should not send parameters with nil values" do
      options_with_empty_values = @options.merge(random_string => nil)
      @options.merge!(:username => @username, :password => @password, :cmd => @command)
      WebMock.
        stub_request(:post, @uri).
        with(body: @options).
        to_return(status: 200, body: "", headers: {})
      TextMagic::API::Executor.execute(@command, @username, @password, options_with_empty_values)
    end

    it "should raise an error if the response contains error_code" do
      response = "{\"error_code\":#{1 + rand(10)}}"
      WebMock.stub_request(:post, @uri).to_return(status: 200, body: response)
      assert_raises TextMagic::API::Error do
        TextMagic::API::Executor.execute(@command, @username, @password, @options)
      end
    end

    it "should return a hash with values from the response" do
      hash = { "this" => "is", "just" => "a", "random" => "hash" }
      response = '{"this":"is","just":"a","random":"hash"}'
      WebMock.stub_request(:post, @uri).to_return(status: 200, body: response)
      response = TextMagic::API::Executor.execute(@command, @username, @password, @options)
      assert_equal hash, response.to_hash
    end

  end

end
