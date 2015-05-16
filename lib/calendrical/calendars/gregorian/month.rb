class Gregorian::Month < Calendar
  attr_accessor :year, :month, :fixed
  MONTHS_IN_YEAR = 12
  
  def initialize(year, month)
    raise(Calendrical::InvalidMonth, "Invalid month '#{month}' which must be between 1 and 12 inclusive") unless (1..12).include?(month.to_i)
    @year = year
    @month = month.to_i
  end
  
  def inspect
    range.inspect
  end

  def <=>(other)
    months <=> other.months
  end

  def range
    @range ||= start_of_month..end_of_month
  end
  
  def start_of_month
    Gregorian::Date[year.year, month, 1]
  end
  
  def end_of_month
    Gregorian::Date[year.year, month, last_day_of_month]
  end

  def +(other)
    absolute_months = months + other
    new_year = absolute_months / MONTHS_IN_YEAR
    new_month = absolute_quarters % MONTHS_IN_YEAR
    if new_month == 0
      new_month = DECEMBER
      new_year = new_year - 1
    end
    self.class[new_year, new_month]
  end
  
  def -(other)
    self + -other
  end
  
  def last_day_of_month(yyear = self.year.year, mmonth = self.month)
    case mmonth
    when SEPTEMBER, APRIL, JUNE, NOVEMBER
      30
    when FEBRUARY
      Gregorian::Year[yyear].leap_year? ? 29 : 28
    else
      31
    end
  end
  
  def week(n)
    start_day = range.first + ((n - 1) * 7)
    raise(Calendrical::InvalidWeek, "Week #{n} doesn't lie within month #{month}'s range of #{range}") \
      unless range.include?(start_day)
    end_day = [start_day + 6, range.last].min
    Gregorian::Week[year, n, start_day, end_day]
  end
  
  def weeks
    days / 7.0
  end
  
protected
  
  def months
    year.year * MONTHS_IN_YEAR + month
  end

end
