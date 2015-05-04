class Gregorian::Week < Calendar
  attr_accessor :year, :week, :start_day, :end_day, :fixed
    
  def initialize(year, week, start_day = nil, end_day = nil, quarter = nil)
    raise(Calendrical::InvalidWeek, "Week #{week} doesn't lie between 1 and 53 inclusive") unless (1..53).include?(week.to_i)
    @year = year
    @week = week
    @start_day = start_day
    @end_day = end_day
  end
  
  def inspect
    range.inspect
  end
  
  def <=>(other)
    weeks <=> other.weeks
  end
 
  def range
    start_of_week..end_of_week
  end

  def to_fixed
    range.first.fixed
  end 

  def +(other)
    start_date = start_of_week + (other * 7)
    week_number = ((start_date.to_fixed - Gregorian::Year[start_date.year].new_year.to_fixed) / 7) + 1
    Gregorian::Week[start_date.year, week_number]
  end
  
  def -(other)
    self + -other
  end

  def start_of_week
    start_day || Gregorian::Year[year].new_year + ((week - 1) * 7)
  end
  
  def end_of_week
    end_day || [start_of_week + 6, Gregorian::Year[year].year_end].min
  end
  
  def weeks
    (start_of_week.fixed / 7.0).ceil
  end
end
