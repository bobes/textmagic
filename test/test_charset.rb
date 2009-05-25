require 'test_helper'
require 'json'

class CharsetTest < Test::Unit::TestCase

  context 'is_gsm method' do

    should 'return true if all characters are in GSM 03.38 charset' do
      TextMagic::API.is_gsm(('a'..'z').to_a.join).should == true
      TextMagic::API.is_gsm(('A'..'Z').to_a.join).should == true
      TextMagic::API.is_gsm(('0'..'9').to_a.join).should == true
      TextMagic::API.is_gsm("@£$¥€").should == true
      TextMagic::API.is_gsm("\n\r\e\f\\\"").should == true
      TextMagic::API.is_gsm("èéùìòÇØøÅåÉÆæß").should == true
      TextMagic::API.is_gsm("ΔΦΓΛΩΠΨΣΘΞ").should == true
      TextMagic::API.is_gsm("^{}[~]| !#¤%&'()").should == true
      TextMagic::API.is_gsm("*+,-./_:;<=>?¡¿§").should == true
      TextMagic::API.is_gsm("ÖÑÜöñüàäÄ").should == true
    end

    should 'return false if some characters are outside of GSM 03.38 charset' do
      TextMagic::API.is_gsm('Arabic: مرحبا فيلما').should == false
      TextMagic::API.is_gsm('Chinese: 您好').should == false
      TextMagic::API.is_gsm('Cyrilic: Вильма Привет').should == false
      TextMagic::API.is_gsm('Thai: สวัสดี').should == false
    end
  end
end
