require 'test_helper'

class ResponseTest < Test::Unit::TestCase

  context 'Account response' do

    setup do
      @balance = 0.1 * rand(1e4)
      @response = { 'balance' => @balance.to_s }
      @response.extend TextMagic::API::Response::Account
    end

    should 'allow access to balance' do
      @response.balance.should be_close(@balance, 1e-10)
    end
  end

  context 'Send response' do

    setup do
      @message_id = {
        '141421' => '999314159265',
        '173205' => '999271828182'
      }
      @text = random_string
      @parts_count = rand(10)
      @response = {
        'message_id' => @message_id,
        'sent_text' => @text,
        'parts_count' => @parts_count
      }
      @response.extend TextMagic::API::Response::Send
    end

    should 'allow access to message_ids array' do
      @response.message_ids.should == ['141421', '173205']
    end

    should 'allow access to message_id for a given phone number' do
      @response['999314159265'].should == '141421'
      @response['999271828182'].should == '173205'
    end

    should 'allow access to sent_text' do
      @response.sent_text.should == @text
    end

    should 'allow access to parts_count' do
      @response.parts_count.should == @parts_count
    end
  end

  context 'MessageStatus response' do

    setup do
      @text = random_string
      @reply_number = random_phone
      @created_time = (Time.now - 30).to_i
      @completed_time = (Time.now - 20).to_i
      @credits_cost = 0.01 * rand(300)
      @response = {
        '141421' => {
          'text' => @text,
          'status' => 'd',
          'created_time' => @created_time,
          'reply_number' => @reply_number,
          'completed_time' => @completed_time,
          'credits_cost' => @credits_cost
        },
        '173205' => {
          'text' => 'test',
          'status' => 'r',
          'created_time' => '1242979839',
          'reply_number' => '447624800500',
          'completed_time' => nil,
          'credits_cost' => 0.5
        }
      }
      @response.extend TextMagic::API::Response::MessageStatus
    end

    should 'allow access to text for all statuses' do
      @response['141421'].text.should == @text
      @response['173205'].text.should == 'test'
    end

    should 'allow access to status for a given message_id' do
      @response['141421'].status.should == 'd'
      @response['173205'].status.should == 'r'
    end

    should 'allow access to reply_number for a given message_id' do
      @response['141421'].reply_number.should == @reply_number
      @response['173205'].reply_number.should == '447624800500'
    end

    should 'allow access to created_time for a given message_id' do
      @response['141421'].created_time.should == Time.at(@created_time)
      @response['173205'].created_time.should == Time.at(1242979839)
    end

    should 'allow access to completed_time for a given message_id' do
      @response['141421'].completed_time.should == Time.at(@completed_time)
      @response['173205'].completed_time.should == nil
    end

    should 'allow access to credits_cost for a given message_id' do
      @response['141421'].credits_cost.should be_close(@credits_cost, 1e-10)
      @response['173205'].credits_cost.should be_close(0.5, 1e-10)
    end
  end

  context 'Receive response' do

    setup do
      @timestamp = (Time.now - 30).to_i
      @message1 = {
        'timestamp' => @timestamp,
        'from' => '999314159265',
        'text' => 'Hi Fred',
        'message_id' => '141421'
      }
      @message2 = {
        'timestamp' => 1243244148,
        'from' => '999271828182',
        'text' => 'Hello buddy',
        'message_id' => '173205'
      }
      @messages = [@message1, @message2]
      @unread = rand(1e4)
      @response = { 'unread' => @unread, 'messages' => @messages }
      @response.extend TextMagic::API::Response::Receive
    end

    should 'allow access to unread' do
      @response.unread.should == @unread
    end

    should 'allow access to messages array' do
      @response.messages.should == @messages
    end

    should 'allow access to message_ids array' do
      @response.message_ids.should == ['141421', '173205']
    end

    should 'allow access to message_id for all messages' do
      @response.messages.first.message_id.should == '141421'
    end

    should 'allow access to timestamp for all messages' do
      @response.messages.first.timestamp.should == Time.at(@timestamp)
    end

    should 'allow access to from for all messages' do
      @response.messages.first.from.should == '999314159265'
    end

    should 'allow access to text for all messages' do
      @response.messages.first.text.should == 'Hi Fred'
    end
  end

  context 'DeleteReply response' do

    setup do
      @ids = ['141421', '1780826']
      @response = { 'deleted' => @ids }
      @response.extend TextMagic::API::Response::DeleteReply
    end

    should 'allow access to deleted' do
      @response.deleted.should == @ids
    end
  end
end
