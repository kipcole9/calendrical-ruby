require File.expand_path("../gregorian/day.rb", __FILE__)
require File.expand_path("../gregorian/month.rb", __FILE__)
require File.expand_path("../gregorian/year.rb", __FILE__)
require File.expand_path("../gregorian/quarter.rb", __FILE__)
require File.expand_path("../gregorian/week.rb", __FILE__)

module Gregorian
  def self.Year(year)
    Gregorian::Year[year]
  end
    
  def self.Quarter(*args)
    Gregorian::Quarter[*args]
  end
  
  def self.Month(*args)
    Gregorian::Month[year, month]
  end
  
  def self.Week(*args)
    Gregorian::Week[*args]
  end

  def self.Date(*args)
    Gregorian::Date[*args]
  end
  
end