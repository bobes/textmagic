module TextMagic

  class API

    # Used to cleanup response hash and extend it with custom reader methods.
    #
    # === Account response hash
    #
    # When extended, it
    # * converts the +balance+ value to +float+ and
    # * adds a reader method +balance+.
    #
    # === Send response hash
    #
    # When extended, it
    # * inverts the +message_id+ hash and puts it in +message_id_hash+,
    # * adds an array of ids to +message_ids+,
    # * adds reader methods +message_id_hash+, +message_ids+, +sent_text+ and
    #   +parts_count+ to the hash.
    # * adds a reader method +message_id+, which returns a +message_id+ for
    #   a given phone number, or the first message_id if no phone number
    #   is specified.
    #
    # === Message status response hash
    #
    # When extended, it
    # * converts the +credits_cost+ value to +float+,
    # * converts the +created_time+ and +completed_time+ values to +Time+,
    # * adds reader methods +text+, +status+, +reply_number+, +credits_cost+,
    #   +created_time+ and +completed_time+ to all values of the hash.
    #
    # === Receive status response hash
    #
    # When extended, it
    # * converts the +timestamp+ value to +Time+,
    # * adds reader methods +messages+ and +unread+ to the hash
    # * adds reader methods +message_id+, +timestamp+, +text+ and +from+
    #   to all members of the +messages+ array.
    #
    # === Delete reply response hash
    #
    # When extended, it
    # * adds a reader method +deleted+.
    module Response

      module Account #:nodoc: all

        def self.extended(base)
          return unless base.is_a?(Hash)
          base['balance'] = base['balance'].to_f if base['balance']
        end

        def balance
          self['balance']
        end
      end

      module Send #:nodoc: all

        def self.extended(base)
          return unless base.is_a?(Hash) && base['message_id']
          base['message_ids'] = base['message_id'].keys.sort
          base.merge! base.delete('message_id').invert
        end

        %w(message_ids sent_text parts_count).each do |method|
          module_eval <<-EOS
          def #{method}
            self['#{method}']
          end
          EOS
        end

        def message_id(phone = nil)
          phone ? self[phone] : self['message_ids'].first
        end
      end

      module MessageStatus #:nodoc: all

        def self.extended(base)
          return unless base.is_a?(Hash)
          base.values.each do |status|
            status['credits_cost'] = status['credits_cost'].to_f if status['credits_cost']
            status['created_time'] = Time.at(status['created_time'].to_i) if status['created_time']
            status['completed_time'] = Time.at(status['completed_time'].to_i) if status['completed_time']
            status.extend Status
          end
        end

        module Status

          %w(text status reply_number credits_cost created_time completed_time).each do |method|
            module_eval <<-EOS
            def #{method}
              self['#{method}']
            end
            EOS
          end
        end
      end

      module Receive #:nodoc: all

        def self.extended(base)
          return unless base.is_a?(Hash) && base['messages']
          base['message_ids'] = base['messages'].collect { |message| message['message_id'] }.sort
          base['messages'].each do |message|
            message['timestamp'] = Time.at(message['timestamp'].to_i) if message['timestamp']
            message.extend Message
          end
        end

        %w(messages message_ids unread).each do |method|
          module_eval <<-EOS, __FILE__, __LINE__ + 1
          def #{method}
            self['#{method}']
          end
          EOS
        end

        module Message

          %w(message_id timestamp text from).each do |method|
            module_eval <<-EOS
            def #{method}
              self['#{method}']
            end
            EOS
          end
        end
      end

      module DeleteReply #:nodoc: all

        def deleted
          self['deleted']
        end
      end
    end
  end
end
