require "test_helper"

class ResponseTest < Minitest::Test

  context "Response to account command" do

    setup do
      @balance = 0.1 * rand(1e4)
      @hash = { "balance" => @balance.to_s }
      @response = TextMagic::API::Response.account(@hash)
    end

    should "be an OpenStruct instance" do
      assert_equal(@response.class, OpenStruct)
    end

    should "have balance" do
      assert_in_delta @response.balance, (@balance), 1e-10
    end
  end

  context "Response to send command with single phone number" do

    setup do
      @message_id, @phone = random_string, random_phone
      @text = random_string
      @parts_count = 1 + rand(3)
      @hash = { "message_id" => { @message_id => @phone }, "sent_text" => @text, "parts_count" => @parts_count }
      @response = TextMagic::API::Response.send(@hash, true)
    end

    should "equal to the message_id" do
      assert_equal(@response, @message_id)
    end

    should "have sent_text" do
      assert_equal(@response.sent_text, @text)
    end

    should "have parts_count" do
      assert_equal(@response.parts_count, @parts_count)
    end
  end

  context "Response to send command with multiple phone numbers" do

    setup do
      @message_id1, @phone1 = random_string, random_phone
      @message_id2, @phone2 = random_string, random_phone
      @text = random_string
      @parts_count = 1 + rand(3)
      @hash = { "message_id" => { @message_id1 => @phone1, @message_id2 => @phone2 }, "sent_text" => @text, "parts_count" => @parts_count }
      @response = TextMagic::API::Response.send(@hash, false)
    end

    should "be a hash" do
      assert_equal(@response.class, Hash)
    end

    should "have phone numbers as keys" do
      assert_equal(@response.keys.sort, [@phone1, @phone2].sort)
    end

    should "have message ids as values" do
      assert_equal(@response[@phone1], @message_id1)
      assert_equal(@response[@phone2], @message_id2)
    end

    should "have sent_text" do
      assert_equal(@response.sent_text, @text)
    end

    should "have parts_count" do
      assert_equal( @response.parts_count, @parts_count)
    end
  end

  context "Response to message_status command with single id" do

    setup do
      @text = random_string
      @status = random_string
      @reply_number = random_phone
      @created_time = (Time.now - 30).to_i
      @completed_time = (Time.now - 20).to_i
      @credits_cost = 0.01 * rand(300)
      @hash = {
        "141421" => {
          "text" => @text,
          "status" => @status,
          "created_time" => @created_time.to_s,
          "reply_number" => @reply_number,
          "completed_time" => @completed_time.to_s,
          "credits_cost" => @credits_cost
        }
      }
      @response = TextMagic::API::Response.message_status(@hash, true)
    end

    should "equal to the message status" do
      assert_equal(@response, @status)
    end

    should "have text" do
      assert_equal(@response.text, @text)
    end

    should "have created_time" do
      assert_equal(@response.created_time, Time.at(@created_time))
    end

    should "have completed_time" do
      assert_equal(@response.completed_time, Time.at(@completed_time))
    end

    should "have reply_number" do
      assert_equal(@response.reply_number, @reply_number)
    end

    should "have credits_cost" do
      assert_in_delta @response.credits_cost, (@credits_cost), 1e-10
    end

    should "have status" do
      assert_equal(@response.status, @status)
    end
  end

  context "Response to message_status command with multiple ids" do

    setup do
      @text = random_string
      @status = random_string
      @reply_number = random_phone
      @created_time = (Time.now - 30).to_i
      @completed_time = (Time.now - 20).to_i
      @credits_cost = 0.01 * rand(300)
      @hash = {
        "141421" => {
          "text" => @text,
          "status" => @status,
          "created_time" => @created_time,
          "reply_number" => @reply_number,
          "completed_time" => @completed_time,
          "credits_cost" => @credits_cost
        }
      }
      @response = TextMagic::API::Response.message_status(@hash, false)
    end

    should "be a hash" do
      assert_equal(@response.class, Hash)
    end

    should "have message_ids as keys" do
      assert_equal(@response.keys, ["141421"])
    end

    should "contain statuses" do
      assert_equal(@response.values.first, @status)
    end

    should "have text for all statuses" do
      assert_equal(@response.values.first.text, @text)
    end

    should "have created_time for all statuses" do
      assert_equal(@response.values.first.created_time, Time.at(@created_time))
    end

    should "have completed_time for all statuses" do
      assert_equal(@response.values.first.completed_time, Time.at(@completed_time))
    end

    should "have reply_number for all statuses" do
      assert_equal(@response.values.first.reply_number, @reply_number)
    end

    should "have status for all statuses" do
      assert_equal(@response.values.first.status, @status)
    end

    should "have credits_cost for all statuses" do
      assert_in_delta @response.values.first.credits_cost, (@credits_cost), 1e-10
    end
  end

  context "Response to receive command" do

    setup do
      @timestamp = (Time.now - 30).to_i
      @text, @phone, @message_id = random_string, random_phone, random_string
      @message = {
        "timestamp" => @timestamp,
        "from" => @phone,
        "text" => @text,
        "message_id" => @message_id
      }
      @unread = rand(1e4)
      @hash = { "unread" => @unread, "messages" => [@message] }
      @response = TextMagic::API::Response.receive(@hash)
    end

    should "have unread" do
      assert_equal(@response.unread, @unread)
    end

    should "be an array" do
      assert_equal(@response.class, Array)
    end

    should "contain strings with phones numbers and texts" do
      assert_equal(@response.first, "#{@phone}: #{@text}")
    end

    should "have timestamp for all messages" do
      assert_equal(@response.first.timestamp, Time.at(@timestamp))
    end

    should "have from for all messages" do
      assert_equal(@response.first.from, @phone)
    end

    should "have text for all messages" do
      assert_equal(@response.first.text, @text)
    end

    should "have message_id for all messages" do
      assert_equal(@response.first.message_id, @message_id)
    end
  end

  context "Response to check_number command with single phone" do

    setup do
      @phone = random_phone
      @price = rand
      @country = random_string
      @hash = {
        @phone => {
          "price" => @price,
          "country" => @country
        }
      }
      @response = TextMagic::API::Response.check_number(@hash, true)
    end

    should "be an OpenStruct instance" do
      assert_equal(@response.class, OpenStruct)
    end

    should "have price" do
      assert_in_delta @response.price, (@price), 1e-10
    end

    should "have country" do
      assert_equal(@response.country, @country)
    end
  end

  context "Response to check_number command with multiple phones" do

    setup do
      @phone = random_phone
      @price = rand
      @country = random_string
      @hash = {
        @phone => {
          "price" => @price,
          "country" => @country
        }
      }
      @response = TextMagic::API::Response.check_number(@hash, false)
    end

    should "be a hash" do
      assert_equal(@response.class, Hash)
    end

    should "have phones as keys" do
      assert_equal(@response.keys, [@phone])
    end

    should "contain OpenStruct instances" do
      assert_equal(@response.values.first.class, OpenStruct)
    end

    should "have price for all phones" do
      assert_in_delta @response.values.first.price, (@price), 1e-10
    end

    should "have country for all phones" do
      assert_equal( @response.values.first.country, @country)
    end
  end
end
