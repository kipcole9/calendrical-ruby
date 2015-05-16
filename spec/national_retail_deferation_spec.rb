require 'spec_helper'

describe NationalRetailFederation do
  let!(:default_long_years) {
    [2000, 2006, 2012, 2017, 2023, 2028, 2034, 2040, 2045, 2051, 2056, 2062, 
     2068, 2073, 2079, 2084, 2090, 2096, 2102, 2108, 2113, 2119, 2124, 2130, 
     2136, 2141, 2147, 2152, 2158, 2164, 2169, 2175, 2180, 2186, 2192, 2197] 
  }
  
  it 'should validate the nrf configuration' do
    expect(NationalRetailFederation.config.calendar_type).to eq(:'454')
    expect(NationalRetailFederation.config.starts_or_ends).to eq(:ends)
    expect(NationalRetailFederation.config.first_last_nearest).to eq(:nearest)
    expect(NationalRetailFederation.config.month_name).to eq(:january)
    expect(NationalRetailFederation.config.day_of_week).to eq(:saturday)
  end
  
  it 'should always end the year on a saturday' do
    (2000..2200).each do |y|
     expect(NationalRetailFederation::Year[y].year_end.day_of_week).to eq(Calendrical::Days::SATURDAY) 
    end
  end
  
  it 'should know which years are long years' do
    default_long_years.each do |y|
      expect(NationalRetailFederation::Year[y].long_year?).to be_truthy
    end
  end
  
  it 'should know which years are not long years' do
    (2000..2200).each do |y|
      next if default_long_years.include?(y)
      expect(NationalRetailFederation::Year[y].long_year?).to be_falsy
    end
  end
  
  it 'should know the number of weeks in a month for a long year' do
    @long_year_weeks = [nil,4,5,4,4,5,4,4,5,4,4,5,5]
    default_long_years.each do |y|
      (1..12).each do |m|
        expect(NationalRetailFederation::Year[y].month(m).weeks).to eq(@long_year_weeks[m])
      end
    end   
  end
  
  it 'should know the number of weeks in a month for a standard year' do
    @standard_weeks = [nil,4,5,4,4,5,4,4,5,4,4,5,4]
    (2000..2200).each do |y|
      next if default_long_years.include?(y)
      (1..12).each do |m|
        expect(NationalRetailFederation::Year[y].month(m).weeks).to eq(@standard_weeks[m])
      end
    end   
  end
  
  it 'should know the dates for 2015..2017' do
    expect(NationalRetailFederation::Year[2015].range).to eq(NationalRetailFederation::Date[2015,2,1]..NationalRetailFederation::Date[2016,1,30])
    expect(NationalRetailFederation::Year[2016].range).to eq(NationalRetailFederation::Date[2016,1,31]..NationalRetailFederation::Date[2017,1,28])
    expect(NationalRetailFederation::Year[2017].range).to eq(NationalRetailFederation::Date[2017,1,29]..NationalRetailFederation::Date[2018,2,3])
  end
end