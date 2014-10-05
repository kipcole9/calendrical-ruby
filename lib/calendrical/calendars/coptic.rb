class CopticCalendar < Calendar
  # see lines 1281-1284 in calendrica-3.0.cl
  COPTIC_EPOCH = fixed_from_julian(julian_date(ce(284), AUGUST, 29))

  # see lines 1286-1289 in calendrica-3.0.cl
  # Return True if Coptic year 'c_year' is a leap year
  # in the Coptic calendar."""
  def leap_year?(c_year)
    c_year % 4 == 3
  end

  # see lines 1291-1301 in calendrica-3.0.cl
  # Return the fixed date of Coptic date 'c_date'."""
  def to_fixed(c_date):
    month = standard_month(c_date)
    day   = standard_day(c_date)
    year  = standard_year(c_date)
    (COPTIC_EPOCH - 1  +
            365 * (year - 1)  +
            quotient(year, 4) +
            30 * (month - 1)  +
            day)
  end

  # see lines 1303-1318 in calendrica-3.0.cl
  # Return the Coptic date equivalent of fixed date 'date'."""
  def to_calendar(date):
    year  = quotient((4 * (date - COPTIC_EPOCH)) + 1463, 1461)
    month = 1 + quotient(date - fixed_from_coptic(coptic_date(year, 1, 1)), 30)
    day   = date + 1 - fixed_from_coptic(coptic_date(year, month, 1))
    date(year, month, day)
  end

  # see lines 1347-1360 in calendrica-3.0.cl
  # Return the list of the fixed dates of Coptic month 'c_month',
  # day 'c_day' that occur in Gregorian year 'g_year'."""
  def coptic_in_gregorian(c_month, c_day, g_year):
    jan1  = GregorianCalendar.new_year(g_year)
    y     = standard_year(coptic_from_fixed(jan1))
    date1 = to_fixed(coptic_date(y, c_month, c_day))
    date2 = to_fixed(coptic_date(y+1, c_month, c_day))
    list_range(date1..date2, GregorianCalendar.year_range(g_year))
  end

  # see lines 1362-1366 in calendrica-3.0.cl
  # Retuen the list of zero or one fixed dates of Coptic Christmas
  # dates in Gregorian year 'g_year'."""
  def christmas(g_year):
    coptic_in_gregorian(4, 29, g_year)
  end
end


