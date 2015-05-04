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
  
  def new_year
    date(year, 1, 1)
  end
  
  def year_end
    date(year, long_year?(year) ? 53 : 52, 7)
  end
  
  def range
    new_year..year_end
  end
  
  def each_day(&block)
    range.each(&block)
  end
end
