require File.expand_path("../thirteen_week_quarter/config.rb", __FILE__)
require File.expand_path("../thirteen_week_quarter/configurations.rb", __FILE__)
require File.expand_path("../thirteen_week_quarter/day.rb", __FILE__)
require File.expand_path("../thirteen_week_quarter/year.rb", __FILE__)
require File.expand_path("../thirteen_week_quarter/quarter.rb", __FILE__)
require File.expand_path("../thirteen_week_quarter/week.rb", __FILE__)
require File.expand_path("../thirteen_week_quarter/month.rb", __FILE__)

module ThirteenWeekQuarter

  def self.Year(year)
    ThirteenWeekQuarter::Year[year]
  end
    
  def self.Quarter(*args)
    ThirteenWeekQuarter::Quarter[*args]
  end

  def self.Month(*args)
    ThirteenWeekQuarter::Month[*args]
  end  
  
  def self.Week(*args)
    ThirteenWeekQuarter::Week[*args]
  end
  
  def self.Date(*args)
    ThirteenWeekQuarter::Date[*args]
  end
  
end