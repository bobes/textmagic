require "test_helper"

describe "Error" do

  describe "Initialization" do

    before do
      @code = rand(1e3)
      @message = random_string
    end

    it "should accept a hash with error_code and error_message" do
      e = TextMagic::API::Error.new("error_code" => @code, "error_message" => @message)
      assert_equal @code, e.code
      assert_equal @message, e.message
    end

    it "should accept error_code and error_message" do
      e = TextMagic::API::Error.new(@code, @message)
      assert_equal @code, e.code
      assert_equal @message, e.message
    end
  end
end
