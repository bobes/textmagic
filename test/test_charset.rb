# encoding: utf-8

require "test_helper"

class CharsetTest < Minitest::Test

  context "is_gsm method" do

    should "return true if all characters are in GSM 03.38 charset" do
      assert_equal(TextMagic::API.is_gsm(("a".."z").to_a.join), true)
      assert_equal(TextMagic::API.is_gsm(("A".."Z").to_a.join), true)
      assert_equal(TextMagic::API.is_gsm(("0".."9").to_a.join), true)
      assert_equal(TextMagic::API.is_gsm("@£$¥€"), true)
      assert_equal(TextMagic::API.is_gsm("\n\r\e\f\\\""), true)
      assert_equal(TextMagic::API.is_gsm("èéùìòÇØøÅåÉÆæß"), true)
      assert_equal(TextMagic::API.is_gsm("ΔΦΓΛΩΠΨΣΘΞ"), true)
      assert_equal(TextMagic::API.is_gsm("^{}[~]| !#¤%&'()"), true)
      assert_equal(TextMagic::API.is_gsm("*+,-./_:;<=>?¡¿§"), true)
      assert_equal(TextMagic::API.is_gsm("ÖÑÜöñüàäÄ"), true)
    end

    should "return false if some characters are outside of GSM 03.38 charset" do
      assert_equal(TextMagic::API.is_gsm("Arabic: مرحبا فيلما"), false)
      assert_equal(TextMagic::API.is_gsm("Chinese: 您好"), false)
      assert_equal(TextMagic::API.is_gsm("Cyrilic: Вильма Привет"), false)
      assert_equal(TextMagic::API.is_gsm("Thai: สวัสดี"), false)
    end
  end

  context "real_length method" do

    should "count escaped characters as two and all others as one for non-unicode text" do
      escaped = "{}\\~[]|€"
      unescaped = random_string
      text = "#{escaped}#{unescaped}".scan(/./).sort_by { rand }.join
      assert_equal(TextMagic::API.real_length(text, false), unescaped.size + escaped.size * 2)
    end

    should "count all characters as one for unicode text" do
      escaped = "{}\\~[]|€"
      unescaped = random_string
      text = "#{escaped}#{unescaped}".scan(/./).sort_by { rand }.join
      assert_equal(TextMagic::API.real_length(text, true), unescaped.size + escaped.size)
    end
  end
end
