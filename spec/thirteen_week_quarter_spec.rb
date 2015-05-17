require 'spec_helper'

describe Calendar::ThirteenWeekQuarter do
  
  let!(:default_long_years) {
    [2000, 2006, 2012, 2017, 2023, 2028, 2034, 2040, 2045, 2051, 2056, 2062, 
     2068, 2073, 2079, 2084, 2090, 2096, 2102, 2108, 2113, 2119, 2124, 2130, 
     2136, 2141, 2147, 2152, 2158, 2164, 2169, 2175, 2180, 2186, 2192, 2197] 
  }
  
  it 'should start the new year on a Sunday by default' do
    Calendar::ThirteenWeekQuarter.config.default!    
    (2000..2200).each do |y|
     expect(Calendar::ThirteenWeekQuarter::Year[y].new_year.day_of_week).to eq(Calendrical::Days::SUNDAY) 
    end
  end
  
  it 'should end the year on a Saturday by default' do
    Calendar::ThirteenWeekQuarter.config.default!
    (2000..2200).each do |y|
     expect(Calendar::ThirteenWeekQuarter::Year[y].year_end.day_of_week).to eq(Calendrical::Days::SATURDAY) 
    end
  end
  
  it 'should know the first day in 2014 with default configuration' do
    Calendar::ThirteenWeekQuarter.config.default!
    expect(Calendar::ThirteenWeekQuarter::Year[2014].new_year).to eq(Calendar::Gregorian::Date.new(2014,1,5))
    expect(Calendar::ThirteenWeekQuarter::Year[2014].quarter(1).begin).to eq(Calendar::Gregorian::Date.new(2014,1,5))
    expect(Calendar::ThirteenWeekQuarter::Year[2014].month(1).begin).to eq(Calendar::Gregorian::Date.new(2014,1,5))
    expect(Calendar::ThirteenWeekQuarter::Year[2014].quarter(1).month(1).begin).to eq(Calendar::Gregorian::Date.new(2014,1,5))
    expect(Calendar::ThirteenWeekQuarter::Year[2014].week(1).begin).to eq(Calendar::Gregorian::Date.new(2014,1,5))
    expect(Calendar::ThirteenWeekQuarter::Year[2014].quarter(1).week(1).begin).to eq(Calendar::Gregorian::Date.new(2014,1,5))    
    expect(Calendar::ThirteenWeekQuarter::Year[2014].quarter(1).month(1).week(1).begin).to eq(Calendar::Gregorian::Date.new(2014,1,5))
    expect(Calendar::ThirteenWeekQuarter::Year[2014].month(1).week(1).begin).to eq(Calendar::Gregorian::Date.new(2014,1,5))    
  end

  it 'should show know the last day in 2014 with default configuration' do
    Calendar::ThirteenWeekQuarter.config.default!    
    expect(Calendar::ThirteenWeekQuarter::Year[2014].year_end).to eq(Calendar::Gregorian::Date.new(2015,1,3))
    expect(Calendar::ThirteenWeekQuarter::Year[2014].quarter(4).end).to eq(Calendar::Gregorian::Date.new(2015,1,3))
    expect(Calendar::ThirteenWeekQuarter::Year[2014].month(12).end).to eq(Calendar::Gregorian::Date.new(2015,1,3))
    expect(Calendar::ThirteenWeekQuarter::Year[2014].quarter(4).month(3).end).to eq(Calendar::Gregorian::Date.new(2015,1,3))
    expect(Calendar::ThirteenWeekQuarter::Year[2014].week(52).end).to eq(Calendar::Gregorian::Date.new(2015,1,3))
    expect(Calendar::ThirteenWeekQuarter::Year[2014].quarter(4).month(3).week(5).end).to eq(Calendar::Gregorian::Date.new(2015,1,3))
    expect(Calendar::ThirteenWeekQuarter::Year[2014].month(12).week(5).end).to eq(Calendar::Gregorian::Date.new(2015,1,3))
    expect(Calendar::ThirteenWeekQuarter::Year[2014].quarter(4).week(13).end).to eq(Calendar::Gregorian::Date.new(2015,1,3))            
  end
  
  it 'should know the number of weeks in a month for a long year' do
    Calendar::ThirteenWeekQuarter.config.default!
    @long_year_weeks = [4,4,5,4,4,5,4,4,5,4,4,6]
    (default_long_years).each do |y|
      (1..12).each do |m|
        expect(Calendar::ThirteenWeekQuarter::Year[y].month(m).weeks).to eq(@long_year_weeks[m - 1])
      end
    end   
  end
  
  it 'should know the number of weeks in a month for a standard year' do
    Calendar::ThirteenWeekQuarter.config.default!
    @standard_weeks = [4,4,5,4,4,5,4,4,5,4,4,5]
    (1..12).each do |m|
      expect(Calendar::ThirteenWeekQuarter::Year[2014].month(m).weeks).to eq(@standard_weeks[m - 1])
    end   
  end
end
