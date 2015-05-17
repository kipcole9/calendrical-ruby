require File.expand_path("../julian/day.rb", __FILE__)
require File.expand_path("../julian/year.rb", __FILE__)
require File.expand_path("../julian/quarter.rb", __FILE__)
require File.expand_path("../julian/week.rb", __FILE__)

module Calendar
  module Julian
    def self.Year(year)
      Julian::Year[year]
    end
    
    def self.Quarter(*args)
      Julian::Quarter[*args]
    end
  
    def self.Week(*args)
      Julian::Week[*args]
    end
  
    def self.Date(*args)
      Julian::Date[*args]
    end
  
  end
end