require 'spec_helper'

describe Julian do
  it 'can check equality between Gregorian and Julian dates' do
    expect(Gregorian::Date[2015,5,5]).to eq(Julian::Date[2015,4,22])
  end
end