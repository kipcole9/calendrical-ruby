require 'spec_helper'

describe Iso do
  it 'knows 2014 is not a long year' do
    expect(Iso::Year(2014).long_year?).to be_falsy
  end
  
  it 'knows 2015 is a long year' do
    expect(Iso::Year(2015).long_year?).to be_truthy
  end
  
  it 'knows 2015 has 53 weeks' do
    expect(Iso::Year(2015).range).to eq(Iso::Date(2015,1,1)..Iso::Date(2015,53,7))
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
end