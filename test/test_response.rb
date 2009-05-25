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
        '1414213' => '314159265358',
        '1732050' => '271828182845'
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

    should 'allow access to inverted message_id hash' do
      @response.message_id.should == @message_id.invert
    end

    should 'allow access to message_ids array' do
      @response.message_ids.should == ['1414213', '1732050']
    end

    should 'allow access to message_id for a given phone number' do
      @response.message_id('314159265358').should == '1414213'
      @response.message_id('271828182845').should == '1732050'
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
        '8659912' => {
          'text' => @text,
          'status' => 'd',
          'created_time' => @created_time,
          'reply_number' => @reply_number,
          'completed_time' => @completed_time,
          'credits_cost' => @credits_cost
        },
        '8659914' => {
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

    should 'allow access to text for a given message_id' do
      @response.text('8659912').should == @text
      @response.text('8659914').should == 'test'
    end

    should 'allow access to status for a given message_id' do
      @response.status('8659912').should == 'd'
      @response.status('8659914').should == 'r'
    end

    should 'allow access to reply_number for a given message_id' do
      @response.reply_number('8659912').should == @reply_number
      @response.reply_number('8659914').should == '447624800500'
    end

    should 'allow access to created_time for a given message_id' do
      @response.created_time('8659912').should == Time.at(@created_time)
      @response.created_time('8659914').should == Time.at(1242979839)
    end

    should 'allow access to completed_time for a given message_id' do
      @response.completed_time('8659912').should == Time.at(@completed_time)
      @response.completed_time('8659914').should == nil
    end

    should 'allow access to credits_cost for a given message_id' do
      @response.credits_cost('8659912').should be_close(@credits_cost, 1e-10)
      @response.credits_cost('8659914').should be_close(0.5, 1e-10)
    end
  end

  context 'Receive response' do

    setup do
      @timestamp = (Time.now - 30).to_i
      @message1 = {
        'timestamp' => @timestamp,
        'from' => '314159265358',
        'text' => 'Hi Fred',
        'message_id' => '1780826'
      }
      @message2 = {
        'timestamp' => 1243244148,
        'from' => '271828182845',
        'text' => 'Hello buddy',
        'message_id' => '1782274'
      }
      @messages = [@message1, @message2]
      @unread = rand(1e4)
      @response = { 'unread' => @unread, 'messages' => @messages }
      @response.extend TextMagic::API::Response::Receive
    end

    should 'allow access to unread' do
      @response.unread.should == @unread
    end

    should 'allow access to messages hash' do
      @response.messages.should == { '1780826' => @message1, '1782274' => @message2 }
    end

    should 'allow access to message ids' do
      @response.message_ids.should == ['1780826', '1782274']
    end

    should 'allow access to message hash for a given message id' do
      @response.message('1780826').should == @message1
    end

    should 'allow access to timestamp for a given message id' do
      @response.timestamp('1780826').should == Time.at(@timestamp)
    end

    should 'allow access to from for a given message id' do
      @response.from('1780826').should == '314159265358'
    end

    should 'allow access to text for a given message id' do
      @response.text('1780826').should == 'Hi Fred'
    end
  end

  context 'DeleteReply response' do

    setup do
      @ids = ['1414213', '1780826']
      @response = { 'deleted' => @ids }
      @response.extend TextMagic::API::Response::DeleteReply
    end

    should 'allow access to deleted' do
      @response.deleted.should == @ids
    end
  end
end
