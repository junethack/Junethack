require 'rubygems'
require 'json'
require 'time'

require 'singleton'

Dir.mkdir('trace') unless File.exists?('trace')

class XLog
    include Singleton

    def self.parse_xlog xlog
        #puts "#{xlog}"
        # xlogfiles look like key1=value1:key2=value2:...
        # there are no : in the value fields but = may appear
        Hash[xlog.chomp.split(":").map{|e| e.split("=", 2)}]
    end

    def self.fetch_header xlog_url
        if ENV['JUNETHACK_TRACE']
            %x{ curl --trace-time --trace-ascii "trace/#{Time.new.iso8601}_trace_head.log" -I -s #{xlog_url}}
        else
            %x{ curl -I -s #{xlog_url}}
        end
    end

    def self.parse_header raw_header
        Hash[raw_header.chomp.split(/\n/).map{|e| e.chomp.split(/\: ?/, 2)}]
    end
    
    def self.fetch_from_xlog xlog_url, startp, endp
        return false if startp.to_i >= endp.to_i-1
        if ENV['JUNETHACK_TRACE']
            time = Time.new.iso8601
            xlogdiff = %x{ curl --trace-time --trace-ascii "trace/#{time}_trace.log" -s -r #{startp}-#{endp.to_i-1} #{xlog_url}}
            File.open("trace/#{time}_xlogfile.txt", 'w') {|f| f.write(xlogdiff) }
        else
            xlogdiff = %x{ curl -s -r #{startp}-#{endp.to_i-1} #{xlog_url}}
        end
        StringIO.new xlogdiff
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
