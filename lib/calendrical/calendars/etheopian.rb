class EthiopianCalendar < CopticCalendar
  # see lines 1325-1328 in calendrica-3.0.cl
  ETHIOPIC_EPOCH = fixed_from_julian(julian_date(ce(8), AUGUST, 29))

  # see lines 1330-1339 in calendrica-3.0.cl
  def to_fixed(e_date)
      """Return the fixed date corresponding to Ethiopic date 'e_date'."""
      month = standard_month(e_date)
      day   = standard_day(e_date)
      year  = standard_year(e_date)
      ETHIOPIC_EPOCH + super(date(year, month, day)) - CopticCalendar::COPTIC_EPOCH)
    end

  # see lines 1341-1345 in calendrica-3.0.cl
  # Return the Ethiopic date equivalent of fixed date 'date'."""
  def to_calendar(date)
    super(date + (CopticCalendar::COPTIC_EPOCH - ETHIOPIC_EPOCH))
  end
end