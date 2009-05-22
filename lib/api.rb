module TextMagic

  class API

    def initialize(username, password)
      @username = username
      @password = password
    end

    def account
      response = Executor.execute('account', @username, @password)
      response['balance'] = response['balance'].to_f
      response
    end

    def send(text, *args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      phones = args.flatten.join(',')
      Executor.execute('send', @username, @password, options.merge(:text => text, :phone => phones))
    end

    def message_status(*ids)
      Executor.execute('message_status', @username, @password, :ids => ids.flatten.join(','))
    end

    def receive
      Executor.execute('receive', @username, @password)
    end

    def delete_reply(*ids)
      Executor.execute('delete_reply', @username, @password, :ids => ids.flatten.join(','))
    end
  end
end
