module TextMagic

  class API

    module Response

      module Account

        def balance
          self['balance'].to_f
        end
      end

      module Send

        def message_id(phone = nil)
          @message_id_hash ||= self['message_id'].invert
          phone ? @message_id_hash[phone] : @message_id_hash
        end

        def message_ids
          @message_ids ||= message_id.values.sort
        end

        def sent_text
          self['sent_text']
        end

        def parts_count
          self['parts_count'].to_i
        end
      end

      module MessageStatus

        def text(message_id)
          self[message_id]['text']
        end

        def status(message_id)
          self[message_id]['status']
        end

        def reply_number(message_id)
          self[message_id]['reply_number']
        end

        def credits_cost(message_id)
          self[message_id]['credits_cost']
        end

        def created_time(message_id)
          return nil unless self[message_id]['created_time']
          Time.at self[message_id]['created_time'].to_i
        end

        def completed_time(message_id)
          return nil unless self[message_id]['completed_time']
          Time.at self[message_id]['completed_time'].to_i
        end
      end

      module Receive

        def unread
          self['unread']
        end

        def messages
          @messages ||= self['messages'].inject({}) { |hash, message| hash[message['message_id']] = message; hash }
          @messages
        end

        def message_ids
          @message_ids ||= messages.keys.sort
        end

        def message(message_id)
          messages[message_id]
        end

        def timestamp(message_id)
          return nil unless messages[message_id]['timestamp']
          Time.at messages[message_id]['timestamp']
        end

        def text(message_id)
          messages[message_id]['text']
        end

        def from(message_id)
          messages[message_id]['from']
        end
      end

      module DeleteReply

        def deleted
          self['deleted']
        end
      end
    end
  end
end
