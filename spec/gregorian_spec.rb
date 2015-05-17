require 'spec_helper'

describe Calendar::Gregorian do
  it 'creates a valid Gregorian date' do
    expect(Calendar::Gregorian::Date[2014,10,11].to_date).to eq(Date.new(2014,10,11))
  end
  
  it 'can also create dates with module method' do
    expect(Calendar::Gregorian::Date(2014,10,11).to_date).to eq(Date.new(2014,10,11))  
  end
  
  it 'knows that AD 400 is a leap year' do
    expect(Calendar::Gregorian::Year[400].leap_year?).to be_truthy
  end
  
  it 'knows that AD 1000 is not a leap year' do
    expect(Calendar::Gregorian::Year[1000].leap_year?).to be_falsey
  end
  
  it 'knows that AD 2000 is a leap year' do
    expect(Calendar::Gregorian::Year[2000].leap_year?).to be_truthy
  end
  
  it 'knows that January 1st + one day is January 2nd' do
    expect(Calendar::Gregorian::Date[2010,1,1] + 1).to eq(Calendar::Gregorian::Date[2010,1,2])
  end
  
  it 'knows that the day before January 1st is December 31st' do
    expect(Calendar::Gregorian::Date[2010,1,1] - 1).to eq(Calendar::Gregorian::Date[2009,12,31])
  end
  
  it 'knows that 2017 is two years after 2015' do
    expect(Calendar::Gregorian::Year[2015] + 2).to eq(Calendar::Gregorian::Year[2017])    
  end
  
  it 'knows the fixed date of January 1, 2010' do
    expect(Calendar::Gregorian::Date[2010,1,1].fixed).to eq(733773)
  end 
  
  it 'knows the quarters of 2010' do
    expect(Calendar::Gregorian::Year[2010].quarter(1).range).to eq(Calendar::Gregorian::Date.new(2010,1,1)..Calendar::Gregorian::Date.new(2010,3,31))
    expect(Calendar::Gregorian::Year[2010].quarter(2).range).to eq(Calendar::Gregorian::Date.new(2010,4,1)..Calendar::Gregorian::Date.new(2010,6,30))
    expect(Calendar::Gregorian::Year[2010].quarter(3).range).to eq(Calendar::Gregorian::Date.new(2010,7,1)..Calendar::Gregorian::Date.new(2010,9,30))
    expect(Calendar::Gregorian::Year[2010].quarter(4).range).to eq(Calendar::Gregorian::Date.new(2010,10,1)..Calendar::Gregorian::Date.new(2010,12,31))
  end
  
  it 'knows the months of a quarter' do
    expect(Calendar::Gregorian::Year[2010].quarter(2).month(1).range).to eq(Calendar::Gregorian::Date.new(2010,4,1)..Calendar::Gregorian::Date.new(2010,4,30))    
  end
  
  it 'knows the weeks of a year' do
    expect(Calendar::Gregorian::Year[2015].week(20).range).to eq(Calendar::Gregorian::Date.new(2015,5,14)..Calendar::Gregorian::Date.new(2015,5,20))    
  end
  
  it 'knows that there is a short week 53 since a year doesn''t divide into 7' do
    expect(Calendar::Gregorian::Year[2014].week(53).range).to eq(Calendar::Gregorian::Date.new(2014,12,31)..Calendar::Gregorian::Date.new(2014,12,31))
  end
  
  it 'knows the months of 2010' do
    expect(Calendar::Gregorian::Year[2010].month(1).range).to eq(Calendar::Gregorian::Date.new(2010,1,1)..Calendar::Gregorian::Date.new(2010,1,31))
    expect(Calendar::Gregorian::Year[2010].month(2).range).to eq(Calendar::Gregorian::Date.new(2010,2,1)..Calendar::Gregorian::Date.new(2010,2,28))
    expect(Calendar::Gregorian::Year[2010].month(3).range).to eq(Calendar::Gregorian::Date.new(2010,3,1)..Calendar::Gregorian::Date.new(2010,3,31))
    expect(Calendar::Gregorian::Year[2010].month(4).range).to eq(Calendar::Gregorian::Date.new(2010,4,1)..Calendar::Gregorian::Date.new(2010,4,30))
    expect(Calendar::Gregorian::Year[2010].month(5).range).to eq(Calendar::Gregorian::Date.new(2010,5,1)..Calendar::Gregorian::Date.new(2010,5,31))
    expect(Calendar::Gregorian::Year[2010].month(6).range).to eq(Calendar::Gregorian::Date.new(2010,6,1)..Calendar::Gregorian::Date.new(2010,6,30))
    expect(Calendar::Gregorian::Year[2010].month(7).range).to eq(Calendar::Gregorian::Date.new(2010,7,1)..Calendar::Gregorian::Date.new(2010,7,31))
    expect(Calendar::Gregorian::Year[2010].month(8).range).to eq(Calendar::Gregorian::Date.new(2010,8,1)..Calendar::Gregorian::Date.new(2010,8,31))
    expect(Calendar::Gregorian::Year[2010].month(9).range).to eq(Calendar::Gregorian::Date.new(2010,9,1)..Calendar::Gregorian::Date.new(2010,9,30))
    expect(Calendar::Gregorian::Year[2010].month(10).range).to eq(Calendar::Gregorian::Date.new(2010,10,1)..Calendar::Gregorian::Date.new(2010,10,31))
    expect(Calendar::Gregorian::Year[2010].month(11).range).to eq(Calendar::Gregorian::Date.new(2010,11,1)..Calendar::Gregorian::Date.new(2010,11,30))
    expect(Calendar::Gregorian::Year[2010].month(12).range).to eq(Calendar::Gregorian::Date.new(2010,12,1)..Calendar::Gregorian::Date.new(2010,12,31))    
  end
  
  it 'knows that february 2016 is a leap year' do
    expect(Calendar::Gregorian::Year[2016].month(2).range).to eq(Calendar::Gregorian::Date.new(2016,2,1)..Calendar::Gregorian::Date.new(2016,2,29))
  end    
  
  it 'doesn''t accept invalid dates' do
    expect {Calendar::Gregorian::Date(2014,14,1)}.to raise_exception(ArgumentError, 'invalid date')
    expect {Calendar::Gregorian::Date(2014,12,32)}.to raise_exception(ArgumentError, 'invalid date')
  end
  
  it 'has an epoch of 1 at Date of Date.new(1,1,1)' do
    expect(Calendar::Gregorian::Date(1,1,1).fixed).to eq(1)
  end
  
  it 'knows how many weeks in a year' do
    expect(Calendar::Gregorian::Year[2014].weeks).to eq(52.142857142857146)
    expect(Calendar::Gregorian::Year[2016].weeks).to eq(52.285714285714285)
  end
  
  it 'knows how many weeks in a quarter' do
    expect(Calendar::Gregorian::Year[2014].quarter(1).weeks).to eq(12.857142857142858)
    expect(Calendar::Gregorian::Year[2016].quarter(4).weeks).to eq(13.142857142857142)
  end
  
  it 'knows how many weeks in a month' do
    expect(Calendar::Gregorian::Year[2014].month(1).weeks).to eq(4.428571428571429)
    expect(Calendar::Gregorian::Year[2016].month(4).weeks).to eq(4.285714285714286)
  end
end
