require 'spec_helper'

describe Server, '.display_name' do
  it "should display url and variant info" do
    server = Server.new(:variant => 'vanilla',
             :name => 'nao',
             :url => 'nethack.alt.org')

    server.display_name.should == 'nethack.alt.org (vanilla)'
  end
end
