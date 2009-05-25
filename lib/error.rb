module TextMagic

  class API

    class Error < StandardError

      attr_reader :code, :message

      def initialize(*args)
        if args.first.is_a?(Hash)
          @code, @message = args.first['error_code'], args.first['error_message']
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
