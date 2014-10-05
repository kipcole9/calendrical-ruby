class ArmenianCalendar < EgyptianCalendar
  # see lines 560-564 in calendrica-3.0.cl
  ARMENIAN_EPOCH = rd(201443)

  # see lines 566-575 in calendrica-3.0.cl
  # Return the fixed date corresponding to Armenian date 'a_date'."""
  def to_fixed(a_date):
      month = standard_month(a_date)
      day   = standard_day(a_date)
      year  = standard_year(a_date)
      (ARMENIAN_EPOCH + super(super.date(year, month, day)) - EGYPTIAN_EPOCH)

  # see lines 577-581 in calendrica-3.0.cl
  # Return the Armenian date corresponding to fixed date 'date'."""
  def to_calendard(date):
    super(date + (EGYPTIAN_EPOCH - ARMENIAN_EPOCH))
  end
end