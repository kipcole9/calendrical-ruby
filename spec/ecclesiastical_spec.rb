require 'spec_helper'

describe 'Ecclesiastical' do
  it 'calculates christmas' do
    expect(Gregorian::Year[2015].christmas).to eq(Gregorian::Date[2015,12,25])
  end
  
  it 'calculates easter' do
    expect(Gregorian::Year[2011].easter).to eq(Gregorian::Date[2011,4,24])
    expect(Gregorian::Year[2012].easter).to eq(Gregorian::Date[2012,4,8])
    expect(Gregorian::Year[2013].easter).to eq(Gregorian::Date[2013,3,31])
    expect(Gregorian::Year[2014].easter).to eq(Gregorian::Date[2014,4,20])
    expect(Gregorian::Year[2015].easter).to eq(Gregorian::Date[2015,4,5])
    expect(Gregorian::Year[2016].easter).to eq(Gregorian::Date[2016,3,27])
    expect(Gregorian::Year[2017].easter).to eq(Gregorian::Date[2017,4,16])
    expect(Gregorian::Year[2018].easter).to eq(Gregorian::Date[2018,4,1])
    expect(Gregorian::Year[2019].easter).to eq(Gregorian::Date[2019,4,21])
    expect(Gregorian::Year[2020].easter).to eq(Gregorian::Date[2020,4,12])  
  end
end
