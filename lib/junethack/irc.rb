#!/usr/local/bin/ruby

#mainly stolen from http://snippets.dzone.com/posts/show/1785

require "socket"

# Don't allow use of "tainted" data by potentially dangerous operations

$SAFE=1

# The irc class, which talks to the server and holds the main event loop
class IRC
    def initialize(server, port, nick, channel)
        @server = server
        @port = port
        @nick = nick
        @channel = channel
    end
    def send(s)
        # Send a message to the irc server and print it to the screen
        puts "--> #{s}"
        @irc.send "#{s}\n", 0 
    end
    def connect()
        # Connect to the IRC server
        @irc = TCPSocket.open(@server, @port)
        send "USER blah blah blah :blah blah"
        send "NICK #{@nick}"
        send "JOIN #{@channel}"
    end
    def say text
            send "PRIVMSG #{@channel} :#{text}"
    end
    def handle_server_input(s)
        # This isn't at all efficient, but it shows what we can do with Ruby
        # (Dave Thomas calls this construct "a multiway if on steroids")
        case s.strip
            when /^PING :(.+)$/i
                puts "[ Server ping ]"
                send "PONG :#{$1}"
            when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s.+\s:[\001]PING (.+)[\001]$/i
                puts "[ CTCP PING from #{$1}!#{$2}@#{$3} ]"
                send "NOTICE #{$1} :\001PING #{$4}\001"
            when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s.+\s:[\001]VERSION[\001]$/i
                puts "[ CTCP VERSION from #{$1}!#{$2}@#{$3} ]"
                send "NOTICE #{$1} :\001VERSION Ruby-irc v0.042\001"
=begin
            when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s(#\w+)\s:(.+)$/i
            
                c = $5.split
                cmd = c.first
                args = c[1..-1]
                #@botcommands[cmd].call *args
            else
                puts s
=end
        end
    end

    def main_loop()
        # Just keep on truckin' until we disconnect
        Thread.start do
            while true
                ready = select([@irc], nil, nil, nil)
                if ready
                    return if @irc.eof
                    s = @irc.gets
                    handle_server_input(s)
                end
            end
        end   
    end
end
