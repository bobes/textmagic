require 'test_helper'
require 'json'

class ValidationTest < Test::Unit::TestCase

  context 'validate_text_length method for non-unicode texts' do

    should 'return true if parts limit is set to 1 and text length is less than or equal to 160' do
      TextMagic::API.validate_text_length(random_string(160), false, 1).should == true
    end

    should 'return false if parts limit is set to 1 and text length is greater than 160' do
      TextMagic::API.validate_text_length(random_string(161), false, 1).should == false
    end

    should 'return true if parts limit is set to 2 and text length is less than or equal to 306' do
      TextMagic::API.validate_text_length(random_string(306), false, 2).should == true
    end

    should 'return false if parts limit is set to 2 and text length is greater than 306' do
      TextMagic::API.validate_text_length(random_string(307), false, 2).should == false
    end

    should 'return true if parts limit is set to 3 or is not specified and text length is less than or equal to 459' do
      TextMagic::API.validate_text_length(random_string(459), false).should == true
      TextMagic::API.validate_text_length(random_string(459), false, 3).should == true
    end

    should 'return false if parts limit is set to 3 or is not specified and text length is greater than 459' do
      TextMagic::API.validate_text_length(random_string(460), false).should == false
      TextMagic::API.validate_text_length(random_string(460), false, 3).should == false
    end
  end

  context 'validate_text_length method for unicode texts' do

    should 'return true if parts limit is set to 1 and text length is less than or equal to 70' do
      TextMagic::API.validate_text_length(random_string(70), true, 1).should == true
    end

    should 'return false if parts limit is set to 1 and text length is greater than 70' do
      TextMagic::API.validate_text_length(random_string(71), true, 1).should == false
    end

    should 'return true if parts limit is set to 2 and text length is less than or equal to 134' do
      TextMagic::API.validate_text_length(random_string(134), true, 2).should == true
    end

    should 'return false if parts limit is set to 2 and text length is greater than 134' do
      TextMagic::API.validate_text_length(random_string(135), true, 2).should == false
    end

    should 'return true if parts limit is set to 3 or is not specified and text length is less than or equal to 201' do
      TextMagic::API.validate_text_length(random_string(201), true).should == true
      TextMagic::API.validate_text_length(random_string(201), true, 3).should == true
    end

    should 'return false if parts limit is set to 3 or is not specified and text length is greater than 201' do
      TextMagic::API.validate_text_length(random_string(202), true).should == false
      TextMagic::API.validate_text_length(random_string(202), true, 3).should == false
    end
  end

  context 'validate_phones method' do

    should 'return true if phone number consists of up to 15 digits' do
      TextMagic::API.validate_phones(rand(10 ** 15).to_s).should == true
    end

    should 'return false if phone number is longer than 15 digits' do
      TextMagic::API.validate_phones((10 ** 16 + rand(10 ** 15)).to_s).should == false
    end

    should 'return false if phone number contains non-digits' do
      TextMagic::API.validate_phones(random_string).should == false
    end

    should 'return false if phone number is empty' do
      TextMagic::API.validate_phones('').should == false
    end

    should 'return true if all phone numbers in a list are valid' do
      phone1, phone2 = rand(10 ** 15).to_s, rand(10 ** 15).to_s
      TextMagic::API.validate_phones(phone1, phone2).should == true
      TextMagic::API.validate_phones([phone1, phone2]).should == true
    end

    should 'return false if phone numbers list is empty' do
      TextMagic::API.validate_phones().should == false
    end

    should 'return false if format of any of phone numbers in a list is invalid' do
      phone1 = rand(10 ** 15).to_s, rand(10 ** 15).to_s
      phone2 = random_string
      TextMagic::API.validate_phones(phone1, phone2).should == false
      TextMagic::API.validate_phones([phone1, phone2]).should == false
    end
  end
end
