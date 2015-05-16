require File.expand_path("../national_retail_federation/day.rb", __FILE__)
require File.expand_path("../national_retail_federation/year.rb", __FILE__)
require File.expand_path("../national_retail_federation/quarter.rb", __FILE__)
require File.expand_path("../national_retail_federation/week.rb", __FILE__)
require File.expand_path("../national_retail_federation/month.rb", __FILE__)

module NationalRetailFederation
  class Config
    @@config = ThirteenWeekQuarter::Config.new.config do |c|
      c.calendar_type      = :'454'        # one of 445, 454, 544 defining weeks in a quarter
      c.starts_or_ends     = :ends         # define the :start of the year, or the :end of the year
      c.first_last_nearest = :nearest      # :first, :last, :nearest (:nearest to :start or :end of :month)
      c.day_of_week        = :saturday     # start (or end) the year on this day
      c.month_name         = :january      # start (or end) the year in this month
    end
    
    def self.config
      @@config
    end
  end
  
  def self.config(*args)
    Config.config
  end

  def self.Year(year)
    Year[year]
  end
    
  def self.Quarter(*args)
    Quarter[*args]
  end

  def self.Month(*args)
    Month[*args]
  end  
  
  def self.Week(*args)
    Week[*args]
  end
  
  def self.Date(*args)
    Date[*args]
  end
  
end