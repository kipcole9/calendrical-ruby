class ISOCalendar < GregorianCalendar
  # see lines 979-981 in calendrica-3.0.cl
  # Return the ISO date data structure."""
  def date(year, week, day)
    [year, week, day]
  end

  # see lines 983-985 in calendrica-3.0.cl
  # Return the week of ISO date 'date'.
  def week(date)
    date[1]
  end

  # see lines 987-989 in calendrica-3.0.cl
  #  Return the day of ISO date 'date'.
  def day(date)
    date[2]
  end

  # see lines 991-993 in calendrica-3.0.cl
  # Return the year of ISO date 'date'.
  def year(date)
    date[0]
  end

  # see lines 995-1005 in calendrica-3.0.cl
  # Return the fixed date equivalent to ISO date 'i_date'.
  def to_fixed(i_date):
    week = iso_week(i_date)
    day  = iso_day(i_date)
    year = iso_year(i_date)
    nth_kday(week, SUNDAY, GregorignaCalendar.date(year - 1, DECEMBER, 28)) + day
  end

  # see lines 1007-1022 in calendrica-3.0.cl
  # Return the ISO date corresponding to the fixed date 'date'."""
  def to_calendar(date)
    approx = gregorian_year_from_fixed(date - 3)
    year   = date >= to_fixed(iso_date(approx + 1, 1, 1)) ? approx + 1 : approx
    week   = 1 + quotient(date - to_fixed(iso_date(year, 1, 1)), 7)
    day    = amod(date - rd(0), 7)
    date(year, week, day)
  end

  # see lines 1024-1032 in calendrica-3.0.cl
  # Return True if ISO year 'i_year' is a long (53-week) year."""
  def long_year?(i_year)
    jan1  = day_of_week_from_fixed(gregorian_new_year(i_year))
    dec31 = day_of_week_from_fixed(gregorian_year_end(i_year))
    (jan1 == THURSDAY) || (dec31 == THURSDAY)
  end
end
