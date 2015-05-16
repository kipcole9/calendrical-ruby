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
  
  it 'calculates advent' do
    expect(Gregorian::Year[2013].advent).to eq(Gregorian::Date[2013,12,1])
    expect(Gregorian::Year[2014].advent).to eq(Gregorian::Date[2014,11,30])
    expect(Gregorian::Year[2015].advent).to eq(Gregorian::Date[2015,11,29])
    expect(Gregorian::Year[2016].advent).to eq(Gregorian::Date[2016,11,27])
    expect(Gregorian::Year[2017].advent).to eq(Gregorian::Date[2017,12,3])
    expect(Gregorian::Year[2018].advent).to eq(Gregorian::Date[2018,12,2])
    expect(Gregorian::Year[2019].advent).to eq(Gregorian::Date[2019,12,1])
    expect(Gregorian::Year[2020].advent).to eq(Gregorian::Date[2020,11,29])
    expect(Gregorian::Year[2021].advent).to eq(Gregorian::Date[2021,11,28])
    expect(Gregorian::Year[2022].advent).to eq(Gregorian::Date[2022,11,27])
  end
  
  it 'calculates orthodox easter' do
    expect(Gregorian::Year[2015].eastern_orthodox_easter).to eq(Gregorian::Date[2015,4,12])
    expect(Gregorian::Year[2016].eastern_orthodox_easter).to eq(Gregorian::Date[2016,5,1])
    expect(Gregorian::Year[2017].eastern_orthodox_easter).to eq(Gregorian::Date[2017,4,16])
    expect(Gregorian::Year[2018].eastern_orthodox_easter).to eq(Gregorian::Date[2018,4,8])
    expect(Gregorian::Year[2019].eastern_orthodox_easter).to eq(Gregorian::Date[2019,4,28])
    expect(Gregorian::Year[2020].eastern_orthodox_easter).to eq(Gregorian::Date[2020,4,19])
    expect(Gregorian::Year[2021].eastern_orthodox_easter).to eq(Gregorian::Date[2021,5,2])
    expect(Gregorian::Year[2022].eastern_orthodox_easter).to eq(Gregorian::Date[2022,4,24])
    expect(Gregorian::Year[2023].eastern_orthodox_easter).to eq(Gregorian::Date[2023,4,16])
    expect(Gregorian::Year[2024].eastern_orthodox_easter).to eq(Gregorian::Date[2024,5,5])
  end

  it 'calculates orthodox christmas' do
    expect(Gregorian::Year[2015].eastern_orthodox_christmas).to eq(Gregorian::Date[2016,1,7])
    expect(Gregorian::Year[2016].eastern_orthodox_christmas).to eq(Gregorian::Date[2017,1,7])
    expect(Gregorian::Year[2017].eastern_orthodox_christmas).to eq(Gregorian::Date[2018,1,7])
    expect(Gregorian::Year[2100].eastern_orthodox_christmas).to eq(Gregorian::Date[2101,1,8])
    expect(Gregorian::Year[2200].eastern_orthodox_christmas).to eq(Gregorian::Date[2201,1,9])
  end
end
