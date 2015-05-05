class Julian::Quarter < Gregorian::Quarter
  def range
    @range ||= case quarter
    when 1
      Julian::Date[year, JANUARY, 1]..Julian::Date[year, MARCH, 31]
    when 2
      Julian::Date[year, APRIL, 1]..Julian::Date[year, JUNE, 30]
    when 3
      Julian::Date[year, JULY, 1]..Julian::Date[year, SEPTEMBER, 30]
    when 4
      Julian::Date[year, OCTOBER, 1]..Julian::Date[year, DECEMBER, 31]
    end
  end

  def month(n)
    raise(Calendrical::InvalidMonth, "Invalid month '#{n}' which must be between 1 and 3 inclusive for a quarter") unless (1..3).include?(n.to_i)
    target_month = range.first.month + n - 1
    Julian::Month[year, target_month]
  end
  
  def week(n)
    start_day = range.first + ((n - 1) * 7)
    raise(Calendrical::InvalidWeek, "Week #{n} doesn't lie within quarter #{quarter}'s range of #{range}") \
      unless range.include?(start_day)
    end_day = [start_day + 6, range.last].min
    Julian::Week[year, n, start_day, end_day]
  end
  
protected
  
  def quarters
    year * QUARTERS_IN_YEAR + quarter
  end

end
