require 'spec_helper'

require 'parse'

describe XLog do
  it "should parse a single xlogfile line" do
    parsed = XLog.parse_xlog "version=3.4.3:points=1337:name=bhaak:death=killed by an orc"
    parsed['version'].should == "3.4.3"
    parsed['points'].should == "1337"
    parsed['name'].should == "bhaak"
    parsed['death'].should == "killed by an orc"
    parsed['does_not_exists'].should be_nil
  end

  it "should not split on a = character in value field" do
    parsed = XLog.parse_xlog "version=3.4.3:points=0:name=player:death=killed by a monster called something = something:flags=0x0"
    parsed['version'].should == "3.4.3"
    parsed['points'].should == "0"
    parsed['death'].should == "killed by a monster called something = something"
  end

  it "should split HTTP headers into a Hash" do
    headers = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n"
    hash = XLog.parse_header headers
    hash.size.should == 2
    hash["Content-Type"].should == 'text/plain'
  end
end
