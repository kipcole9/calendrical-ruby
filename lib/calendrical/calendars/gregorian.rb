require "#{File.dirname(__FILE__)}/../calendar.rb"

class GregorianDate < Calendar
  include Calendrical::Ecclesiastical
  include Calendrical::KdayCalculations
  include Calendrical::Dates
  
  def inspect
    Date.new(@date_elements.year, @date_elements.month, @date_elements.day)
  end
     
  def set_elements(*args)
    @date_elements = args.first.is_a?(DateStruct) ? args.first : DateStruct.new(args.first, args.second, args.third)
  end
  
  def set_fixed(arg)
    @fixed = arg
  end
  
  def to_date
    Date.new(gregorian_date.year, gregorian_date.month, gregorian_date.day)
  end
  
  def epoch
    rd(1)
  end
  
  # see lines 657-663 in calendrica-3.0.cl
  # Return True if Gregorian year 'g_year' is leap.
  def leap_year?(g_year = self.gregorian_date.year)
    (g_year % 4 == 0) && ![100, 200, 300].include?(g_year % 400)
  end
  alias :leap? :leap_year?

  # see lines 665-687 in calendrica-3.0.cl
  # Return the fixed date equivalent to the Gregorian date 'g_date'.
  def to_fixed(g_date = self)
    month = g_date.month
    day   = g_date.day
    year  = g_date.year
    ((epoch - 1) + 
      (365 * (year - 1)) + 
      quotient(year - 1, 4) - 
      quotient(year - 1, 100) + 
      quotient(year - 1, 400) + 
      quotient((367 * month) - 362, 12) +
        (if month <= 2
          0
        elsif leap_year?(year)
          -1
        else
          -2
        end) + 
      day)
  end
  
  # see lines 735-756 in calendrica-3.0.cl
  # Return the Gregorian date corresponding to fixed date 'date'.
  def to_calendar(f_date = self.fixed)
    year        = year_from_fixed(f_date)
    prior_days  = f_date - new_year(year).fixed
    correction = (if f_date < date(year, MARCH, 1).fixed
                    0
                  elsif leap_year?(year)
                    1
                  else
                    2
                  end)
    month = quotient((12 * (prior_days + correction)) + 373, 367)
    day = 1 + f_date - date(year, month, 1).fixed
    DateStruct.new(year, month, day)
  end

protected
  
  # see lines 689-715 in calendrica-3.0.cl
  # Return the Gregorian year corresponding to the fixed date 'date'.
  def year_from_fixed(date)
    d0   = date - epoch
    n400 = quotient(d0, 146097)
    d1   = d0 % 146097
    n100 = quotient(d1, 36524)
    d2   = d1 % 36524
    n4   = quotient(d2, 1461)
    d3   = d2 % 1461
    n1   = quotient(d3, 365)
    year = (400 * n400) + (100 * n100) + (4 * n4) + n1
    ((n100 == 4) || (n1 == 4)) ? year : (year + 1)
  end

  # see lines 779-801 in calendrica-3.0.cl
  # Return the fixed date equivalent to the Gregorian date 'g_date'.
  # Alternative calculation.
  def alt_to_fixed(g_date)
    month = standard_month(g_date)
    day   = standard_day(g_date)
    year  = standard_year(g_date)
    m     = amod(month - 2, 12)
    y     = year + quotient(month + 9, 12)
    ((gregorian_epoch - 1)  +
      -306                   +
      365 * (y - 1)          +
      quotient(y - 1, 4)     +
      -quotient(y - 1, 100)  +
      quotient(y - 1, 400)   +
      quotient(3 * m - 1, 5) +
      30 * (m - 1)           +
      day)
  end
  
  # see lines 803-825 in calendrica-3.0.cl
  # Return the Gregorian date corresponding to fixed date 'date'.
  # Alternative calculation.
  def alt_to_calendar(date)
    y = to_calendar(gregorian_epoch - 1 + date + 306)
    prior_days = date - to_fixed(date(y - 1, MARCH, 1))
    month = amod(quotient(5 * prior_days + 2, 153) + 3, 12)
    year  = y - quotient(month + 9, 12)
    day   = date - to_fixed(date(year, month, 1)) + 1
    date(year, month, day)
  end
  
  # see lines 827-841 in calendrica-3.0.cl
  # Return the Gregorian year corresponding to the fixed date 'date'.
  # Alternative calculation.
  def alt_gregorian_year_from_fixed(date)
    approx = quotient(date - gregorian_epoch + 2, 146097/400.0)
    start  = (gregorian_epoch +
      (365 * approx)         +
      quotient(approx, 4)    +
      -quotient(approx, 100) +
      quotient(approx, 400))
    (date < start) ? approx : (approx + 1)
  end
end

class GregorianYear < Calendar
  attr_accessor :year, :fixed

  include Calendrical::KdayCalculations
  include Calendrical::Ecclesiastical
  include Calendrical::Dates
  
  def initialize(year)
    @year = year
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
      GregorianDate[the_year]
    end
  end 
  
  def range
    new_year..year_end
  end
  
  def fixed
    @fixed ||= to_fixed
  end
  
  def to_fixed
    new_year.fixed
  end 
  
  def each_day(&block)
    range.each(&block)
  end
end

  