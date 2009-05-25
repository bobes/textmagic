module TextMagic

  class API

    class Executor

      include HTTParty
      base_uri "https://www.textmagic.com/app"

      # Executes a command by sending a request to the TextMagic's HTTP
      # gateway. This is a low-level generic method used by methods in
      # TextMagic::API class. You should never need to use this method
      # directly.
      #
      # Parameters specified in the +options+ hash will be added to the
      # HTTP request's URI.
      #
      # Returns a hash with values parsed from the server's response if
      # the command was successfully executed. In case the server replies
      # with error, this method raises a TextMagic::API::Error.
      def self.execute(command, username, password, options = {})
        options.merge!(:username => username, :password => password, :cmd => command)
        response = self.get('/api', :query => options, :format => :json)
        raise Error.new(response) if response['error_code']
        response
      end
    end
  end
end
