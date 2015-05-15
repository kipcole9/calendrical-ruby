class Julian::Year < Gregorian::Year
  def leap_year?(j_year = self.year)
    (j_year % 4) == (j_year > 0 ? 0 : 3)
  end
  alias :leap? :leap_year?

  def quarter(n)
    Julian::Quarter[year, n]
  end
  
  def month(n)
    Julian::Month[year, n]
  end
  
  def week(n)
    Julian::Week[year, n]
  end

  # Need to do a little traffic managment here since
  # we're going to be called sometimes with just a year
  # and sometimes with a date formation from the super class
  def date(g_year, g_month = nil, g_day = nil)
    the_year = g_year.is_a?(Fixnum) ? g_year : g_year.year
    if g_month && g_day
      Julian::Date[the_year, g_month, g_day]
    else
      Julian::Year[the_year]
    end
  end
end
