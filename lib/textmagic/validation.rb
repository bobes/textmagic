module TextMagic

  class API

    module Validation

      MAX_LENGTH_GSM = [160, 306, 459].freeze
      MAX_LENGTH_UNICODE = [70, 134, 201].freeze

      # Validates message text length. Returns +true+ if the text length is
      # within the limits for the unicode/parts combination, otherwise it
      # returns +false+.
      #
      # Note: <em>Maximum lengths for 1, 2 and 3-part GSM 03.38 messages are
      # 160, 306 and 459 respectively.
      # Maximum lengths for 1, 2 and 3-part unicode messages are
      # 70, 134 and 201 respectively.</em>
      def validate_text_length(text, unicode, parts = 3)
        max_text_length = (unicode ? MAX_LENGTH_UNICODE : MAX_LENGTH_GSM)[parts - 1]
        real_length(text, unicode) <= max_text_length
      end

      # Validates a list of phone numbers. Returns +true+ if the list is not empty
      # and all phone numbers are digit-only strings of maximum length of 15,
      # otherwise it returns +false+.
      def validate_phones(*phones)
        phones.flatten!
        return false if phones.empty?
        phones.each { |phone| return false unless phone =~ /^\d{1,15}$/ }
        true
      end

    end

  end

end
