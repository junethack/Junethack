require 'rubygems'
require 'json'
require 'time'

require 'singleton'

Dir.mkdir('trace') unless File.exists?('trace')

class XLog
  include Singleton

  def self.parse_xlog xlog
    # xlogfiles look like key1=value1:key2=value2:...
    # xlogfiles from NetHack 3.6.0 are tab separated
    # there are no : in the value fields but = may appear
    tabs = xlog.count "\t"
    colons = xlog.count ":"
    separator = tabs > colons ? "\t" : ":"
    Hash[xlog.chomp.split(separator).map{ |e| e.split("=", 2)}].tap { |hash|
      hash.delete('id')
    }
  end

  def self.fetch_header xlog_url
    if ENV['JUNETHACK_TRACE']
      head = %x{ curl -L --trace-time --trace-ascii "trace/#{Time.new.iso8601}_trace_head.log" -I -s #{xlog_url}}
    else
      head = %x{ curl -L -I -s #{xlog_url}}
      if head.start_with?('HTTP/2 405')
        # web server not supporting HEAD
        puts "workaround for #{xlog_url}"
        head = %x{ curl -L -i -s #{xlog_url}}.split("\r\n\r\n").first
      end
      head
    end
  end

  def self.parse_header raw_header
    Hash[raw_header.split(/\n/).map{|e| e.strip.split(/\: ?/, 2)}.reject(&:empty?).map {|a,b| [a.downcase,b] }]
  end

  def self.fetch_from_xlog xlog_url, startp, endp
    return false if startp.to_i >= endp.to_i-1

    if ENV['JUNETHACK_TRACE']
      time = Time.new.iso8601
      xlogdiff = %x{ curl -L --trace-time --trace-ascii "trace/#{time}_trace.log" -s -r #{startp}-#{endp.to_i-1} #{xlog_url}}
      File.open("trace/#{time}_xlogfile.txt", 'w') {|f| f.write(xlogdiff) }
    else
      xlogdiff = %x{ curl -L -s -r #{startp}-#{endp.to_i-1} #{xlog_url}}
    end
    StringIO.new xlogdiff
  end
end

class Hash
  def to_xlog
    self.reject {|key, value| [:id, :user_id].include?(key) || value.to_s.empty? }
      .map{|key, value| "#{key}=#{value}"}.join(":")
  end
end
