require 'spec_helper'

require 'helper'

describe 'variant helper methods' do
  it "return the correct xlogfile designator" do
    expect(helper_get_variant_for 'does not exist').to be_nil

    expect(helper_get_variant_for 'NetHack 3.4.3').to eq "3.4.3"
    # choose a variant unlikely to be changed again
    expect(helper_get_variant_for 'grunthack').to eq "0.2.1"

    expect(helper_get_variant_for 'vanilla').to eq "3.4.3"
    expect(helper_get_variant_for 'oldhack').to eq "NH-1.3d"

    $variant_order.each {|variant|
        expect($variants_mapping[variant]).to_not be_nil, "$variants_mapping(#{variant}) was nil"
    }
  end
end
