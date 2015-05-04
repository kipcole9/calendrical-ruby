require File.expand_path("../iso/day.rb", __FILE__)
require File.expand_path("../iso/year.rb", __FILE__)
require File.expand_path("../iso/quarter.rb", __FILE__)
require File.expand_path("../iso/week.rb", __FILE__)

module Iso
  def self.Year(year)
    Iso::Year[year]
  end
    
  def self.Quarter(year, quarter)
    Iso::Quarter[year, quarter]
  end
  
  def self.Week(year, week)
    Iso::Week[year, week]
  end
  
  def self.Date(year, month, day)
    Iso::Date[year, month, day]
  end
  
end