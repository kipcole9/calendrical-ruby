class Julian::Month < Gregorian::Month
  def range
    @range ||= Julian::Date[year, month, 1]..Julian::Date[year, month, last_day_of_month]
  end

  def last_day_of_month
    case month
    when SEPTEMBER, APRIL, JUNE, NOVEMBER
      30
    when FEBRUARY
      Julian::Year[year].leap_year? ? 29 : 28
    else
      31
    end
  end
  
  def week(n)
    start_day = range.first + ((n - 1) * 7)
    raise(Calendrical::InvalidWeek, "Week #{n} doesn't lie within month #{month}'s range of #{range}") \
      unless range.include?(start_day)
    end_day = [start_day + 6, range.last].min
    Julian::Week[year, n, start_day, end_day]
  end
  
protected
  
  def months
    year * MONTHS_IN_YEAR + month
  end

end
