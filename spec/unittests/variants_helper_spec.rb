require 'spec_helper'

require 'helper'

describe 'variant helper methods' do
  it "return the correct xlogfile designator" do
    (helper_get_variant_for 'does not exist').should be_nil

    (helper_get_variant_for 'NetHack 3.4.3').should == "3.4.3"
    # choose a variant unlikely to be changed again
    (helper_get_variant_for 'sporkhack').should == "0.6.3"

    (helper_get_variant_for 'vanilla').should == "3.4.3"
    (helper_get_variant_for 'oldhack').should == "NH-1.3d"
  end
end
