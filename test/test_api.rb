# encoding: utf-8

require "test_helper"

describe "API" do

  describe "Initialization" do

    it " should require username and password" do
      assert_raises ArgumentError do
        TextMagic::API.new
      end
      TextMagic::API.new(random_string, random_string)
    end
  end

  describe "Account command" do

    before do
      @username, @password = random_string, random_string
      @api = TextMagic::API.new(@username, @password)
      @response = random_string
      @processed_response = random_string
      TextMagic::API::Executor.stubs(:execute).returns(@response)
      TextMagic::API::Response.stubs(:account).returns(@processed_response)
    end

    it "should call Executor execute with correct arguments" do
      TextMagic::API::Executor.expects(:execute).with("account", @username, @password).returns(@response)
      @api.account
    end

    it "should call Response.account method to process the response hash" do
      processed_response = rand
      TextMagic::API::Response.expects(:account).with(@response).returns(processed_response)
      assert_equal processed_response, @api.account
    end
  end

  describe "Send command" do

    before do
      @username, @password = random_string, random_string
      @text, @phone = random_string, random_phone
      @api = TextMagic::API.new(@username, @password)
      @response = random_string
      @processed_response = random_string
      TextMagic::API::Executor.stubs(:execute).returns(@response)
      TextMagic::API::Response.stubs(:send).returns(@processed_response)
    end

    it "should call Executor execute with correct arguments" do
      TextMagic::API::Executor.expects(:execute).with("send", @username, @password, :text => @text, :phone => @phone, :unicode => 0).returns(@response)
      @api.send(@text, @phone)
    end

    it "should join multiple phone numbers supplied as an array" do
      phones = Array.new(3) { random_phone }
      TextMagic::API::Executor.expects(:execute).with("send", @username, @password, :text => @text, :phone => phones.join(","), :unicode => 0).returns(@response)
      @api.send(@text, phones)
    end

    it "should join multiple phone numbers supplied as arguments" do
      phones = Array.new(3) { random_phone }
      TextMagic::API::Executor.expects(:execute).with("send", @username, @password, :text => @text, :phone => phones.join(","), :unicode => 0).returns(@response)
      @api.send(@text, *phones)
    end

    it "should replace true with 1 for unicode" do
      TextMagic::API::Executor.expects(:execute).with("send", @username, @password, :text => @text, :phone => @phone, :unicode => 1).returns(@response)
      @api.send(@text, @phone, :unicode => true)
    end

    it "should set unicode value to 0 if it is not set to by user and text contains only characters from GSM 03.38 charset" do
      TextMagic::API::Executor.expects(:execute).with("send", @username, @password, :text => @text, :phone => @phone, :unicode => 0).returns(@response).times(2)
      @api.send(@text, @phone)
      @api.send(@text, @phone, :unicode => false)
    end

    it "should raise an error if unicode is set to 0 and text contains characters outside of GSM 03.38 charset" do
      text = "Вильма Привет"
      assert_raises TextMagic::API::Error do
        @api.send(text, @phone, :unicode => false)
      end
    end

    it "should raise an error if unicode value is not valid" do
      assert_raises TextMagic::API::Error do
        @api.send(@text, @phone, :unicode => 2 + rand(10))
      end
      assert_raises TextMagic::API::Error do
        @api.send(@text, @phone, :unicode => random_string)
      end
    end

    it "should raise an error if no phone numbers are specified" do
      assert_raises TextMagic::API::Error do
        @api.send(@text)
      end
      assert_raises TextMagic::API::Error do
        @api.send(@text, [])
      end
    end

    it "should raise an error if format of any of the specified phone numbers is invalid" do
      TextMagic::API.expects(:validate_phones).returns(false)
      assert_raises TextMagic::API::Error do
        @api.send(@text, random_string)
      end
    end

    it "should raise an error if text is nil" do
      assert_raises TextMagic::API::Error do
        @api.send(nil, @phone)
      end
    end

    it "should raise an error if text is too long" do
      TextMagic::API.expects(:validate_text_length).returns(false)
      assert_raises TextMagic::API::Error do
        @api.send(@text, @phone)
      end
    end

    it "should support send_time option" do
      time = Time.now + rand
      TextMagic::API::Executor.expects(:execute).with("send", @username, @password, :text => @text, :phone => @phone, :unicode => 0, :send_time => time.to_i).returns(@response)
      @api.send(@text, @phone, :send_time => time.to_i)
    end

    it "should convert send_time to Fixnum" do
      time = Time.now + rand
      TextMagic::API::Executor.expects(:execute).with("send", @username, @password, :text => @text, :phone => @phone, :unicode => 0, :send_time => time.to_i).returns(@response)
      @api.send(@text, @phone, :send_time => time)
    end

    it "should call Response.send method to process the response hash (single phone)" do
      processed_response = rand
      TextMagic::API::Response.expects(:send).with(@response, true).returns(processed_response)
      assert_equal processed_response, @api.send(@text, random_phone)
    end

    it "should call Response.send method to process the response hash (multiple phones)" do
      processed_response = rand
      TextMagic::API::Response.expects(:send).with(@response, false).returns(processed_response).twice
      assert_equal processed_response, @api.send(@text, [random_phone])
      assert_equal processed_response, @api.send(@text, random_phone, random_phone)
    end
  end

  describe "Message status command" do

    before do
      @username, @password = random_string, random_string
      @api = TextMagic::API.new(@username, @password)
      @response = random_string
      @processed_response = random_string
      TextMagic::API::Executor.stubs(:execute).returns(@response)
      TextMagic::API::Response.stubs(:message_status).returns(@processed_response)
    end

    it "should call Executor execute with correct arguments" do
      id = random_string
      TextMagic::API::Executor.expects(:execute).with("message_status", @username, @password, :ids => id).returns(@response)
      @api.message_status(id)
    end

    it "should join ids supplied as array" do
      ids = Array.new(3) { random_string }
      TextMagic::API::Executor.expects(:execute).with("message_status", @username, @password, :ids => ids.join(","))
      @api.message_status(ids)
    end

    it "should join ids supplied as arguments" do
      ids = Array.new(3) { random_string }
      TextMagic::API::Executor.expects(:execute).with("message_status", @username, @password, :ids => ids.join(","))
      @api.message_status(*ids)
    end

    it "should not call execute and should raise an exception if no ids are specified" do
      TextMagic::API::Executor.expects(:execute).never
      assert_raises TextMagic::API::Error do
        @api.message_status
      end
    end

    it "should call Response.message_status method to process the response hash (single id)" do
      TextMagic::API::Response.expects(:message_status).with(@response, true).returns(@processed_response)
      assert_equal @processed_response, @api.message_status(random_string)
    end

    it "should call Response.message_status method to process the response hash (multiple ids)" do
      TextMagic::API::Response.expects(:message_status).with(@response, false).returns(@processed_response).twice
      assert_equal @processed_response, @api.message_status([random_string])
      assert_equal @processed_response, @api.message_status(random_string, random_string)
    end
  end

  describe "Receive command" do

    before do
      @username, @password = random_string, random_string
      @api = TextMagic::API.new(@username, @password)
      @response = random_string
      @processed_response = random_string
      TextMagic::API::Executor.stubs(:execute).returns(@response)
      TextMagic::API::Response.stubs(:receive).returns(@processed_response)
    end

    it "should call Executor execute with correct arguments" do
      TextMagic::API::Executor.expects(:execute).with("receive", @username, @password, :last_retrieved_id => nil)
      @api.receive
    end

    it "should accept last_retrieved_id optional value" do
      last_retrieved_id = rand(1e10)
      TextMagic::API::Executor.expects(:execute).with("receive", @username, @password, :last_retrieved_id => last_retrieved_id)
      @api.receive(last_retrieved_id)
    end

    it "should call Response.receive method to process the response hash" do
      TextMagic::API::Response.expects(:receive).with(@response).returns(@processed_response)
      assert_equal @processed_response, @api.receive(random_string)
    end
  end

  describe "Delete reply command" do

    before do
      @username, @password = random_string, random_string
      @api = TextMagic::API.new(@username, @password)
      @response = random_string
      @processed_response = random_string
      TextMagic::API::Executor.stubs(:execute).returns(@response)
      TextMagic::API::Response.stubs(:delete_reply).returns(@processed_response)
    end

    it "should call Executor execute with correct arguments" do
      id = random_string
      TextMagic::API::Executor.expects(:execute).with("delete_reply", @username, @password, :ids => id)
      @api.delete_reply(id)
    end

    it "should join ids supplied as array" do
      ids = Array.new(3) { random_string }
      TextMagic::API::Executor.expects(:execute).with("delete_reply", @username, @password, :ids => ids.join(","))
      @api.delete_reply(ids)
    end

    it "should join ids supplied as arguments" do
      ids = Array.new(3) { random_string }
      TextMagic::API::Executor.expects(:execute).with("delete_reply", @username, @password, :ids => ids.join(","))
      @api.delete_reply(*ids)
    end

    it "should not call execute and should raise an exception if no ids are specified" do
      TextMagic::API::Executor.expects(:execute).never
      assert_raises TextMagic::API::Error do
        @api.delete_reply
      end
    end

    it "should return true" do
      assert_equal true, @api.delete_reply(random_string)
    end
  end

  describe "Check number command" do

    before do
      @username, @password = random_string, random_string
      @api = TextMagic::API.new(@username, @password)
      @response = random_string
      @processed_response = random_string
      TextMagic::API::Executor.stubs(:execute).returns(@response)
      TextMagic::API::Response.stubs(:check_number).returns(@processed_response)
    end

    it "should call Executor execute with correct arguments" do
      phone = random_phone
      TextMagic::API::Executor.expects(:execute).with("check_number", @username, @password, :phone => phone)
      @api.check_number(phone)
    end

    it "should join phones supplied as array" do
      phones = Array.new(3) { random_phone }
      TextMagic::API::Executor.expects(:execute).with("check_number", @username, @password, :phone => phones.join(","))
      @api.check_number(phones)
    end

    it "should join phones supplied as arguments" do
      phones = Array.new(3) { random_phone }
      TextMagic::API::Executor.expects(:execute).with("check_number", @username, @password, :phone => phones.join(","))
      @api.check_number(*phones)
    end

    it "should not call execute and should raise an exception if no phones are specified" do
      TextMagic::API::Executor.expects(:execute).never
      assert_raises TextMagic::API::Error do
        @api.check_number
      end
    end

    it "should call Response.check_number method to process the response hash (single phone)" do
      TextMagic::API::Response.expects(:check_number).with(@response, true).returns(@processed_response)
      assert_equal @processed_response, @api.check_number(random_string)
    end

    it "should call Response.check_number method to process the response hash (mulitple phones)" do
      TextMagic::API::Response.expects(:check_number).with(@response, false).returns(@processed_response).twice
      assert_equal @processed_response, @api.check_number([random_string])
      assert_equal @processed_response, @api.check_number(random_string, random_string)
    end
  end
end
