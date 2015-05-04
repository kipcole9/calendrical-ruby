class Gregorian::Quarter < Calendar
  attr_accessor :year, :quarter, :fixed

  include Calendrical::Kday
  include Calendrical::Ecclesiastical
  include Calendrical::Dates
    
  def initialize(year, quarter)
    raise(Calendrical::InvalidQuarter, "Invalid quarter '#{quarter}' which must be between 1 and 4 inclusive") unless (1..4).include?(quarter.to_i)
    @year = year
    @quarter = quarter
  end
  
  def inspect
    "#{year}-Q#{quarter}"
  end

  def <=>(other)
    quarters <=> other.quarters
  end

  def range
    @range ||= case quarter
    when 1
      Gregorian::Date[year, 1, 1]..Gregorian::Date[year, 3, 31]
    when 2
      Gregorian::Date[year, 4, 1]..Gregorian::Date[year, 6, 30]
    when 3
      Gregorian::Date[year, 7, 1]..Gregorian::Date[year, 9, 30]
    when 4
      Gregorian::Date[year, 10, 1]..Gregorian::Date[year, 12, 31]
    end
  end

  def +(other)
    absolute_quarters = quarters + other
    new_year = absolute_quarters / 4
    new_quarter = absolute_quarters % 4
    if new_quarter == 0
      new_quarter = 4 
      new_year = new_year - 1
    end
    self.class[new_year, new_quarter]
  end
  
  def -(other)
    self + -other
  end
  
  def quarters
    year * 4 + quarter
  end
  
  # TODO:  Weeks should be offset to quarter, not the year
  def week(n)
    week_number = ((range.first.fixed - Gregorian::Year[year].new_year.fixed) / 7) + n
    Gregorian::Week[year, week_number]
  end
end
