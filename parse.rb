require 'rubygems'
require 'json'
require 'time'

require 'singleton'

Dir.mkdir('trace') unless File.exists?('trace')

class XLog
    include Singleton

    def self.parse_xlog xlog
        #puts "#{xlog}"
        Hash[xlog.chomp.split(":").map{|e| e.split("=")}]
    end

    def self.fetch_header xlog_url
        %x{ curl --trace-time --trace-ascii "trace/#{Time.new.iso8601}_trace_head.log" -I -s #{xlog_url}}
    end 

    def self.parse_header raw_header
        Hash[raw_header.split(/\n/).map{|e| e.chomp.split(/\: ?/, 2)}]
    end
    
    def self.fetch_from_xlog xlog_url, startp, endp
        return false if startp.to_i >= endp.to_i-1
        time = Time.new.iso8601
        xlogdiff = %x{ curl --trace-time --trace-ascii "trace/#{time}_trace.log" -s -r #{startp}-#{endp.to_i-1} #{xlog_url}}
        File.open("trace/#{time}_xlogfile.txt", 'w') {|f| f.write(xlogdiff) }
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
