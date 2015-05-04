require 'spec_helper'

describe 'K-day' do
  it 'knows the sunday before Jan 1 2015 is Dec 28 2014' do
    expect(Gregorian::Date[2015,1,1].kday_on_or_before(Calendrical::Days::SUNDAY)).to eq(Gregorian::Date[2014,12,28])
    expect(Gregorian::Date[2015,1,1].kday_on_or_before(Calendrical::Days::THURSDAY)).to eq(Gregorian::Date[2015,1,1])
  end
  
  it 'knows the sunday after Jan 1 2015 is Jan 4 2015' do
    expect(Gregorian::Date[2015,1,1].kday_on_or_after(Calendrical::Days::SUNDAY)).to eq(Gregorian::Date[2015,1,4])
    expect(Gregorian::Date[2015,1,1].kday_on_or_after(Calendrical::Days::THURSDAY)).to eq(Gregorian::Date[2015,1,1])
  end
  
  it 'knows the nearest sunday to Jan 1 2015 is Jan 4 2015' do
    expect(Gregorian::Date[2015,1,1].kday_nearest(Calendrical::Days::SUNDAY)).to eq(Gregorian::Date[2015,1,4])
    expect(Gregorian::Date[2015,1,1].kday_nearest(Calendrical::Days::THURSDAY)).to eq(Gregorian::Date[2015,1,1])
  end
  
  it 'knows the sunday after Jan 1 2015 is Jan 4 2015' do
    expect(Gregorian::Date[2015,1,1].kday_after(Calendrical::Days::SUNDAY)).to eq(Gregorian::Date[2015,1,4])
  end
  
  it 'knows the sunday before Jan 1 2015 is Dec 28 2014' do
    expect(Gregorian::Date[2015,1,1].kday_before(Calendrical::Days::SUNDAY)).to eq(Gregorian::Date[2014,12,28])
  end
  
  it 'knows the last sunday in Jan 2015 is Jan 25' do
    expect(Gregorian::Date[2015,1,31].last_kday(Calendrical::Days::SUNDAY)).to eq(Gregorian::Date[2015,1,25])
  end

  it 'knows the last saturday in Jan 2015 is Jan 31' do
    expect(Gregorian::Date[2015,1,31].last_kday(Calendrical::Days::SATURDAY)).to eq(Gregorian::Date[2015,1,31])
  end
  
  it 'knows the first sunday in Jan 2015 is Jan 4' do
    expect(Gregorian::Date[2015,1,1].first_kday(Calendrical::Days::SUNDAY)).to eq(Gregorian::Date[2015,1,4])
    expect(Gregorian::Year[2015].first_kday(Calendrical::Days::SUNDAY)).to eq(Gregorian::Date[2015,1,4])
    expect(Gregorian::Year[2015].quarter(1).first_kday(Calendrical::Days::SUNDAY)).to eq(Gregorian::Date[2015,1,4])
    expect(Gregorian::Year[2015].quarter(1).month(1).first_kday(Calendrical::Days::SUNDAY)).to eq(Gregorian::Date[2015,1,4])
    expect(Gregorian::Year[2015].quarter(1).month(1).week(1).first_kday(Calendrical::Days::SUNDAY)).to eq(Gregorian::Date[2015,1,4])
    expect(Gregorian::Year[2015].quarter(1).week(1).first_kday(Calendrical::Days::SUNDAY)).to eq(Gregorian::Date[2015,1,4])
    expect(Gregorian::Year[2015].month(1).week(1).first_kday(Calendrical::Days::SUNDAY)).to eq(Gregorian::Date[2015,1,4])
    expect(Gregorian::Year[2015].week(1).first_kday(Calendrical::Days::SUNDAY)).to eq(Gregorian::Date[2015,1,4])
  end
  
  it 'knows the last sunday in quarter 1 is March 29th' do
    expect(Gregorian::Year[2015].quarter(1).last_kday(Calendrical::Days::SUNDAY)).to eq(Gregorian::Date[2015,3,29])
  end  
  
end