module ThirteenWeekQuarter
  class Quarter < Gregorian::Quarter
    attr_reader :start_of_year
    
    def initialize(*args)
      super
      @start_of_year = Year[year].new_year
    end
    
    def range
      @range ||= start_of_quarter..end_of_quarter
    end
    
    def start_of_quarter
      @start_of_quarter = start_of_year + ((quarter - 1) * days_in_quarter)
    end
    
    def end_of_quarter
      @end_of_quarter = start_of_year + (quarter * days_in_quarter) - 1
    end
  
    def last_week_of_year
      Year[year].last_week_of_year
    end
  
    def month(n) 
      raise(Calendrical::InvalidWeek, "Month #{n} isn't between 1 and 3 for months in a quarter") \
        unless (1..3).include?(n.to_i)
      Month[self.year, ((quarter - 1) * 3) + n.to_i]
    end
     
    def week(n)
      raise(Calendrical::InvalidWeek, "Week #{n} isn't between 1 and 13 (or 14 for a long year in q4) for weeks in a quarter") \
        unless (1..13).include?(n.to_i) || (FourFourFive::Year.long_year?(year) && quarter == 4 && week == 14)
      Week[year, ((quarter - 1) * 13) + n.to_i]
    end
    
    def days_in_quarter
      diq = 13 * 7
      diq += 7 if quarter == 4 and Year[year].long_year?
      diq
    end
  end
end
