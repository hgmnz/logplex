class FakeLogplex
  class Message

    attr_reader :message, :token

    def initialize(opts)
      @message = opts[:message]
      @token   = opts[:token]
    end

    def self.from_syslog(syslog_message)
      messages = []
      anchor = 0
      until anchor >= syslog_message.length
        new_anchor, opts = extract_message(syslog_message, anchor)
        raise "same" if anchor == new_anchor
        anchor = new_anchor
        messages << new(opts)
      end
      messages
    end

    def self.extract_message(syslog_message, anchor)
      start = anchor
      pos = start
      until (char = syslog_message[pos+=1] and char == ' ') || pos >= syslog_message.length
        bytes = syslog_message[anchor..pos].to_i
      end
      anchor = pos+=1
      until (char = syslog_message[pos+=1] and char == ' ') || pos >= syslog_message.length
        facility_and_priority = syslog_message[anchor..pos]
      end
      anchor = pos+1
      until (char = syslog_message[pos+=1] and char == ' ') || pos >= syslog_message.length
        if char == ' '
          time = DateTime.parse(syslog_message[anchor..pos])
        end
      end
      anchor = pos+1
      until (char = syslog_message[pos+=1] and char == ' ') || pos >= syslog_message.length
        host = syslog_message[anchor..pos]
      end
      anchor = pos+1
      until (char = syslog_message[pos+=1] and char == ' ') || pos >= syslog_message.length
        token = syslog_message[anchor..pos]
      end
      anchor = pos+1
      until (char = syslog_message[pos+=1] and char == ' ') || pos >= syslog_message.length
        process = syslog_message[anchor..pos]
      end
      anchor = pos+1
      until (char = syslog_message[pos+=1] and char == ' ') || pos >= syslog_message.length
        message_id = syslog_message[anchor..pos]
      end
      anchor = pos+1
      limit = start + bytes + bytes.to_s.length
      message = syslog_message[anchor..limit]
      [limit + 1, { message: message, token: token }]
    end
  end

  @@tokens = []
  @@received_messages = []
  @@requests_received = 0

  def call(env)
    @@requests_received += 1

    message        = env['rack.input'].read
    method         = env['REQUEST_METHOD']
    path           = env['PATH_INFO']
    content_type   = env['CONTENT_TYPE']
    content_length = env['CONTENT_LENGTH'].to_i
    auth           = env['HTTP_AUTHORIZATION']

    _, auth_token = auth.split(' ')
    user, pass = Base64.decode64(auth_token).split(':')
    if @@tokens.include?(pass)
      if (method == 'POST' &&
          path == '/logs' &&
          content_type == 'application/logplex-1' &&
          content_length == message.length)

        @@received_messages << Message.from_syslog(message)
        @@received_messages.flatten!
        [200, {}, []]
      else
        raise "wat"
      end
    else
      [401, {}, []]
    end
  end

  def self.has_received_message?(message)
    @@received_messages.map(&:message).include? message
  end

  def self.register_token(token)
    @@tokens << token
  end

  def self.clear!
    @@tokens = []
    @@received_messages = []
    @@requests_received = 0
  end

  def self.requests_received
    @@requests_received
  end
end

