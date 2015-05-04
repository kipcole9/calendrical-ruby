class GregorianYear < Calendar
  attr_accessor :year, :fixed

  include Calendrical::Kday
  include Calendrical::Ecclesiastical
  include Calendrical::Dates
  # include Calendrical::Dates::US
    
  def initialize(year)
    @year = year
  end
  
  def inspect
    # "#{year} Gregorian"
    year
  end
  
  def to_s
    inspect
  end
  
  def leap_year?
    new_year.leap_year?
  end
  
  def <=>(other)
    year <=> other.year
  end
  
  def succ
    self.class[year + 1]
  end
  
  # Need to do a little traffic managment here since
  # we're going to be called sometimes with just a year
  # and sometimes with a date formation from the super class
  def date(g_year, g_month = nil, g_day = nil)
    the_year = g_year.is_a?(Fixnum) ? g_year : g_year.year
    if g_month && g_day
      GregorianDate[the_year, g_month, g_day]
    else
      GregorianYear[the_year]
    end
  end 
  
  def range
    new_year..year_end
  end

  def to_fixed
    new_year.fixed
  end 
  
  def each_day(&block)
    range.each(&block)
  end
end
