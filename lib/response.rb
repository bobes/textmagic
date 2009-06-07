require 'ostruct'

module TextMagic

  class API

    class Response

      def self.account(hash)
        response = OpenStruct.new(hash)
        response.balance = response.balance.to_f
        response.balance = response.balance.to_i if response.balance % 1 == 0
        response
      end

      def self.send(hash, single)
        response = nil
        if single
          response = hash['message_id'].keys.first.dup
        else
          response = hash['message_id'].invert
        end
        metaclass = class << response; self; end
        metaclass.send :attr_accessor, :sent_text, :parts_count, :message_id
        response.sent_text = hash['sent_text']
        response.parts_count = hash['parts_count']
        response.message_id = hash['message_id']
        response
      end

      def self.message_status(hash, single)
        response = {}
        hash.each do |message_id, message_hash|
          status = message_hash['status'].dup
          metaclass = class << status; self; end
          metaclass.send :attr_accessor, :text, :credits_cost, :reply_number, :message_status, :created_time, :completed_time
          status.text = message_hash['text']
          status.credits_cost = message_hash['credits_cost']
          status.reply_number = message_hash['reply_number']
          status.message_status = message_hash['message_status']
          status.created_time = Time.at(message_hash['created_time'].to_i) if message_hash['created_time']
          status.completed_time = Time.at(message_hash['completed_time'].to_i) if message_hash['completed_time']
          response[message_id] = status
        end
        single ? response.values.first : response
      end

      def self.receive(hash)
        response = hash['messages'].collect do |message_hash|
          message = "#{message_hash['from']}: #{message_hash['text']}"
          metaclass = class << message; self; end
          metaclass.send :attr_accessor, :timestamp, :message_id, :text, :from
          message.text = message_hash['text']
          message.from = message_hash['from']
          message.message_id = message_hash['message_id']
          message.timestamp = Time.at(message_hash['timestamp'].to_i)
          message
        end
        metaclass = class << response; self; end
        metaclass.send :attr_accessor, :unread
        response.unread = hash['unread']
        response
      end
    end
  end
end
