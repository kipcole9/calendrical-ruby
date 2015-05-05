require File.expand_path("../iso/day.rb", __FILE__)
require File.expand_path("../iso/year.rb", __FILE__)
require File.expand_path("../iso/quarter.rb", __FILE__)
require File.expand_path("../iso/week.rb", __FILE__)

module Iso
  def self.Year(year)
    Iso::Year[year]
  end
    
  def self.Quarter(*args)
    Iso::Quarter[*args]
  end
  
  def self.Week(*args)
    Iso::Week[*args]
  end
  
  def self.Date(*args)
    Iso::Date[*args]
  end
  
end