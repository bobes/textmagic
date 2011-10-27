module TextMagic

  class API

    class Error < StandardError

      attr_reader :code, :message

      # Creates an instance of TextMagic::API::Error. Error code and error message
      # can be supplied as arguments or in a hash.
      #
      #  TextMagic::API::Error.new(code, message)
      #  TextMagic::API::Error.new("error_code" => code, "error_message" => message)
      def initialize(*args)
        if args.first.is_a?(Hash)
          @code, @message = args.first["error_code"], args.first["error_message"]
        else
          @code, @message = args
        end
      end

      def to_s
        "#{@message} (#{@code})"
      end
    end
  end
end
