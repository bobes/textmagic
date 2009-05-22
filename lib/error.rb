module TextMagic

  class API

    class Error < StandardError

      attr_reader :code, :message

      def initialize(response)
        @code, @message = response[:error_code], response[:error_message]
      end

      def to_s
        "#{@message} (#{@code})"
      end
    end
  end
end
