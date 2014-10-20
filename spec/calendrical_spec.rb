require 'spec_helper'

describe Calendrical do
  it 'has a version number' do
    expect(Calendrical::VERSION).not_to be nil
  end

  it 'creates a valid Gregorian date' do
    expect(GregorianDate[2014,10,11].to_date).to eq(Date.new(2014,10,11))
  end
  
  it 'knows that AD 400 is a leap year' do
    expect(GregorianYear[400].leap_year?).to be_truthy
  end
  
  it 'knows that AD 1000 is not a leap year' do
    expect(GregorianYear[1000].leap_year?).to be_falsey
  end
  
  it 'knows that AD 2000 is a leap year' do
    expect(GregorianYear[2000].leap_year?).to be_truthy
  end
  
  it 'knows that January 1st + one day is January 2nd' do
    expect(GregorianDate[2010,1,1] + 1).to eq(GregorianDate[2010,1,2])
  end
  
  it 'knows that the day before January 1st is December 31st' do
    expect(GregorianDate[2010,1,1] - 1).to eq(GregorianDate[2009,12,31])
  end
  
  it 'knows the fixed date of January 1, 2010' do
    expect(GregorianDate[2010,1,1].fixed).to eq(733773)
  end
  
end
