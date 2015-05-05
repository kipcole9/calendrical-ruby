require 'spec_helper'

describe Iso do
  let!(:long_years) {
    [2004, 2009, 2015, 2020, 2026, 2032, 2037, 2043, 2048, 2054, 2060, 2065, 2071, 2076, 2082,
    2088, 2093, 2099, 2105, 2111, 2116, 2122, 2128, 2133, 2139, 2144, 2150, 2156,
    2161, 2167, 2172, 2178, 2184, 2189, 2195, 2201, 2207, 2212, 2218, 2224, 2229, 2235, 2240,
    2246, 2252, 2257, 2263, 2268, 2274, 2280, 2285, 2291, 2296, 2303, 2308, 2314,
    2320, 2325, 2331, 2336, 2342, 2348, 2353, 2359, 2364, 2370, 2376, 2381, 2387, 2392, 2398]
  }
  
  it 'knows 2014 is not a long year' do
    expect(Iso::Year(2014).long_year?).to be_falsy
  end
  
  it 'knows 2015 is a long year' do
    expect(Iso::Year(2015).long_year?).to be_truthy
  end
  
  it 'knows what is a long year' do
    long_years.each do |y|
      expect(Iso::Year(y).long_year?).to be_truthy
    end
  end 
  
  it 'knows what is not a long year' do
    (2000..2400).each do |y|
      next if long_years.include? y
      expect(Iso::Year(y).long_year?).to be_falsy
    end
  end
  
  it 'knows 2015 has 53 weeks' do
    expect(Iso::Year(2015).range).to eq(Iso::Date(2015,1,1)..Iso::Date(2015,53,7))
  end
  
  it 'won''t allow invalid week number in a date' do
    expect {Iso::Date(2015,55,1)}.to raise_exception(Calendrical::InvalidWeek)
  end
  
  it 'won''t allow invalid day number in a date' do
    expect {Iso::Date(2015,52,9)}.to raise_exception(Calendrical::InvalidDay)
  end
  
  it 'knows ISO quarters for 2015' do
    expect(Iso::Year(2015).quarter(1).range).to eq(Iso::Date(2015,1,1)..Iso::Date(2015,13,7))
    expect(Iso::Year(2015).quarter(2).range).to eq(Iso::Date(2015,14,1)..Iso::Date(2015,26,7))    
    expect(Iso::Year(2015).quarter(3).range).to eq(Iso::Date(2015,27,1)..Iso::Date(2015,39,7))
    expect(Iso::Year(2015).quarter(4).range).to eq(Iso::Date(2015,40,1)..Iso::Date(2015,53,7))
  end
  
  it 'knows ISO quarters for 2014' do
    expect(Iso::Year(2014).quarter(1).range).to eq(Iso::Date(2014,1,1)..Iso::Date(2014,13,7))
    expect(Iso::Year(2014).quarter(2).range).to eq(Iso::Date(2014,14,1)..Iso::Date(2014,26,7))    
    expect(Iso::Year(2014).quarter(3).range).to eq(Iso::Date(2014,27,1)..Iso::Date(2014,39,7))
    expect(Iso::Year(2014).quarter(4).range).to eq(Iso::Date(2014,40,1)..Iso::Date(2014,52,7))
  end
  
  it 'knows the first Monday of the year is the first day of the year' do
    expect(Iso::Year(2015).first_kday(Calendrical::Days::MONDAY)).to eq(Iso::Date(2015,1,1))
    expect(Iso::Year(2015).quarter(1).first_kday(Calendrical::Days::MONDAY)).to eq(Iso::Date(2015,1,1))
  end
end