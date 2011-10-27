# encoding: utf-8

module TextMagic

  class API

    module Charset

      GSM_CHARSET = "@£$¥èéùìòÇ\nØø\rÅåΔ_ΦΓΛΩΠΨΣΘΞ\e\f^{}\\[~]|€ÆæßÉ !\"#¤%&'()*+,-./0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüà".scan(/./u)
      ESCAPED_CHARS = "{}\\~[]|€"

      # Returns +true+ if the supplied text contains only characters from
      # GSM 03.38 charset, otherwise it returns +false+.
      def is_gsm(text)
        text.scan(/./u).each { |c| return false unless GSM_CHARSET.include?(c) }
        true
      end

      # Returns +true+ if the supplied text contains characters outside of
      # GSM 03.38 charset, otherwise it returns +false+.
      def is_unicode(text)
        !is_gsm(text)
      end

      def real_length(text, unicode)
        text.size + (unicode ? 0 : text.scan(/[\{\}\\~\[\]\|€]/).size)
      end
    end
  end
end
