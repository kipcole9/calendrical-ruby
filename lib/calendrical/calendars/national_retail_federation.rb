require File.expand_path("../national_retail_federation/day.rb", __FILE__)
require File.expand_path("../national_retail_federation/year.rb", __FILE__)
require File.expand_path("../national_retail_federation/quarter.rb", __FILE__)
require File.expand_path("../national_retail_federation/week.rb", __FILE__)
require File.expand_path("../national_retail_federation/month.rb", __FILE__)

module NationalRetailFederation

  def self.Year(year)
    NationalRetailFederation::Year[year]
  end
    
  def self.Quarter(*args)
    NationalRetailFederation::Quarter[*args]
  end

  def self.Month(*args)
    NationalRetailFederation::Month[*args]
  end  
  
  def self.Week(*args)
    NationalRetailFederation::Week[*args]
  end
  
  def self.Date(*args)
    NationalRetailFederation::Date[*args]
  end
  
end