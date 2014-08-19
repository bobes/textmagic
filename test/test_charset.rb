# encoding: utf-8

require "test_helper"

describe "Charset" do

  describe "is_gsm method" do

    it "should return true if all characters are in GSM 03.38 charset" do
      assert_equal true, TextMagic::API.is_gsm(("a".."z").to_a.join)
      assert_equal true, TextMagic::API.is_gsm(("A".."Z").to_a.join)
      assert_equal true, TextMagic::API.is_gsm(("0".."9").to_a.join)
      assert_equal true, TextMagic::API.is_gsm("@£$¥€")
      assert_equal true, TextMagic::API.is_gsm("\n\r\e\f\\\"")
      assert_equal true, TextMagic::API.is_gsm("èéùìòÇØøÅåÉÆæß")
      assert_equal true, TextMagic::API.is_gsm("ΔΦΓΛΩΠΨΣΘΞ")
      assert_equal true, TextMagic::API.is_gsm("^{}[~]| !#¤%&'()")
      assert_equal true, TextMagic::API.is_gsm("*+,-./_:;<=>?¡¿§")
      assert_equal true, TextMagic::API.is_gsm("ÖÑÜöñüàäÄ")
    end

    it "should return false if some characters are outside of GSM 03.38 charset" do
      assert_equal false, TextMagic::API.is_gsm("Arabic: مرحبا فيلما")
      assert_equal false, TextMagic::API.is_gsm("Chinese: 您好")
      assert_equal false, TextMagic::API.is_gsm("Cyrilic: Вильма Привет")
      assert_equal false, TextMagic::API.is_gsm("Thai: สวัสดี")
    end
  end

  describe "real_length method" do

    it "should count escaped characters as two and all others as one for non-unicode text" do
      escaped = "{}\\~[]|€"
      unescaped = random_string
      text = "#{escaped}#{unescaped}".scan(/./).sort_by { rand }.join
      assert_equal unescaped.size + escaped.size * 2, TextMagic::API.real_length(text, false)
    end

    it "should count all characters as one for unicode text" do
      escaped = "{}\\~[]|€"
      unescaped = random_string
      text = "#{escaped}#{unescaped}".scan(/./).sort_by { rand }.join
      assert_equal unescaped.size + escaped.size, TextMagic::API.real_length(text, true)
    end
  end
end
