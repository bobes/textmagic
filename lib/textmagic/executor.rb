require "net/http"

module TextMagic

  class API

    module Executor

      module_function

      # Executes a command by sending a request to the TextMagic's Bulk
      # SMS gateway. This is a low-level generic method used by methods
      # in TextMagic::API class. You should never need to use this method
      # directly.
      #
      # Parameters specified in the +options+ hash will be added to the
      # HTTP POST request"s body together with command, username and
      # password.
      #
      # Returns a hash with values parsed from the server"s response if
      # the command was successfully executed. In case the server replies
      # with error, this method raises a TextMagic::API::Error.
      def execute(command, username, password, options = {})
        raise TextMagic::API::Error.new(3, "Command is undefined") unless command
        raise TextMagic::API::Error.new(5, "Invalid username & password combination") unless username && password
        options.merge!(:username => username, :password => password, :cmd => command)
        options.delete_if { |key, value| !key || !value }
        uri = URI("https://www.textmagic.com/app/api")
        response = Net::HTTP.post_form(uri, options)
        result = JSON.parse(response.body) if response.body
        raise Error.new(response.body) if result && result["error_code"]
        result
      end

    end

  end

end
