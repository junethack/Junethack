require 'rubygems'
require 'json'

require 'singleton'

class XLog
    include Singleton

    def self.parse_xlog xlog
        puts "#{xlog}"
        Hash[xlog.chomp.split(":").map{|e| e.split("=")}]
    end

    def self.fetch_header xlog_url
        %x{ curl -I -s #{xlog_url}}
    end 

    def self.parse_header raw_header
        Hash[raw_header.split(/\n/).map{|e| e.chomp.split(/\: ?/, 2)}]
    end
    
    def self.fetch_from_xlog xlog_url, startp, endp
        puts
        return false if startp.to_i >= endp.to_i
        %x{ curl -s -r #{startp}-#{endp} #{xlog_url}}.split("\n").map{|g| XLog.parse_xlog(g)}
    end
    private 
    def self.instance
    end
end

class Hash
    def to_xlog            #expects sane input
        map{|k, v| "#{k.to_s}=#{v.to_s}"}.join(":")
    end    
end
