require 'spec_helper'

require 'ext/numeric'

describe Numeric,"#html_formatted" do

  it "returns small number as strings" do
    expect(0.html_formatted).to eq "0"
  end

  it "groups large number by groups of three" do
    expect(1234567890.html_formatted).to eq "1&#8239;234&#8239;567&#8239;890"
  end

  it 'formats floats as integers' do
    expect(1234.5678.html_formatted).to eq "1&#8239;234"
  end

end
