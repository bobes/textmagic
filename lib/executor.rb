module TextMagic

  class API

    class Executor

      include HTTParty
      base_uri "https://www.textmagic.com/app"

      def self.execute(command, username, password, options = {})
        options.merge!(:username => username, :password => password, :cmd => command)
        response = self.get('/api', :query => options, :format => :json)
        raise Error.new(response) if response['error_code']
        response
      end
    end
  end
end
