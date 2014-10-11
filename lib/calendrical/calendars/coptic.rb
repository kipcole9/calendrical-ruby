class CopticDate < Calendar

  def inspect
    "#{year}-#{month}-#{day} Coptic"
  end
  
  # see lines 1281-1284 in calendrica-3.0.cl
  def self.epoch
    JulianDate[284, AUGUST, 29].fixed
  end
  
  # see lines 1286-1289 in calendrica-3.0.cl
  # Return True if Coptic year 'c_year' is a leap year
  # in the Coptic calendar."""
  def leap_year?(c_year)
    c_year % 4 == 3
  end

  # see lines 1291-1301 in calendrica-3.0.cl
  # Return the fixed date of Coptic date 'c_date'."""
  def to_fixed(c_date = self)
    month = c_date.month
    day   = c_date.day
    year  = c_date.year
    (epoch - 1  +
            365 * (year - 1)  +
            quotient(year, 4.0) +
            30 * (month - 1)  +
            day)
  end

  # see lines 1303-1318 in calendrica-3.0.cl
  # Return the Coptic date equivalent of fixed date 'f_date'.
  def to_calendar(f_date = self.fixed)
    yyear  = quotient((4 * (f_date - epoch) + 1463), 1461.0)
    mmonth = 1 + quotient(f_date - date(yyear, 1, 1).fixed, 30.0)
    dday   = f_date + 1 - date(yyear, mmonth, 1).fixed
    Date.new(yyear, mmonth, dday)
  end

  # see lines 1347-1360 in calendrica-3.0.cl
  # Return the list of the fixed dates of Coptic month 'c_month',
  # day 'c_day' that occur in Gregorian year 'g_year'.
  def coptic_in_gregorian(c_month, c_day, g_year)
    jan1  = GregorianCalendar.new_year(g_year)
    y     = date(jan1).year
    date1 = date(y, c_month, c_day).fixed
    date2 = date(y + 1, c_month, c_day).fixed
    list_range(date1..date2, GregorianCalendar.year_range(g_year))
  end

  # see lines 1362-1366 in calendrica-3.0.cl
  # Retuen the list of zero or one fixed dates of Coptic Christmas
  # dates in Gregorian year 'g_year'.
  def christmas(g_year)
    GregorianDate[date(g_year, 4, 29).fixed]
  end
end


