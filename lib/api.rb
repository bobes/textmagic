module TextMagic

  class API

    extend Charset
    extend Validation

    # Creates new API instance with specified credentials. These will be
    # used in all requests to the TextMagic SMS gateway done through
    # this instance. Multiple instances with different credentials can
    # be used at the same time.
    #
    # Example usage:
    #
    #   api = TextMagic::API.new('fred', 'secret')
    def initialize(username, password)
      @username = username
      @password = password
    end

    # Executes an account command by sending a request to the TextMagic's
    # SMS gateway.
    #
    # This method returns an object with balance attribute.
    # In case the request to the SMS gateway is not successful or the server
    # returns an error response, an Error is raised.
    #
    # Example usage:
    #
    #  api.account.balance
    #  # => 314.15
    def account
      hash = Executor.execute('account', @username, @password)
      TextMagic::API::Response.account(hash)
    end

    # Executes a send command by sending a request to the TextMagic's
    # SMS gateway.
    #
    # If called with a single phone number, this method returns a string message id.
    # If called with multiple phone numbers, it will return an hash of message ids
    # with phone numbers as keys.
    # In both cases the returned object is extended with +sent_text+ and +parts_count+
    # attributes.
    # In case the request to the SMS gateway is not successful or the server returns
    # an error response, an Error is raised.
    #
    # The optional parameters you can specify in the options Hash are:
    # * +unicode+: accepted values are +true+, +false+, +0+ and +1+. If not specified,
    #   the method will determine the unicode value based on the characters in
    #   the text.
    # * +max_length+: accepted values are +nil+, +1+, +2+ and +3+, defaults to nil.
    #   If not specified, the SMS gateway will apply its own default value.
    #
    # Example usage:
    #
    #  api.send('Hi Wilma', '999314159265')
    #  # => '141421'
    #  response = api.send('Hello everybody', '999314159265', '999271828182', :max_length => 2)
    #  # => { '999314159265' => '141421', '999271828182' => '173205' }
    #  response.parts_count
    #  # => 1
    #
    # Multiple phone numbers can be supplied as an array or as a list of arguments:
    #
    #  api.send('Hello everybody', ['999314159265', '999271828182'])
    #  api.send('Hello everybody', '999314159265', '999271828182')
    #
    # If you want to send a message to a single phone number but still
    # want to get a hash response, put the phone number in an array:
    #
    #  api.send('Hi Barney', ['999271828182'])
    def send(text, *args)
      raise Error.new(1, 'Message text is empty') if text.nil? || text.blank?
      options = args.last.is_a?(Hash) ? args.pop : {}
      unicode = API.is_unicode(text)
      options[:unicode] = case options[:unicode]
      when 1, true: 1
      when 0, false: 0
      when nil: unicode ? 1 : 0
      else raise Error.new(10, "Wrong parameter value #{options[:unicode]} for parameter unicode")
      end
      raise Error.new(6, 'Message contains invalid characters') if unicode && options[:unicode] == 0
      raise Error.new(7, 'Message too long') unless API.validate_text_length(text, unicode)
      single = args.size == 1 && args.first.is_a?(String)
      phones = args.flatten
      raise Error.new(9, 'Invalid phone number format') unless API.validate_phones(phones)
      hash = Executor.execute('send', @username, @password, options.merge(:text => text, :phone => phones.join(',')))
      TextMagic::API::Response.send(hash, single)
    end

    # Executes a message_status command by sending a request to the TextMagic's
    # SMS gateway.
    #
    # If called with a single +id+, this method returns a single string value
    # denoting the message status. This string is extended with custom attributes
    # +text+, +status+, +created_time+, +completed_time+, +reply_number+ and
    # +credits_cost+. If called with multiple ids, it returns a hash of such
    # strings with message ids as keys.
    # In case the request to the SMS gateway is not successful or the server returns
    # an error response, an Error is raised.
    #
    # Example usage:
    #
    #  status = api.message_status('141421')
    #  # => 'd'
    #  status.completed_time
    #  # => Fri May 22 10:10:18 +0200 2009
    #
    # Example with multiple ids:
    #
    #  statuses = api.message_status('141421', '173205')
    #  # => { '141421' => 'r', '173205' => 'd' }
    #  statuses['141421'].text
    #  # => 'Hi Wilma'
    #  statuses['173205'].created_time
    #  # => Thu May 28 16:41:45 +0200 2009
    #
    # Multiple ids can be supplied as an array or as a list of arguments:
    #
    #  api.send('Hello everybody', ['999314159265', '999271828182'])
    #  api.send('Hello everybody', '999314159265', '999271828182')
    #
    # If you want to request status for a single message but still want to get
    # a hash response, put the id in an array:
    #
    #  api.message_status(['141421'])
    #
    # <b>It is strongly encouraged to setup callbacks to receive updates on message status
    # instead of using this method.</b>
    def message_status(*ids)
      single = ids.size == 1 && ids.first.is_a?(String)
      ids.flatten!
      raise TextMagic::API::Error.new(4, 'Insufficient parameters') if ids.empty?
      hash = Executor.execute('message_status', @username, @password, :ids => ids.join(','))
      TextMagic::API::Response.message_status(hash, single)
    end

    # Executes a receive command by sending a request to the TextMagic's
    # SMS gateway.
    #
    # This method returnes an array with retrieved messages. Every member of
    # the array is a string with +from+, +text+, +timestamp+ and +message_id+
    # attributes. The value of every string contains a phone number and text.
    # In case the request to the SMS gateway is not successful or the server returns
    # an error response, an Error is raised.
    #
    # This method accepts an optional +last_retrieved_id+ value. If called
    # with this argument, the gateway will only return replies newer than the
    # one with specified id.
    #
    # Example usage:
    #
    #  replies = api.receive
    #  # => ['999271828182: Hello Fred', '999314159265: Good day']
    #  replies.first.text
    #  # => 'Hello Fred'
    #  replies.first.from
    #  # => '999314159265'
    #  replies.last.message_id
    #  # => '223606'
    #  api.receive '223606'
    #  # => []
    #
    # <b>It is strongly encouraged to setup callbacks to receive replies instead of
    # using this method.</b>
    def receive(last_retrieved_id = nil)
      hash = Executor.execute('receive', @username, @password, :last_retrieved_id => last_retrieved_id)
      TextMagic::API::Response.receive(hash)
    end

    # Executes a delete_reply command by sending a request to the TextMagic's
    # SMS gateway.
    #
    # This method always returns true.
    # In case the request to the SMS gateway is not successful or the server returns
    # an error response, an Error is raised.
    #
    # Example usage:
    #
    #  api.delete_reply('141421')
    #  api.delete_reply('173205', '223606')
    #  api.delete_reply(['244948', '264575'])
    def delete_reply(*ids)
      single = ids.size == 1 && ids.first.is_a?(String)
      ids.flatten!
      raise TextMagic::API::Error.new(4, 'Insufficient parameters') if ids.empty?
      Executor.execute('delete_reply', @username, @password, :ids => ids.join(','))
      true
    end
  end
end
