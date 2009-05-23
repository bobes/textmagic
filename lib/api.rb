module TextMagic

  class API

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
    #
    # Example usage:
    #
    #  api.account
    #  # => { 'balance' => 3.14 }
    def account
      response = Executor.execute('account', @username, @password)
      response['balance'] = response['balance'].to_f
      response
    end

    # Executes a send command and returns a hash with message ids, sent text and
    # number of parts if successful, otherwise it raises a TextMagic::API::Error.
    # This method accepts a single phone number as well as a list of multiple
    # phone numbers and additional options.
    # The optional parameters you can specify in the options argument are:
    # * unicode: accepted values are true, false, 0 and 1, defaults to 0
    # * max_length: accepted values are nil, 1, 2 and 3, defaults to nil
    #
    # Example usage:
    #
    #  api.send('Hi Vilma', '441234567890')
    #  # => { 'message_id' => { '314159' => '441234567890' }, 'sent_text' => 'Hi Vilma', 'parts_count' => 1 }
    #  api.send(text, phone, :unicode => true)
    #  api.send(text, phone1, phone2, :max_length => 2)
    #  api.send(text, [phone1, phone2])
    def send(text, *args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      phones = args.flatten.join(',')
      Executor.execute('send', @username, @password, options.merge(:text => text, :phone => phones))
    end

    # Executes a message_status command and returns a hash with states of
    # messages for specified ids if successful, otherwise it raises a
    # TextMagic::API::Error.
    # This method accepts any positive number of ids specified as an array
    # or as a list of arguments
    #
    # Example usage:
    #
    #  api.message_status('314159')
    #  # => { '314159' => { 'text' => 'Hi Vilma', 'status' => 'd' , 'created_time' => '1242979818', 'reply_number' => '447624800500', 'completed_time': null, 'credits_cost': '0.5' } }
    #  api.message_status('314159', '271828')
    #  api.message_status(['314159', '271828'])
    def message_status(*ids)
      Executor.execute('message_status', @username, @password, :ids => ids.flatten.join(','))
    end

    # Executes a receive command and returns a hash with unread messages
    # if successful, otherwise it raises a TextMagic::API::Error.
    #
    # Example usage:
    #
    #  api.receive
    #  # => { 'messages' => [{ 'message_id' => '1414213', 'from' => '441234567890', 'timestamp' => 1242987175, 'text' => 'Hi Fred!' }], 'unread' => 0 }
    def receive
      Executor.execute('receive', @username, @password)
    end

    # Executes a delete_reply command and returns a hash with a list of deleted
    # message ids if successful, otherwise it raises a TextMagic::API::Error.
    # This method accepts any positive number of ids specified as an array
    # or as a list of arguments.
    #
    # Example usage:
    #
    #  api.delete_reply('314159')
    #  # => { 'deleted' => ['314159'] }
    #  api.delete_reply('314159', '271828')
    #  api.delete_reply(['314159', '271828'])
    def delete_reply(*ids)
      Executor.execute('delete_reply', @username, @password, :ids => ids.flatten.join(','))
    end
  end
end
