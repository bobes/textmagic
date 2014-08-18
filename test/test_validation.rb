require "test_helper"

class ValidationTest < Minitest::Test

  context "validate_text_length method for non-unicode texts" do

    should "use real_length method to determine the real length of the message" do
      text = random_string
      TextMagic::API.expects(:real_length).with(text, false).returns(0)
      TextMagic::API.validate_text_length(text, false, 1)
    end

    should "return true if parts limit is set to 1 and text length is less than or equal to 160" do
      assert_equal(TextMagic::API.validate_text_length(random_string(160), false, 1), true)
    end

    should "return false if parts limit is set to 1 and text length is greater than 160" do
      assert_equal(TextMagic::API.validate_text_length(random_string(161), false, 1), false)
    end

    should "return true if parts limit is set to 2 and text length is less than or equal to 306" do
      assert_equal(TextMagic::API.validate_text_length(random_string(306), false, 2), true)
    end

    should "return false if parts limit is set to 2 and text length is greater than 306" do
      assert_equal(TextMagic::API.validate_text_length(random_string(307), false, 2), false)
    end

    should "return true if parts limit is set to 3 or is not specified and text length is less than or equal to 459" do
      assert_equal(TextMagic::API.validate_text_length(random_string(459), false), true)
      assert_equal(TextMagic::API.validate_text_length(random_string(459), false, 3), true)
    end

    should "return false if parts limit is set to 3 or is not specified and text length is greater than 459" do
      assert_equal(TextMagic::API.validate_text_length(random_string(460), false), false)
      assert_equal(TextMagic::API.validate_text_length(random_string(460), false, 3), false)
    end
  end

  context "validate_text_length method for unicode texts" do

    should "use real_length method to determine the real length of the message" do
      text = random_string
      TextMagic::API.expects(:real_length).with(text, true).returns(0)
      TextMagic::API.validate_text_length(text, true, 1)
    end

    should "return true if parts limit is set to 1 and text length is less than or equal to 70" do
      assert_equal(TextMagic::API.validate_text_length(random_string(70), true, 1), true)
    end

    should "return false if parts limit is set to 1 and text length is greater than 70" do
      assert_equal(TextMagic::API.validate_text_length(random_string(71), true, 1), false)
    end

    should "return true if parts limit is set to 2 and text length is less than or equal to 134" do
      assert_equal(TextMagic::API.validate_text_length(random_string(134), true, 2), true)
    end

    should "return false if parts limit is set to 2 and text length is greater than 134" do
      assert_equal(TextMagic::API.validate_text_length(random_string(135), true, 2), false)
    end

    should "return true if parts limit is set to 3 or is not specified and text length is less than or equal to 201" do
      assert_equal(TextMagic::API.validate_text_length(random_string(201), true), true)
      assert_equal(TextMagic::API.validate_text_length(random_string(201), true, 3), true)
    end

    should "return false if parts limit is set to 3 or is not specified and text length is greater than 201" do
      assert_equal(TextMagic::API.validate_text_length(random_string(202), true), false)
      assert_equal(TextMagic::API.validate_text_length(random_string(202), true, 3), false)
    end
  end

  context "validate_phones method" do

    should "return true if phone number consists of up to 15 digits" do
      assert_equal(TextMagic::API.validate_phones(rand(10 ** 15).to_s), true)
    end

    should "return false if phone number is longer than 15 digits" do
      assert_equal(TextMagic::API.validate_phones((10 ** 16 + rand(10 ** 15)).to_s), false)
    end

    should "return false if phone number contains non-digits" do
      assert_equal(TextMagic::API.validate_phones(random_string), false)
    end

    should "return false if phone number is empty" do
      assert_equal(TextMagic::API.validate_phones(""), false)
    end

    should "return true if all phone numbers in a list are valid" do
      phone1, phone2 = rand(10 ** 15).to_s, rand(10 ** 15).to_s
      assert_equal(TextMagic::API.validate_phones(phone1, phone2), true)
      assert_equal(TextMagic::API.validate_phones([phone1, phone2]), true)
    end

    should "return false if phone numbers list is empty" do
      assert_equal(TextMagic::API.validate_phones(), false)
    end

    should "return false if format of any of phone numbers in a list is invalid" do
      phone1 = rand(10 ** 15).to_s, rand(10 ** 15).to_s
      phone2 = random_string
      assert_equal(TextMagic::API.validate_phones(phone1, phone2), false)
      assert_equal(TextMagic::API.validate_phones([phone1, phone2]), false)
    end
  end
end
