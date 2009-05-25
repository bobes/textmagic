require 'test_helper'

class ErrorTest < Test::Unit::TestCase

  context 'Initialization' do

    setup do
      @code = rand(1e3)
      @message = random_string
    end

    should 'accept a hash with error_code and error_message' do
      e = TextMagic::API::Error.new('error_code' => @code, 'error_message' => @message)
      e.code.should == @code
      e.message.should == @message
    end

    should 'accept error_code and error_message' do
      e = TextMagic::API::Error.new(@code, @message)
      e.code.should == @code
      e.message.should == @message
    end
  end
end
