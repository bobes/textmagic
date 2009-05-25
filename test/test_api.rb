require 'test_helper'

class APITest < Test::Unit::TestCase

  context 'Initialization' do

    should 'require username and password' do
      lambda { TextMagic::API.new }.should raise_error(ArgumentError)
      TextMagic::API.new(random_string, random_string)
    end
  end

  context 'Account command' do

    setup do
      @username, @password = random_string, random_string
      @api = TextMagic::API.new(@username, @password)
    end

    should 'call Executor execute with correct arguments' do
      TextMagic::API::Executor.expects(:execute).with('account', @username, @password).returns({})
      @api.account
    end

    should 'return a hash with account balance value' do
      TextMagic::API::Executor.expects(:execute).returns({ 'balance' => '3.14' })
      response = @api.account
      response.class.should == Hash
      response.balance.should == 3.14
    end
  end

  context 'Send command' do

    setup do
      @username, @password = random_string, random_string
      @text, @phone = random_string, random_phone
      @api = TextMagic::API.new(@username, @password)
      TextMagic::API::Executor.stubs(:execute)
    end

    should 'call Executor execute with correct arguments' do
      TextMagic::API::Executor.expects(:execute).with('send', @username, @password, :text => @text, :phone => @phone, :unicode => 0)
      @api.send(@text, @phone)
    end

    should 'join multiple phone numbers supplied as an array' do
      phones = Array.new(3) { random_phone }
      TextMagic::API::Executor.expects(:execute).with('send', @username, @password, :text => @text, :phone => phones.join(','), :unicode => 0)
      @api.send(@text, phones)
    end

    should 'join multiple phone numbers supplied as arguments' do
      phones = Array.new(3) { random_phone }
      TextMagic::API::Executor.expects(:execute).with('send', @username, @password, :text => @text, :phone => phones.join(','), :unicode => 0)
      @api.send(@text, *phones)
    end

    should 'replace true with 1 for unicode' do
      TextMagic::API::Executor.expects(:execute).with('send', @username, @password, :text => @text, :phone => @phone, :unicode => 1)
      @api.send(@text, @phone, :unicode => true)
    end

    should 'set unicode value to 0 if it is not set to by user and text contains only characters from GSM 03.38 charset' do
      TextMagic::API::Executor.expects(:execute).with('send', @username, @password, :text => @text, :phone => @phone, :unicode => 0).times(2)
      @api.send(@text, @phone)
      @api.send(@text, @phone, :unicode => false)
    end

    should 'raise an error if unicode is set to 0 and text contains characters outside of GSM 03.38 charset' do
      text = 'Вильма Привет'
      lambda { @api.send(text, @phone, :unicode => false) }.should raise_error(TextMagic::API::Error)
    end

    should 'raise an error if unicode value is not valid' do
      lambda { @api.send(@text, @phone, :unicode => 2 + rand(10)) }.should raise_error(TextMagic::API::Error)
      lambda { @api.send(@text, @phone, :unicode => random_string) }.should raise_error(TextMagic::API::Error)
    end

    should 'raise an error if no phone numbers are specified' do
      lambda { @api.send(@text) }.should raise_error(TextMagic::API::Error)
      lambda { @api.send(@text, []) }.should raise_error(TextMagic::API::Error)
    end

    should 'raise an error if format of any of the specified phone numbers is invalid' do
      TextMagic::API.expects(:validate_phones).returns(false)
      lambda { @api.send(@text, random_string) }.should raise_error(TextMagic::API::Error)
    end

    should 'raise an error if text is empty' do
      lambda { @api.send('', @phone) }.should raise_error(TextMagic::API::Error)
    end

    should 'raise an error if text is too long' do
      TextMagic::API.expects(:validate_text_length).returns(false)
      lambda { @api.send(@text, @phone) }.should raise_error(TextMagic::API::Error)
    end

    should 'return a hash with message_id, sent_text and parts_count' do
      message_id = random_string
      TextMagic::API::Executor.expects(:execute).returns({ 'message_id' => { message_id => @phone }, 'sent_text' => @text, 'parts_count' => 1 })
      response = @api.send(@text, @phone)
      response.class.should == Hash
      response.message_id.should == { @phone => message_id }
      response.sent_text.should == @text
      response.parts_count.should == 1
    end
  end

  context 'Message status command' do

    setup do
      @username, @password = random_string, random_string
      @api = TextMagic::API.new(@username, @password)
    end

    should 'call Executor execute with correct arguments' do
      id = random_string
      TextMagic::API::Executor.expects(:execute).with('message_status', @username, @password, :ids => id)
      @api.message_status(id)
    end

    should 'join ids supplied as array' do
      ids = Array.new(3) { random_string }
      TextMagic::API::Executor.expects(:execute).with('message_status', @username, @password, :ids => ids.join(','))
      @api.message_status(ids)
    end

    should 'join ids supplied as arguments' do
      ids = Array.new(3) { random_string }
      TextMagic::API::Executor.expects(:execute).with('message_status', @username, @password, :ids => ids.join(','))
      @api.message_status(*ids)
    end

    should 'not call execute and should raise an exception if no ids are specified' do
      TextMagic::API::Executor.expects(:execute).never
      lambda { @api.message_status }.should raise_error(TextMagic::API::Error)
    end

    should 'return a hash with message ids as keys' do
      TextMagic::API::Executor.expects(:execute).returns({ '8659912' => {} })
      response = @api.message_status(random_string)
      response['8659912'].should == {}
    end
  end

  context 'Receive command' do

    setup do
      @username, @password = random_string, random_string
      @api = TextMagic::API.new(@username, @password)
    end

    should 'call Executor execute with correct arguments' do
      TextMagic::API::Executor.expects(:execute).with('receive', @username, @password, :last_retrieved_id => nil)
      @api.receive
    end

    should 'accept last_retrieved_id optional value' do
      last_retrieved_id = rand(1e10)
      TextMagic::API::Executor.expects(:execute).with('receive', @username, @password, :last_retrieved_id => last_retrieved_id)
      @api.receive(last_retrieved_id)
    end

    should 'return a hash with messages and number of unread messages' do
      TextMagic::API::Executor.expects(:execute).returns({ 'messages' => [], 'unread' => 0 })
      response = @api.receive
      response['unread'].should == 0
      response['messages'].should == []
    end
  end

  context 'Delete reply command' do

    setup do
      @username, @password = random_string, random_string
      @api = TextMagic::API.new(@username, @password)
    end

    should 'call Executor execute with correct arguments' do
      id = random_string
      TextMagic::API::Executor.expects(:execute).with('delete_reply', @username, @password, :ids => id)
      @api.delete_reply(id)
    end

    should 'join ids supplied as array' do
      ids = Array.new(3) { random_string }
      TextMagic::API::Executor.expects(:execute).with('delete_reply', @username, @password, :ids => ids.join(','))
      @api.delete_reply(ids)
    end

    should 'join ids supplied as arguments' do
      ids = Array.new(3) { random_string }
      TextMagic::API::Executor.expects(:execute).with('delete_reply', @username, @password, :ids => ids.join(','))
      @api.delete_reply(*ids)
    end

    should 'not call execute and should raise an exception if no ids are specified' do
      TextMagic::API::Executor.expects(:execute).never
      lambda { @api.delete_reply }.should raise_error(TextMagic::API::Error)
    end

    should 'return a hash with deleted ids' do
      ids = Array.new(3) { random_string }
      TextMagic::API::Executor.expects(:execute).returns({ 'deleted' => ids })
      response = @api.delete_reply(ids)
      response.deleted.should == ids
    end
  end
end

__END__

Example responses

account:
{"balance":"100"}

send:
{"message_id":{"1234567":"444444123456"},"sent_text":"test","parts_count":1}

message_status:
{"8659912":{"text":"test","status":"d","created_time":"1242979818","reply_number":"447624800500","completed_time":null,"credits_cost":"0.5"},"8659914":{"text":"test","status":"d","created_time":"1242979839","reply_number":"447624800500","completed_time":null,"credits_cost":"0.5"}}

receive (empty):
{"messages":[],"unread":0}

empty message:
{"error_code":1,"error_message":"Messages text is empty"}

insufficient parameters:
{"error_code":4,"error_message":"Insufficient parameters"}

invalid credentials:
{"error_code":5,"error_message":"Invalid username & password combination"}

invalid phone number format:
{"error_code":9,"error_message":"Wrong phone number format"}

invalid message_id:
{"error_code":14,"error_message":"Message with id 8659913 does not exist"}
