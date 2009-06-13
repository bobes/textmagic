require 'test_helper'

class ResponseTest < Test::Unit::TestCase

  context 'Response to account command' do

    setup do
      @balance = 0.1 * rand(1e4)
      @hash = { 'balance' => @balance.to_s }
      @response = TextMagic::API::Response.account(@hash)
    end

    should 'be an OpenStruct instance' do
      @response.class.should == OpenStruct
    end

    should 'have balance' do
      @response.balance.should be_close(@balance, 1e-10)
    end
  end

  context 'Response to send command with single phone number' do

    setup do
      @message_id, @phone = random_string, random_phone
      @text = random_string
      @parts_count = 1 + rand(3)
      @hash = { 'message_id' => { @message_id => @phone }, 'sent_text' => @text, 'parts_count' => @parts_count }
      @response = TextMagic::API::Response.send(@hash, true)
    end

    should 'equal to the message_id' do
      @response.should == @message_id
    end

    should 'have sent_text' do
      @response.sent_text.should == @text
    end

    should 'have parts_count' do
      @response.parts_count.should == @parts_count
    end
  end

  context 'Response to send command with multiple phone numbers' do

    setup do
      @message_id1, @phone1 = random_string, random_phone
      @message_id2, @phone2 = random_string, random_phone
      @text = random_string
      @parts_count = 1 + rand(3)
      @hash = { 'message_id' => { @message_id1 => @phone1, @message_id2 => @phone2 }, 'sent_text' => @text, 'parts_count' => @parts_count }
      @response = TextMagic::API::Response.send(@hash, false)
    end

    should 'be a hash' do
      @response.class.should == Hash
    end

    should 'have phone numbers as keys' do
      @response.keys.sort.should == [@phone1, @phone2].sort
    end

    should 'have message ids as values' do
      @response[@phone1].should == @message_id1
      @response[@phone2].should == @message_id2
    end

    should 'have sent_text' do
      @response.sent_text.should == @text
    end

    should 'have parts_count' do
      @response.parts_count.should == @parts_count
    end
  end

  context 'Response to message_status command with single id' do

    setup do
      @text = random_string
      @status = random_string
      @reply_number = random_phone
      @created_time = (Time.now - 30).to_i
      @completed_time = (Time.now - 20).to_i
      @credits_cost = 0.01 * rand(300)
      @hash = {
        '141421' => {
          'text' => @text,
          'status' => @status,
          'created_time' => @created_time.to_s,
          'reply_number' => @reply_number,
          'completed_time' => @completed_time.to_s,
          'credits_cost' => @credits_cost
        }
      }
      @response = TextMagic::API::Response.message_status(@hash, true)
    end

    should 'equal to the message status' do
      @response.should == @status
    end

    should 'have text' do
      @response.text.should == @text
    end

    should 'have created_time' do
      @response.created_time.should == Time.at(@created_time)
    end

    should 'have completed_time' do
      @response.completed_time.should == Time.at(@completed_time)
    end

    should 'have reply_number' do
      @response.reply_number.should == @reply_number
    end

    should 'have credits_cost' do
      @response.credits_cost.should be_close(@credits_cost, 1e-10)
    end
  end

  context 'Response to message_status command with multiple ids' do

    setup do
      @text = random_string
      @status = random_string
      @reply_number = random_phone
      @created_time = (Time.now - 30).to_i
      @completed_time = (Time.now - 20).to_i
      @credits_cost = 0.01 * rand(300)
      @hash = {
        '141421' => {
          'text' => @text,
          'status' => @status,
          'created_time' => @created_time,
          'reply_number' => @reply_number,
          'completed_time' => @completed_time,
          'credits_cost' => @credits_cost
        }
      }
      @response = TextMagic::API::Response.message_status(@hash, false)
    end

    should 'be a hash' do
      @response.class.should == Hash
    end

    should 'have message_ids as keys' do
      @response.keys.should == ['141421']
    end

    should 'contain statuses' do
      @response.values.first.should == @status
    end

    should 'have text for all statuses' do
      @response.values.first.text.should == @text
    end

    should 'have created_time for all statuses' do
      @response.values.first.created_time.should == Time.at(@created_time)
    end

    should 'have completed_time for all statuses' do
      @response.values.first.completed_time.should == Time.at(@completed_time)
    end

    should 'have reply_number for all statuses' do
      @response.values.first.reply_number.should == @reply_number
    end

    should 'have credits_cost for all statuses' do
      @response.values.first.credits_cost.should be_close(@credits_cost, 1e-10)
    end
  end

  context 'Response to receive command' do

    setup do
      @timestamp = (Time.now - 30).to_i
      @text, @phone, @message_id = random_string, random_phone, random_string
      @message = {
        'timestamp' => @timestamp,
        'from' => @phone,
        'text' => @text,
        'message_id' => @message_id
      }
      @unread = rand(1e4)
      @hash = { 'unread' => @unread, 'messages' => [@message] }
      @response = TextMagic::API::Response.receive(@hash)
    end

    should 'have unread' do
      @response.unread.should == @unread
    end

    should 'be an array' do
      @response.class.should == Array
    end

    should 'contain strings with phones numbers and texts' do
      @response.first.should == "#{@phone}: #{@text}"
    end

    should 'have timestamp for all messages' do
      @response.first.timestamp.should == Time.at(@timestamp)
    end

    should 'have from for all messages' do
      @response.first.from.should == @phone
    end

    should 'have text for all messages' do
      @response.first.text.should == @text
    end

    should 'have message_id for all messages' do
      @response.first.message_id.should == @message_id
    end
  end

  context 'Response to check_number command with single phone' do

    setup do
      @phone = random_phone
      @price = rand
      @country = random_string
      @hash = {
        @phone => {
          'price' => @price,
          'country' => @country
        }
      }
      @response = TextMagic::API::Response.check_number(@hash, true)
    end

    should 'be an OpenStruct instance' do
      @response.class.should == OpenStruct
    end

    should 'have price' do
      @response.price.should be_close(@price, 1e-10)
    end

    should 'have country' do
      @response.country.should == @country
    end
  end

  context 'Response to check_number command with multiple phones' do

    setup do
      @phone = random_phone
      @price = rand
      @country = random_string
      @hash = {
        @phone => {
          'price' => @price,
          'country' => @country
        }
      }
      @response = TextMagic::API::Response.check_number(@hash, false)
    end

    should 'be a hash' do
      @response.class.should == Hash
    end

    should 'have phones as keys' do
      @response.keys.should == [@phone]
    end

    should 'contain OpenStruct instances' do
      @response.values.first.class.should == OpenStruct
    end

    should 'have price for all phones' do
      @response.values.first.price.should be_close(@price, 1e-10)
    end

    should 'have country for all phones' do
      @response.values.first.country.should == @country
    end
  end
end
