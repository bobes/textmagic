# encoding: utf-8

require "test_helper"

class APITest < Minitest::Test

  context "Initialization" do

    should "require username and password" do
      assert_raises(ArgumentError){ TextMagic::API.new }
      TextMagic::API.new(random_string, random_string)
    end
  end

  context "Account command" do

    setup do
      @username, @password = random_string, random_string
      @api = TextMagic::API.new(@username, @password)
      @response = random_string
      @processed_response = random_string
      TextMagic::API::Executor.stubs(:execute).returns(@response)
      TextMagic::API::Response.stubs(:account).returns(@processed_response)
    end

    should "call Executor execute with correct arguments" do
      TextMagic::API::Executor.expects(:execute).with("account", @username, @password).returns(@response)
      @api.account
    end

    should "call Response.account method to process the response hash" do
      processed_response = rand
      TextMagic::API::Response.expects(:account).with(@response).returns(processed_response)
      assert_equal(@api.account, processed_response)
    end
  end

  context "Send command" do

    setup do
      @username, @password = random_string, random_string
      @text, @phone = random_string, random_phone
      @api = TextMagic::API.new(@username, @password)
      @response = random_string
      @processed_response = random_string
      TextMagic::API::Executor.stubs(:execute).returns(@response)
      TextMagic::API::Response.stubs(:send).returns(@processed_response)
    end

    should "call Executor execute with correct arguments" do
      TextMagic::API::Executor.expects(:execute).with("send", @username, @password, :text => @text, :phone => @phone, :unicode => 0).returns(@response)
      @api.send(@text, @phone)
    end

    should "join multiple phone numbers supplied as an array" do
      phones = Array.new(3) { random_phone }
      TextMagic::API::Executor.expects(:execute).with("send", @username, @password, :text => @text, :phone => phones.join(","), :unicode => 0).returns(@response)
      @api.send(@text, phones)
    end

    should "join multiple phone numbers supplied as arguments" do
      phones = Array.new(3) { random_phone }
      TextMagic::API::Executor.expects(:execute).with("send", @username, @password, :text => @text, :phone => phones.join(","), :unicode => 0).returns(@response)
      @api.send(@text, *phones)
    end

    should "replace true with 1 for unicode" do
      TextMagic::API::Executor.expects(:execute).with("send", @username, @password, :text => @text, :phone => @phone, :unicode => 1).returns(@response)
      @api.send(@text, @phone, :unicode => true)
    end

    should "set unicode value to 0 if it is not set to by user and text contains only characters from GSM 03.38 charset" do
      TextMagic::API::Executor.expects(:execute).with("send", @username, @password, :text => @text, :phone => @phone, :unicode => 0).returns(@response).times(2)
      @api.send(@text, @phone)
      @api.send(@text, @phone, :unicode => false)
    end

    should "raise an error if unicode is set to 0 and text contains characters outside of GSM 03.38 charset" do
      text = "Вильма Привет"
      assert_raises(TextMagic::API::Error){ @api.send(text, @phone, :unicode => false) }
    end

    should "raise an error if unicode value is not valid" do
      assert_raises(TextMagic::API::Error){ @api.send(@text, @phone, :unicode => 2 + rand(10)) }
      assert_raises(TextMagic::API::Error){ @api.send(@text, @phone, :unicode => random_string) }
    end

    should "raise an error if no phone numbers are specified" do
      assert_raises(TextMagic::API::Error){ @api.send(@text) }
      assert_raises(TextMagic::API::Error){ @api.send(@text, []) }
    end

    should "raise an error if format of any of the specified phone numbers is invalid" do
      TextMagic::API.expects(:validate_phones).returns(false)
      assert_raises(TextMagic::API::Error){ @api.send(@text, random_string) }
    end

    should "raise an error if text is nil" do
      assert_raises(TextMagic::API::Error){ @api.send(nil, @phone) }
    end

    should "raise an error if text is too long" do
      TextMagic::API.expects(:validate_text_length).returns(false)
      assert_raises(TextMagic::API::Error){ @api.send(@text, @phone) }
    end

    should "support send_time option" do
      time = Time.now + rand
      TextMagic::API::Executor.expects(:execute).with("send", @username, @password, :text => @text, :phone => @phone, :unicode => 0, :send_time => time.to_i).returns(@response)
      @api.send(@text, @phone, :send_time => time.to_i)
    end

    should "convert send_time to Fixnum" do
      time = Time.now + rand
      TextMagic::API::Executor.expects(:execute).with("send", @username, @password, :text => @text, :phone => @phone, :unicode => 0, :send_time => time.to_i).returns(@response)
      @api.send(@text, @phone, :send_time => time)
    end

    should "call Response.send method to process the response hash (single phone)" do
      processed_response = rand
      TextMagic::API::Response.expects(:send).with(@response, true).returns(processed_response)
      assert_equal(@api.send(@text, random_phone), processed_response)
    end

    should "call Response.send method to process the response hash (multiple phones)" do
      processed_response = rand
      TextMagic::API::Response.expects(:send).with(@response, false).returns(processed_response).twice
      assert_equal(@api.send(@text, [random_phone]), processed_response)
      assert_equal(@api.send(@text, random_phone, random_phone), processed_response)
    end
  end

  context "Message status command" do

    setup do
      @username, @password = random_string, random_string
      @api = TextMagic::API.new(@username, @password)
      @response = random_string
      @processed_response = random_string
      TextMagic::API::Executor.stubs(:execute).returns(@response)
      TextMagic::API::Response.stubs(:message_status).returns(@processed_response)
    end

    should "call Executor execute with correct arguments" do
      id = random_string
      TextMagic::API::Executor.expects(:execute).with("message_status", @username, @password, :ids => id).returns(@response)
      @api.message_status(id)
    end

    should "join ids supplied as array" do
      ids = Array.new(3) { random_string }
      TextMagic::API::Executor.expects(:execute).with("message_status", @username, @password, :ids => ids.join(","))
      @api.message_status(ids)
    end

    should "join ids supplied as arguments" do
      ids = Array.new(3) { random_string }
      TextMagic::API::Executor.expects(:execute).with("message_status", @username, @password, :ids => ids.join(","))
      @api.message_status(*ids)
    end

    should "not call execute and should raise an exception if no ids are specified" do
      TextMagic::API::Executor.expects(:execute).never
      assert_raises(TextMagic::API::Error){ @api.message_status }
    end

    should "call Response.message_status method to process the response hash (single id)" do
      TextMagic::API::Response.expects(:message_status).with(@response, true).returns(@processed_response)
      assert_equal(@api.message_status(random_string) ,@processed_response)
    end

    should "call Response.message_status method to process the response hash (multiple ids)" do
      TextMagic::API::Response.expects(:message_status).with(@response, false).returns(@processed_response).twice
      assert_equal(@api.message_status([random_string]) ,@processed_response)
      assert_equal(@api.message_status(random_string, random_string) ,@processed_response)
    end
  end

  context "Receive command" do

    setup do
      @username, @password = random_string, random_string
      @api = TextMagic::API.new(@username, @password)
      @response = random_string
      @processed_response = random_string
      TextMagic::API::Executor.stubs(:execute).returns(@response)
      TextMagic::API::Response.stubs(:receive).returns(@processed_response)
    end

    should "call Executor execute with correct arguments" do
      TextMagic::API::Executor.expects(:execute).with("receive", @username, @password, :last_retrieved_id => nil)
      @api.receive
    end

    should "accept last_retrieved_id optional value" do
      last_retrieved_id = rand(1e10)
      TextMagic::API::Executor.expects(:execute).with("receive", @username, @password, :last_retrieved_id => last_retrieved_id)
      @api.receive(last_retrieved_id)
    end

    should "call Response.receive method to process the response hash" do
      TextMagic::API::Response.expects(:receive).with(@response).returns(@processed_response)
      assert_equal(@api.receive(random_string), @processed_response)
    end
  end

  context "Delete reply command" do

    setup do
      @username, @password = random_string, random_string
      @api = TextMagic::API.new(@username, @password)
      @response = random_string
      @processed_response = random_string
      TextMagic::API::Executor.stubs(:execute).returns(@response)
      TextMagic::API::Response.stubs(:delete_reply).returns(@processed_response)
    end

    should "call Executor execute with correct arguments" do
      id = random_string
      TextMagic::API::Executor.expects(:execute).with("delete_reply", @username, @password, :ids => id)
      @api.delete_reply(id)
    end

    should "join ids supplied as array" do
      ids = Array.new(3) { random_string }
      TextMagic::API::Executor.expects(:execute).with("delete_reply", @username, @password, :ids => ids.join(","))
      @api.delete_reply(ids)
    end

    should "join ids supplied as arguments" do
      ids = Array.new(3) { random_string }
      TextMagic::API::Executor.expects(:execute).with("delete_reply", @username, @password, :ids => ids.join(","))
      @api.delete_reply(*ids)
    end

    should "not call execute and should raise an exception if no ids are specified" do
      TextMagic::API::Executor.expects(:execute).never
      assert_raises(TextMagic::API::Error){ @api.delete_reply }
    end

    should "return true" do
      assert_equal(@api.delete_reply(random_string), true)
    end
  end

  context "Check number command" do

    setup do
      @username, @password = random_string, random_string
      @api = TextMagic::API.new(@username, @password)
      @response = random_string
      @processed_response = random_string
      TextMagic::API::Executor.stubs(:execute).returns(@response)
      TextMagic::API::Response.stubs(:check_number).returns(@processed_response)
    end

    should "call Executor execute with correct arguments" do
      phone = random_phone
      TextMagic::API::Executor.expects(:execute).with("check_number", @username, @password, :phone => phone)
      @api.check_number(phone)
    end

    should "join phones supplied as array" do
      phones = Array.new(3) { random_phone }
      TextMagic::API::Executor.expects(:execute).with("check_number", @username, @password, :phone => phones.join(","))
      @api.check_number(phones)
    end

    should "join phones supplied as arguments" do
      phones = Array.new(3) { random_phone }
      TextMagic::API::Executor.expects(:execute).with("check_number", @username, @password, :phone => phones.join(","))
      @api.check_number(*phones)
    end

    should "not call execute and should raise an exception if no phones are specified" do
      TextMagic::API::Executor.expects(:execute).never
      assert_raises(TextMagic::API::Error){ @api.check_number}
    end

    should "call Response.check_number method to process the response hash (single phone)" do
      TextMagic::API::Response.expects(:check_number).with(@response, true).returns(@processed_response)
      assert_equal(@api.check_number(random_string), @processed_response)
    end

    should "call Response.check_number method to process the response hash (mulitple phones)" do
      TextMagic::API::Response.expects(:check_number).with(@response, false).returns(@processed_response).twice
      assert_equal(@api.check_number([random_string]), @processed_response)
      assert_equal(@api.check_number(random_string, random_string), @processed_response)
    end
  end
end
