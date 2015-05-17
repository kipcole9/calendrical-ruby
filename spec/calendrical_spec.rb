require 'spec_helper'

describe 'Calendrical' do
  let!(:base_date) { 735723 }  # Which is the fixed date for May 5, 2015
  
  it 'has a version number' do
    expect(Calendrical::VERSION).not_to be nil
  end
  
  it 'does a round trip to fixed and back to calendar for Gregorian' do
    expect(Calendar::Gregorian::Date[base_date]).to eq(Calendar::Gregorian::Date[2015,5,5])
    expect(Calendar::Gregorian::Date[Calendar::Gregorian::Date[base_date].elements]).to eq(Calendar::Gregorian::Date[base_date])
  end
  
  it 'does a round trip to fixed and back to calendar for Julian' do
    expect(Calendar::Julian::Date[base_date].to_gregorian).to eq(Calendar::Gregorian::Date[2015,5,5])   
    expect(Calendar::Julian::Date[Calendar::Julian::Date[base_date].elements]).to eq(Calendar::Julian::Date[base_date])
  end
  
  it 'does a round trip to fixed and back to calendar for French Revolutionary' do
    expect(Calendar::FrenchRevolutionary::Date[base_date].to_gregorian).to eq(Calendar::Gregorian::Date[2015,5,5])   
    expect(Calendar::FrenchRevolutionary::Date[Calendar::FrenchRevolutionary::Date[base_date].elements]).to eq(Calendar::FrenchRevolutionary::Date[base_date])
  end
  
  it 'does a round trip to fixed and back to calendar for Coptic' do
    expect(Calendar::Coptic::Date[base_date].to_gregorian).to eq(Calendar::Gregorian::Date[2015,5,5])   
    expect(Calendar::Coptic::Date[Calendar::Coptic::Date[base_date].elements]).to eq(Calendar::Coptic::Date[base_date])
  end
  
  it 'does a round trip to fixed and back to calendar for Epytian' do
    expect(Calendar::Egyptian::Date[base_date].to_gregorian).to eq(Calendar::Gregorian::Date[2015,5,5])   
    expect(Calendar::Egyptian::Date[Calendar::Egyptian::Date[base_date].elements]).to eq(Calendar::Egyptian::Date[base_date])
  end    
  
  it 'does a round trip to fixed and back to calendar for Etheopian' do
    expect(Calendar::Etheopian::Date[base_date].to_gregorian).to eq(Calendar::Gregorian::Date[2015,5,5])   
    expect(Calendar::Etheopian::Date[Calendar::Etheopian::Date[base_date].elements]).to eq(Calendar::Etheopian::Date[base_date])
  end
  
  it 'does a round trip to fixed and back to calendar for Chinese' do
    expect(Calendar::Chinese::Date[base_date].to_gregorian).to eq(Calendar::Gregorian::Date[2015,5,5])   
    expect(Calendar::Chinese::Date[Calendar::Chinese::Date[base_date].elements]).to eq(Calendar::Chinese::Date[base_date])
  end 
  
  it 'should be accessible via the Calendar module with default Gregorian' do
    expect(Calendar::Date[]).to eq(Calendar::Gregorian::Date[])
    expect(Calendar::Year[2015]).to eq(Calendar::Gregorian::Year[2015])
    expect(Calendar::Quarter[2015, 1]).to eq(Calendar::Gregorian::Quarter[2015, 1])
    expect(Calendar::Month[2015, 10]).to eq(Calendar::Gregorian::Month[2015, 10])
  end 
end