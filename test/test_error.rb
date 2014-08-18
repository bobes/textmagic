require "test_helper"

class ErrorTest < Minitest::Test

  context "Initialization" do

    setup do
      @code = rand(1e3)
      @message = random_string
    end

    should "accept a hash with error_code and error_message" do
      e = TextMagic::API::Error.new("error_code" => @code, "error_message" => @message)
      assert_equal e.code, @code
      assert_equal e.message, @message
    end

    should "accept error_code and error_message" do
      e = TextMagic::API::Error.new(@code, @message)
      assert_equal e.code, @code
      assert_equal e.message, @message
    end
  end
end
