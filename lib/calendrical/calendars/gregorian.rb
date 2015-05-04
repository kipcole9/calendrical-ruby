require File.expand_path("../gregorian/day.rb", __FILE__)
require File.expand_path("../gregorian/month.rb", __FILE__)
require File.expand_path("../gregorian/year.rb", __FILE__)
require File.expand_path("../gregorian/quarter.rb", __FILE__)
require File.expand_path("../gregorian/week.rb", __FILE__)

module Gregorian
  def self.Year(year)
    Gregorian::Year[year]
  end
    
  def self.Quarter(year, quarter)
    Gregorian::Quarter[year, quarter]
  end
  
  def self.Month(year, month)
    Gregorian::Month[year, month]
  end
  
  def self.Week(year, week)
    Gregorian::Week[year, week]
  end

  def self.Date(year, month, day)
    Gregorian::Date[year, month, day]
  end
  
end