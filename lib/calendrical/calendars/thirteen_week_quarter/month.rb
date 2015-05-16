module ThirteenWeekQuarter
  class Month < Gregorian::Month
    
    def start_of_month
      quarter = (month / 4) + 1
      start_of_quarter = year.quarter(quarter).start_of_quarter
      offset_weeks = config.offset_weeks_for_month(month_in_quarter)
      start_of_quarter + (offset_weeks * 7)
    end
    
    def end_of_month
      end_of_month = start_of_month + (config.weeks_in_month(month_in_quarter) * 7) - 1
      end_of_month += 7 if year.long_year? && month == 12
      end_of_month
    end
    
    def week(n)
      start_day = range.first + ((n - 1) * 7)
      raise(Calendrical::InvalidWeek, "Week #{n} doesn't lie within month #{month}'s range of #{range}") \
        unless range.include?(start_day)
      end_day = [start_day + 6, range.last].min
      ThirteenWeekQuarter::Week[year, n, start_day, end_day]
    end
    
    def weeks
      days / 7
    end
  
  protected
    def month_in_quarter
      month_in_quarter = (month.to_i % 3)
      month_in_quarter = 3 if month_in_quarter == 0
      month_in_quarter
    end
  
    def months
      year * MONTHS_IN_YEAR + month
    end

  end
end
