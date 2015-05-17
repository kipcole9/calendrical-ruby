require 'spec_helper'

describe Calendar::Julian do
  it 'can check equality between Gregorian and Julian dates' do
    expect(Calendar::Gregorian::Date[2015,5,5]).to eq(Calendar::Julian::Date[2015,4,22])
  end
end