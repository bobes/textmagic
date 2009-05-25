module TextMagic

  class API

    class Executor

      include HTTParty
      base_uri "http://www.textmagic.com/app"

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
        raise TextMagic::API::Error.new(3, 'Command is undefined') if command.nil? || command.blank?
        if username.nil? || username.blank? || password.nil? || password.blank?
          raise TextMagic::API::Error.new(5, 'Invalid username & password combination')
        end
        options.merge!(:username => username, :password => password, :cmd => command)
        options.delete_if { |key, value| key.nil? || key.to_s.blank? || value.nil? || value.to_s.blank? }
        response = self.get('/api', :query => options, :format => :json)
        raise Error.new(response) if response && response['error_code']
        response
      end
    end
  end
end
