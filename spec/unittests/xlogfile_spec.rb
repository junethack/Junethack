require 'spec_helper'

require 'parse'

describe XLog do
  it "should parse a single colon separated xlogfile line" do
    parsed = XLog.parse_xlog "version=3.4.3:points=1337:name=bhaak:death=killed by an orc"
    parsed['version'].should == "3.4.3"
    parsed['points'].should == "1337"
    parsed['name'].should == "bhaak"
    parsed['death'].should == "killed by an orc"
    parsed['does_not_exists'].should be_nil
  end

  it "should parse a single tab separated xlogfile line" do
    parsed = XLog.parse_xlog "version=3.6.0	points=1337	name=bhaak	death=killed by a newt	colon=has:colon"
    parsed['version'].should == "3.6.0"
    parsed['points'].should == "1337"
    parsed['name'].should == "bhaak"
    parsed['death'].should == "killed by a newt"
    parsed['colon'].should == "has:colon"
    parsed['does_not_exists'].should be_nil
  end

  it "should not split on a = character in value field" do
    parsed = XLog.parse_xlog "version=3.4.3:points=0:name=player:death=killed by a monster called something = something:flags=0x0"
    parsed['version'].should == "3.4.3"
    parsed['points'].should == "0"
    parsed['death'].should == "killed by a monster called something = something"
  end

  describe "#parse_header" do
    it "splits HTTP headers into a Hash" do
      headers = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n"
      hash = XLog.parse_header headers
      hash.size.should == 2
      hash["Content-Type"].should == 'text/plain'
    end

    it "parses HTTP headers with redirects" do
      headers = "HTTP/1.1 301 Moved Permanently\r\nDate: Mon, 01 Jan 2000 00:00:00 GMT\r\n\r\nHTTP/1.1 200 OK\r\nDate: Mon, 01 Jan 2016 00:00:00 GMT\r\n\r\n"
      hash = XLog.parse_header headers
      hash.size.should == 3
      hash["Date"].should == 'Mon, 01 Jan 2016 00:00:00 GMT'
    end
  end
end
