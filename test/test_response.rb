require "test_helper"

describe "Response" do

  describe "Response to account command" do

    before do
      @balance = 0.1 * rand(1e4)
      @hash = { "balance" => @balance.to_s }
      @response = TextMagic::API::Response.account(@hash)
    end

    it "should be an OpenStruct instance" do
      assert_kind_of OpenStruct, @response
    end

    it "should have balance" do
      assert_in_delta @response.balance, @balance, 1e-10
    end
  end

  describe "Response to send command with single phone number" do

    before do
      @message_id = random_string
      @phone = random_phone
      @text = random_string
      @parts_count = 1 + rand(3)
      @hash = { "message_id" => { @message_id => @phone }, "sent_text" => @text, "parts_count" => @parts_count }
      @response = TextMagic::API::Response.send(@hash, true)
    end

    it "should equal to the message_id" do
      assert_equal @message_id, @response
    end

    it "should have sent_text" do
      assert_equal @text, @response.sent_text
    end

    it "should have parts_count" do
      assert_equal @parts_count, @response.parts_count
    end
  end

  describe "Response to send command with multiple phone numbers" do

    before do
      @message_id1 = random_string
      @phone1 = random_phone
      @message_id2 = random_string
      @phone2 = random_phone
      @text = random_string
      @parts_count = 1 + rand(3)
      @hash = { "message_id" => { @message_id1 => @phone1, @message_id2 => @phone2 }, "sent_text" => @text, "parts_count" => @parts_count }
      @response = TextMagic::API::Response.send(@hash, false)
    end

    it "should be a hash" do
      assert_kind_of Hash, @response
    end

    it "should have phone numbers as keys" do
      assert_equal [@phone1, @phone2].sort, @response.keys.sort
    end

    it "should have message ids as values" do
      assert_equal @message_id1, @response[@phone1]
      assert_equal @message_id2, @response[@phone2]
    end

    it "should have sent_text" do
      assert_equal @text, @response.sent_text
    end

    it "should have parts_count" do
      assert_equal @parts_count, @response.parts_count
    end
  end

  describe "Response to message_status command with single id" do

    before do
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
          "credits_cost" => @credits_cost,
        },
      }
      @response = TextMagic::API::Response.message_status(@hash, true)
    end

    it "should equal to the message status" do
      assert_equal @status, @response
    end

    it "should have text" do
      assert_equal @text, @response.text
    end

    it "should have created_time" do
      assert_equal Time.at(@created_time), @response.created_time
    end

    it "should have completed_time" do
      assert_equal Time.at(@completed_time), @response.completed_time
    end

    it "should have reply_number" do
      assert_equal @reply_number, @response.reply_number
    end

    it "should have credits_cost" do
      assert_in_delta @response.credits_cost, @credits_cost, 1e-10
    end

    it "should have status" do
      assert_equal @status, @response.status
    end
  end

  describe "Response to message_status command with multiple ids" do

    before do
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
          "credits_cost" => @credits_cost,
        },
      }
      @response = TextMagic::API::Response.message_status(@hash, false)
    end

    it "should be a hash" do
      assert_kind_of Hash, @response
    end

    it "should have message_ids as keys" do
      assert_equal ["141421"], @response.keys
    end

    it "should contain statuses" do
      assert_equal @status, @response.values.first
    end

    it "should have text for all statuses" do
      assert_equal @text, @response.values.first.text
    end

    it "should have created_time for all statuses" do
      assert_equal Time.at(@created_time), @response.values.first.created_time
    end

    it "should have completed_time for all statuses" do
      assert_equal Time.at(@completed_time), @response.values.first.completed_time
    end

    it "should have reply_number for all statuses" do
      assert_equal @reply_number, @response.values.first.reply_number
    end

    it "should have status for all statuses" do
      assert_equal @status, @response.values.first.status
    end

    it "should have credits_cost for all statuses" do
      assert_in_delta @response.values.first.credits_cost, @credits_cost, 1e-10
    end
  end

  describe "Response to receive command" do

    before do
      @timestamp = (Time.now - 30).to_i
      @text = random_string
      @phone = random_phone
      @message_id = random_string
      @message = {
        "timestamp" => @timestamp,
        "from" => @phone,
        "text" => @text,
        "message_id" => @message_id,
      }
      @unread = rand(1e4)
      @hash = { "unread" => @unread, "messages" => [@message] }
      @response = TextMagic::API::Response.receive(@hash)
    end

    it "should have unread" do
      assert_equal @unread, @response.unread
    end

    it "should be an array" do
      assert_kind_of Array, @response
    end

    it "should contain strings with phones numbers and texts" do
      assert_equal "#{@phone}: #{@text}", @response.first
    end

    it "should have timestamp for all messages" do
      assert_equal Time.at(@timestamp), @response.first.timestamp
    end

    it "should have from for all messages" do
      assert_equal @phone, @response.first.from
    end

    it "should have text for all messages" do
      assert_equal @text, @response.first.text
    end

    it "should have message_id for all messages" do
      assert_equal @message_id, @response.first.message_id
    end
  end

  describe "Response to check_number command with single phone" do

    before do
      @phone = random_phone
      @price = rand
      @country = random_string
      @hash = {
        @phone => {
          "price" => @price,
          "country" => @country,
        },
      }
      @response = TextMagic::API::Response.check_number(@hash, true)
    end

    it "should be an OpenStruct instance" do
      assert_kind_of OpenStruct, @response
    end

    it "should have price" do
      assert_in_delta @response.price, @price, 1e-10
    end

    it "should have country" do
      assert_equal @country, @response.country
    end
  end

  describe "Response to check_number command with multiple phones" do

    before do
      @phone = random_phone
      @price = rand
      @country = random_string
      @hash = {
        @phone => {
          "price" => @price,
          "country" => @country,
        },
      }
      @response = TextMagic::API::Response.check_number(@hash, false)
    end

    it "should be a hash" do
      assert_kind_of Hash, @response
    end

    it "should have phones as keys" do
      assert_equal [@phone], @response.keys
    end

    it "should contain OpenStruct instances" do
      assert_kind_of OpenStruct, @response.values.first
    end

    it "should have price for all phones" do
      assert_in_delta @response.values.first.price, @price, 1e-10
    end

    it "should have country for all phones" do
      assert_equal  @response.values.first.country, @country
    end
  end
end
