# TextMagic

`textmagic` gem is a Ruby interface to the [TextMagic](http://www.textmagic.com)
Bulk SMS Gateway.
It can be used to easily integrate SMS features into your application.
It supports sending messages, receiving replies and more. You need to have
a valid [TextMagic](http://www.textmagic.com) account to use this gem.

To learn more about the TextMagic Bulk SMS Gateway, visit the official
[API documentation](http://api.textmagic.com)
or [Google group](http://groups.google.com/group/textmagic-api).

This document will give you a good overview of the gem's functionality. For
more information consult the detailed [documentation](http://tuzinsky.com/textmagic/rdoc/).


## Basic usage

First create an API instance with your credentials:

    api = TextMagic::API.new(username, password)

These credentials will be used in all requests to the SMS gateway.


### Account balance

Check your account's balance:

    api.account.balance
    # => 314.15


### Sending messages

To send a message to a single phone number, run:

    api.send 'Hi Wilma!', '999314159265'

You can even specify multiple phone numbers:

    api.send 'Hello everybody', '999314159265', '999271828182'

Unicode messages are supported as well:

    api.send 'Вильма Привет!', '999314159265'

Long messages will be split to up to 3 parts. To limit maximum number
of parts, specify an optional `max_length` parameter:

    api.send 'Very very long message...', '999314159265', :max_length => 2

If you want to postpone message delivery, specify a `send_time` parameter:

    api.send 'Two hours later', '999314159265', :send_time => Time.now.to_i + 7200


### Checking sent message status

If you want to check sent message status, you have to use `message_id`
returned in response to `send` command.

    api.send('Hi Wilma!', '999314159265')
    # => '141421'
    status = api.message_status('141421')
    # => 'd'
    status.completed_time
    # => Fri May 22 10:10:18 +0200 2009

You can also check statuses of several messages at once, in which case
you'll get a hash with message ids as keys:

    api.send('Hi Wilma!', '999314159265', '999271828182').message_id
    # => { '999314159265' => '141421', '999271828182' => '173205' }
    statuses = api.message_status('141421', '173205')
    # => { '141421' => 'r', '173205' => 'd' }
    statuses['173205'].created_time
    # => Thu May 28 16:41:45 +0200 2009

**It is strongly recommended to setup callbacks to receive updates on message status
instead of using this method. Learn more about callbacks at
[TextMagic API](http://api.textmagic.com/https-api) site**


### Receiving replies

To receive all available replies, run:

    replies = api.receive
    # => ['999271828182: Hello Fred!', '999314159265: Good day!']
    replies.first.text
    # => 'Hello Fred!'
    replies.last.from
    # => '999314159265'
    replies.last.message_id
    # => '178082'

To prevent receiving old replies again, supply `last_retrieved_id` argument:

    api.receive('178082')
    # => []

**It is strongly recommended to setup callbacks to receive replies instead of
using this method. Learn more about callbacks at
[TextMagic API](http://api.textmagic.com/https-api) site**


### Deleting retrieved replies

After you retrieve replies, you can delete them from server by running:

    api.delete_reply '141421', '178082'
    # => true


## Command-line utility

The `textmagic` gem also features a handy command-line utility. It gives you access
to all of the gem's features. Run

    tm

from your console to see help on its usage.

*Note: This has only been tested on a Mac with Ruby 1.8.7 and 1.9.1. If you have any troubles using this gem, contact the author (or submit a patch).*


## Copyright

Copyright (c) 2009-2012 Vladimír Bobeš Tužinský. See LICENSE for details.
