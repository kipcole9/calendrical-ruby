class Gregorian::Year < Calendar
  attr_accessor :year, :fixed

  include Calendrical::Kday
  include Calendrical::Ecclesiastical
  include Calendrical::Dates
    
  def initialize(year)
    @year = year
  end
  
  def inspect
    range.inspect
  end
  
  def leap_year?
    (year % 4 == 0) && ![100, 200, 300].include?(year % 400)
  end
  alias :leap? :leap_year?

  def <=>(other)
    year <=> other.year
  end
  
  def range
    @range ||= new_year..year_end
  end
  
  def +(other)
    self.class[year + other]
  end
  
  def -(other)
    self.class[year - other]
  end

  def quarter(n)
    Gregorian::Quarter[self, n]
  end
  
  def month(n)
    Gregorian::Month[self, n]
  end
  
  def week(n)
    Gregorian::Week[self, n]
  end
  
  def weeks
    days / 7.0
  end
  
  def quarters_in_year
    4
  end
  
  def days_in_week
    7
  end

  # Need to do a little traffic managment here since
  # we're going to be called sometimes with just a year
  # and sometimes with a date formation from the super class
  def date(g_year, g_month = nil, g_day = nil)
    the_year = g_year.is_a?(Fixnum) ? g_year : g_year.year
    if g_month && g_day
      Gregorian::Date[the_year, g_month, g_day]
    else
      Gregorian::Year[the_year]
    end
  end
end
