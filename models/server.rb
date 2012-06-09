require 'open-uri'

class Server
    include DataMapper::Resource

    has n, :games
    has n, :accounts
    has n, :users, :through => :accounts

    property :id,                Serial
    property :name,              String, :length => 255
    property :url,               String, :length => 255
    property :xlogurl,           String, :length => 255
    property :xloglastmodified,  String, :default => "Sat Jan 01 00:00:00 UTC 2000"
    property :variant,           String
    property :xlogcurrentoffset, Integer
    property :configfileurl,     String, :length => 255

    # open the rc file for the user and return true if the regexp is found
    def verify_user(user, regexp)
        open(configfileurl.gsub("random_user", CGI::escape(user))) do |f|
            f.each do |line|
              return true if line.strip.match regexp
            end
        end
        return false;
    end

    def display_name
        url+" ("+name+")"
    end

    def dumplog_link(game)
      case @url
      when "un.nethack.nu"
        return "http://un.nethack.nu/user/#{game.name}/dumps/#{game.name}.#{game.endtime}.txt.html"
      when "nethack.alt.org"
        return "http://alt.org/nethack/userdata/#{game.name[0..0]}/#{game.name}/dumplog/#{game.starttime}.nh343.txt"
      when "grunthack.org"
        return "http://grunthack.org/userdata/#{game.name[0..0]}/#{game.name}/dumplog/#{game.starttime}.gh020.txt"
      when "nethack.fi"
        return "http://nethack.fi/userdata/#{game.name}/dumplog/#{game.starttime}.nh343.txt"
      when "acehack.us"
        return "http://acehack.us/userdata/#{game.name}/dumplog/#{game.starttime}"
      else
        return nil
      end
    end
end

