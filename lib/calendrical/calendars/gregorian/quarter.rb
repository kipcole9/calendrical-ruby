class Gregorian::Quarter < Calendrical::Calendar
  attr_accessor :year, :quarter, :fixed
  QUARTERS_IN_YEAR = 4
  LAST_QUARTER = 4
  
  def initialize(year, quarter)
    raise(Calendrical::InvalidQuarter, "Invalid quarter '#{quarter}' which must be between 1 and 4 inclusive") unless (1..4).include?(quarter.to_i)
    @year = year
    @quarter = quarter.to_i
  end
  
  def inspect
    range.inspect
  end

  def <=>(other)
    quarters <=> other.quarters
  end

  def range
    @range ||= case quarter
    when 1
      Gregorian::Date[year.year, JANUARY, 1]..Gregorian::Date[year.year, MARCH, 31]
    when 2
      Gregorian::Date[year.year, APRIL, 1]..Gregorian::Date[year.year, JUNE, 30]
    when 3
      Gregorian::Date[year.year, JULY, 1]..Gregorian::Date[year.year, SEPTEMBER, 30]
    when 4
      Gregorian::Date[year.year, OCTOBER, 1]..Gregorian::Date[year.year, DECEMBER, 31]
    end
  end
  
  def +(other)
    absolute_quarters = quarters + other
    new_year = absolute_quarters / QUARTERS_IN_YEAR
    new_quarter = absolute_quarters % QUARTERS_IN_YEAR
    if new_quarter == 0
      new_quarter = LAST_QUARTER 
      new_year = new_year - 1
    end
    self.class[new_year, new_quarter]
  end
  
  def -(other)
    self + -other
  end

  def month(n)
    raise(Calendrical::InvalidMonth, "Invalid month '#{n}' which must be between 1 and 3 inclusive for a quarter") unless (1..3).include?(n.to_i)
    target_month = range.first.month + n - 1
    Gregorian::Month[year, target_month]
  end
  
  def week(n)
    start_day = range.first + ((n - 1) * 7)
    raise(Calendrical::InvalidWeek, "Week #{n} doesn't lie within quarter #{quarter}'s range of #{range}") \
      unless range.include?(start_day)
    end_day = [start_day + 6, range.last].min
    Gregorian::Week[year, n, start_day, end_day]
  end
  
  def weeks
    days / 7.0
  end
  
protected
  
  def quarters
    year.year * QUARTERS_IN_YEAR + quarter
  end

end
