require 'yaml'
require 'socket'

module PushUtils
  Config = YAML.load(IO.read("#{Rails.root}/config/push_server.yml"))[ENV['RAILS_ENV']]
  Separator = ' '
  EndOfHeader = ' >> '
  EndOfLine = "\n"

  def push_to_user(u, lines)
    push([u.id], lines) if u
  end

  def push_to_room(r, lines)
    push(r.user_ids, lines) if r
  end
    
  def push_to_topic(t, lines)
    push(t.user_ids, lines) if t
  end
  
  def push(target_ids, lines)
    return if target_ids.empty?
    begin
      @socket = TCPSocket.new(Config[:host], Config[:port])
      header = target_ids.join(Separator) + EndOfHeader
      lines.each{|line| @socket.print(header + line + EndOfLine) }
      @socket.flush
    rescue Exception => e
      logger.error e
    ensure
      @socket.close if @socket and !@socket.closed?
    end
  end
end
