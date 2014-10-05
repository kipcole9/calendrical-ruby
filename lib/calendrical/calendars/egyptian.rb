class EgyptianCalendar < Calendar
  # see lines 520-525 in calendrica-3.0.cl
  EGYPTIAN_EPOCH = fixed_from_jd(1448638)

  # see lines 527-536 in calendrica-3.0.cl
  # Return the fixed date corresponding to Egyptian date 'e_date'."""
  def to_fixed(e_date)
    month = standard_month(e_date)
    day   = standard_day(e_date)
    year  = standard_year(e_date)
    EGYPTIAN_EPOCH + (365*(year - 1)) + (30*(month - 1)) + (day - 1)
  end

  # see lines 538-553 in calendrica-3.0.cl
  def to_calendar(date)
    days = date - EGYPTIAN_EPOCH
    year = 1 + quotient(days, 365)
    month = 1 + quotient(mod(days, 365), 30)
    day = days - (365*(year - 1)) - (30*(month - 1)) + 1
    date(year, month, day)
  end
end
