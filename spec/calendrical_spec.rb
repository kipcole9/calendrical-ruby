require 'spec_helper'

describe Gregorian do
  let!(:base_date) { 735723 }  # Which is the fixed date for May 5, 2015
  
  it 'has a version number' do
    expect(Calendrical::VERSION).not_to be nil
  end
  
  it 'does a round trip to fixed and back to calendar for Gregorian' do
    expect(Gregorian::Date[base_date]).to eq(Gregorian::Date[2015,5,5])   
  end
  
  it 'does a round trip to fixed and back to calendar for Julian' do
    expect(Julian::Date[base_date].to_gregorian).to eq(Gregorian::Date[2015,5,5])   
  end
  
  it 'does a round trip to fixed and back to calendar for French Revolutionary' do
    expect(FrenchRevolutionary::Date[base_date].to_gregorian).to eq(Gregorian::Date[2015,5,5])   
  end
  
  it 'does a round trip to fixed and back to calendar for Coptic' do
    expect(Coptic::Date[base_date].to_gregorian).to eq(Gregorian::Date[2015,5,5])   
  end
  
  it 'does a round trip to fixed and back to calendar for Epytian' do
    expect(Egyptian::Date[base_date].to_gregorian).to eq(Gregorian::Date[2015,5,5])   
  end    
  
  it 'does a round trip to fixed and back to calendar for Etheopian' do
    expect(Etheopian::Date[base_date].to_gregorian).to eq(Gregorian::Date[2015,5,5])   
  end
  
  it 'does a round trip to fixed and back to calendar for Chinese' do
    expect(Chinese::Date[base_date].to_gregorian).to eq(Gregorian::Date[2015,5,5])   
  end  
end