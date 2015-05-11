require File.expand_path("../four_four_five/config.rb", __FILE__)
require File.expand_path("../four_four_five/configurations.rb", __FILE__)
require File.expand_path("../four_four_five/day.rb", __FILE__)
require File.expand_path("../four_four_five/year.rb", __FILE__)
require File.expand_path("../four_four_five/quarter.rb", __FILE__)
require File.expand_path("../four_four_five/week.rb", __FILE__)
require File.expand_path("../four_four_five/month.rb", __FILE__)

module FourFourFive
  def self.Year(year)
    FourFourFive::Year[year]
  end
    
  def self.Quarter(*args)
    FourFourFive::Quarter[*args]
  end
  
  def self.Week(*args)
    FourFourFive::Week[*args]
  end
  
  def self.Date(*args)
    FourFourFive::Date[*args]
  end
  
end