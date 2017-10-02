require "test_helper"

describe "Validation" do

  describe "validate_text_length method for non-unicode texts" do

    it "should use real_length method to determine the real length of the message" do
      text = random_string
      TextMagic::API.expects(:real_length).with(text, false).returns(0)
      TextMagic::API.validate_text_length(text, false, 1)
    end

    it "should return true if parts limit is set to 1 and text length is less than or equal to 160" do
      assert_equal true, TextMagic::API.validate_text_length(random_string(160), false, 1)
    end

    it "should return false if parts limit is set to 1 and text length is greater than 160" do
      assert_equal false, TextMagic::API.validate_text_length(random_string(161), false, 1)
    end

    it "should return true if parts limit is set to 2 and text length is less than or equal to 306" do
      assert_equal true, TextMagic::API.validate_text_length(random_string(306), false, 2)
    end

    it "should return false if parts limit is set to 2 and text length is greater than 306" do
      assert_equal false, TextMagic::API.validate_text_length(random_string(307), false, 2)
    end

    it "should return true if parts limit is set to 3 or is not specified and text length is less than or equal to 459" do
      assert_equal true, TextMagic::API.validate_text_length(random_string(459), false)
      assert_equal true, TextMagic::API.validate_text_length(random_string(459), false, 3)
    end

    it "should return false if parts limit is set to 3 or is not specified and text length is greater than 459" do
      assert_equal false, TextMagic::API.validate_text_length(random_string(460), false)
      assert_equal false, TextMagic::API.validate_text_length(random_string(460), false, 3)
    end
  end

  describe "validate_text_length method for unicode texts" do

    it "should use real_length method to determine the real length of the message" do
      text = random_string
      TextMagic::API.expects(:real_length).with(text, true).returns(0)
      TextMagic::API.validate_text_length(text, true, 1)
    end

    it "should return true if parts limit is set to 1 and text length is less than or equal to 70" do
      assert_equal true, TextMagic::API.validate_text_length(random_string(70), true, 1)
    end

    it "should return false if parts limit is set to 1 and text length is greater than 70" do
      assert_equal true, TextMagic::API.validate_text_length(random_string(71), false, 1)
    end

    it "should return true if parts limit is set to 2 and text length is less than or equal to 134" do
      assert_equal true, TextMagic::API.validate_text_length(random_string(134), true, 2)
    end

    it "should return false if parts limit is set to 2 and text length is greater than 134" do
      assert_equal true, TextMagic::API.validate_text_length(random_string(135), false, 2)
    end

    it "should return true if parts limit is set to 3 or is not specified and text length is less than or equal to 201" do
      assert_equal true, TextMagic::API.validate_text_length(random_string(201), true)
      assert_equal true, TextMagic::API.validate_text_length(random_string(201), true, 3)
    end

    it "should return false if parts limit is set to 3 or is not specified and text length is greater than 201" do
      assert_equal true, TextMagic::API.validate_text_length(random_string(202), false)
      assert_equal true, TextMagic::API.validate_text_length(random_string(202), false, 3)
    end
  end

  describe "validate_phones method" do

    it "should return true if phone number consists of up to 15 digits" do
      assert_equal true, TextMagic::API.validate_phones(rand(10**15).to_s)
    end

    it "should return false if phone number is longer than 15 digits" do
      assert_equal false, TextMagic::API.validate_phones((10**16 + rand(10**15)).to_s)
    end

    it "should return false if phone number contains non-digits" do
      assert_equal false, TextMagic::API.validate_phones(random_string)
    end

    it "should return false if phone number is empty" do
      assert_equal false, TextMagic::API.validate_phones("")
    end

    it "should return true if all phone numbers in a list are valid" do
      phone1 = rand(10**15).to_s
      phone2 = rand(10**15).to_s
      assert_equal true, TextMagic::API.validate_phones(phone1, phone2)
      assert_equal true, TextMagic::API.validate_phones([phone1, phone2])
    end

    it "should return false if phone numbers list is empty" do
      assert_equal false, TextMagic::API.validate_phones
    end

    it "should return false if format of any of phone numbers in a list is invalid" do
      phone1 = rand(10**15).to_s, rand(10**15).to_s
      phone2 = random_string
      assert_equal false, TextMagic::API.validate_phones(phone1, phone2)
      assert_equal false, TextMagic::API.validate_phones([phone1, phone2])
    end
  end
end
