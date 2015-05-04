class Gregorian::Month < Calendar
  attr_accessor :year, :month, :fixed
  MONTHS_IN_YEAR = 12
  
  def initialize(year, month)
    raise(Calendrical::InvalidMonth, "Invalid month '#{month}' which must be between 1 and 12 inclusive") unless (1..12).include?(month.to_i)
    @year = year.to_i
    @month = month.to_i
  end
  
  def inspect
    "#{year}-#{month}"
  end

  def <=>(other)
    months <=> other.months
  end

  def range
    @range ||= Gregorian::Date[year, month, 1]..Gregorian::Date[year, month, last_day_of_month]
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
  
  def last_day_of_month
    case month
    when SEPTEMBER, APRIL, JUNE, NOVEMBER
      30
    when FEBRUARY
      Gregorian::Year[year].leap_year? ? 29 : 28
    else
      31
    end
  end
  
  # TODO:  Weeks should be offset to quarter, not the year
  def week(n)
    week_number = ((range.first.fixed - Gregorian::Year[year].new_year.fixed) / 7) + n
    Gregorian::Week[year, week_number]
  end
  
protected
  
  def months
    year * MONTHS_IN_YEAR + month
  end

end
