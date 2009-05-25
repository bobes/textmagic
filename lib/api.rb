module TextMagic

  class API

    extend Charset
    extend Validation

    # Creates new API instance with specified credentials. These will be
    # used in all requests to the TextMagic's HTTP gateway done through
    # this instance. Multiple instances with different credentials can
    # be used at the same time.
    #
    # Example usage:
    #
    #  api = TextMagic::API.new('fred', 'secret')
    def initialize(username, password)
      @username = username
      @password = password
    end

    # Executes an account command and returns a hash with account's balance
    # if successful, otherwise it raises a TextMagic::API::Error.
    # The returned hash will be extended with custom reader methods defined in module
    # TextMagic::API::Response::Account.
    #
    # Example usage:
    #
    #  api.account
    #  # => { 'balance' => '3.14' }
    #  api.account.balance
    #  # => 3.14
    def account
      response = Executor.execute('account', @username, @password)
      response.extend(TextMagic::API::Response::Account)
    end

    # Executes a send command and returns a hash with message ids, sent text and
    # number of parts if successful, otherwise it raises a TextMagic::API::Error.
    # The returned hash will be extended with custom reader methods defined in module
    # TextMagic::API::Response::Send.
    #
    # This method accepts any positive number of phone numbers and an additional
    # options hash.
    #
    # The optional parameters you can specify in the options hash are:
    # * +unicode+: accepted values are true, false, 0 and 1
    # * +max_length+: accepted values are nil, 1, 2 and 3, defaults to nil
    # If not specified, the method will determine the unicode value based on the
    # characters in the text.
    #
    # Example usage:
    #
    #  api.send('Hi Vilma', '314159265358')
    #  # => { 'message_id' => { '1414213' => '314159265358', '1732050' => '271828182845' }, 'sent_text' => 'Hi Vilma', 'parts_count' => 1 }
    #  api.send(text, phone, :unicode => true)
    #  api.send(text, phone1, phone2, :max_length => 2)
    #  api.send(text, [phone1, phone2])
    #
    # Using custom accessors:
    #
    #  response = api.send('Hi Vilma', '314159265358', '271828182845')
    #  response.message_ids
    #  # => ['1414213', '1732050']
    #  response.message_id
    #  # => { '314159265358' => '1414213', '271828182845' => '1732050' }
    #  response.message_id('314159265358')
    #  # => '1414213'
    #  response.parts_count
    #  # => 1
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
      phones = args.flatten
      raise Error.new(9, 'Invalid phone number format') unless API.validate_phones(phones)
      response = Executor.execute('send', @username, @password, options.merge(:text => text, :phone => phones.join(',')))
      response.extend(TextMagic::API::Response::Send)
    end

    # Executes a message_status command and returns a hash with states of
    # messages for specified ids if successful, otherwise it raises a
    # TextMagic::API::Error.
    # The returned hash will be extended with custom reader methods defined in module
    # TextMagic::API::Response::MessageStatus.
    #
    # This method accepts any positive number of ids specified as an array
    # or as a list of arguments
    #
    # Example usage:
    #
    #  api.message_status('1414213')
    #  # => { '1414213' => { 'text' => 'Hi Vilma', 'status' => 'd' , 'created_time' => '1242979818', 'reply_number' => '447624800500', 'completed_time': null, 'credits_cost': '0.5' } }
    #  api.message_status('1414213', '1732050')
    #  api.message_status(['1414213', '1732050'])
    #
    # Using custom accessors:
    #
    #  response = api.message_status('1414213', '1732050')
    #  response.text('1414213')
    #  # => 'Hi Vilma'
    #  response.status('1414213')
    #  # => 'd'
    #  response.created_time('1414213')
    #  # => Fri May 22 10:10:18 +0200 2009
    def message_status(*ids)
      ids.flatten!
      raise TextMagic::API::Error.new(4, 'Insufficient parameters') if ids.empty?
      response = Executor.execute('message_status', @username, @password, :ids => ids.join(','))
      response.extend(TextMagic::API::Response::MessageStatus)
    end

    # Executes a receive command and returns a hash with unread messages
    # if successful, otherwise it raises a TextMagic::API::Error.
    # The returned hash will be extended with custom reader methods defined in module
    # TextMagic::API::Response::Receive.
    #
    # This method accepts an optional +last_retrieved_id+ value.
    #
    # Example usage:
    #
    #  api.receive
    #  # => { 'messages' => [{ 'message_id' => '1414213', 'from' => '314159265358', 'timestamp' => 1242987175, 'text' => 'Hi Fred!' }], 'unread' => 0 }
    #  api.receive '1414213'
    #
    # Using custom accessors:
    #
    #  response = api.receive
    #  response.messages
    #  # => { '1414213' => { 'timestamp' => 1242987175, 'from' => '314159265358', 'text' => 'Hi Fred', 'message_id' => '1414213' } }
    #  response.messages
    #  # => { '1414213' => { 'timestamp' => 1242987175, 'from' => '314159265358', 'text' => 'Hi Fred', 'message_id' => '1414213' } }
    #  response.message_ids
    #  # => ['1414213']
    #  response.message('1414213')
    #  # => { 'timestamp' => 1242987175, 'from' => '314159265358', 'text' => 'Hi Fred', 'message_id' => '1414213' }
    def receive(last_retrieved_id = nil)
      response = Executor.execute('receive', @username, @password, :last_retrieved_id => last_retrieved_id)
      response.extend(TextMagic::API::Response::Receive)
    end

    # Executes a delete_reply command and returns a hash with a list of deleted
    # message ids if successful, otherwise it raises a TextMagic::API::Error.
    # The returned hash will be extended with custom reader methods defined in module
    # TextMagic::API::Response::DeleteReply.
    #
    # This method accepts any positive number of ids specified as an array
    # or as a list of arguments.
    #
    # Example usage:
    #
    #  api.delete_reply('314159')
    #  # => { 'deleted' => ['314159'] }
    #  api.delete_reply('314159', '271828')
    #  api.delete_reply(['314159', '271828'])
    #
    # Using custom accessors:
    #
    #  response = api.delete_reply('314159', '271828')
    #  response.deleted
    #  # => ['314159', '271828']
    def delete_reply(*ids)
      ids.flatten!
      raise TextMagic::API::Error.new(4, 'Insufficient parameters') if ids.empty?
      response = Executor.execute('delete_reply', @username, @password, :ids => ids.join(','))
      response.extend(TextMagic::API::Response::DeleteReply)
    end
  end
end
