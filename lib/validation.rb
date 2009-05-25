module TextMagic

  class API

    module Validation

      MAX_LENGTH_GSM = [160, 306, 459]
      MAX_LENGTH_UNICODE = [70, 134, 201]

      def validate_text_length(text, is_unicode, parts = 3)
        max_text_length = (is_unicode ? MAX_LENGTH_UNICODE : MAX_LENGTH_GSM)[parts - 1]
        text.size <= max_text_length
      end

      def validate_phones(*phones)
        phones.flatten!
        return false if phones.empty?
        phones.each { |phone| return false unless phone =~ /^\d{1,15}$/ }
        true
      end
    end
  end
end
