class FrenchRevolutionary < Calendar
  # see lines 4222-4226 in calendrica-3.0.cl
  # Fixed date of start of the French Revolutionary calendar."""
  FRENCH_EPOCH = fixed_from_gregorian(gregorian_date(1792, SEPTEMBER, 22))

  # see lines 4228-4233 in calendrica-3.0.cl
  PARIS = location(angle(48, 50, 11), angle(2, 20, 15), 27.meters, 1.hr)

  # see lines 4235-4241 in calendrica-3.0.cl
  # Return Universal Time of true midnight at the end of
  # fixed date, date.
  def midnight_in_paris(date):
    # tricky bug: I was using midDAY!!! So French Revolutionary was failing...
    universal_from_standard(midnight(date + 1, PARIS), PARIS)
  end

  # see lines 4243-4252 in calendrica-3.0.cl
  # Return fixed date of French Revolutionary New Year on or
  # before fixed date, date.
  def french_new_year_on_or_before(date):
    approx = estimate_prior_solar_longitude(AUTUMN, midnight_in_paris(date))
    next(floor(approx) - 1, 
        lambda {|day| AUTUMN <= solar_longitude(midnight_in_paris(day)))
  end

  # see lines 4254-4267 in calendrica-3.0.cl
  # Return fixed date of French Revolutionary date, f_date"""
  def to_fixed(f_date):
    month = standard_month(f_date)
    day   = standard_day(f_date)
    year  = standard_year(f_date)
    new_year = french_new_year_on_or_before(
                  floor(FRENCH_EPOCH + 
                        180 + 
                        MEAN_TROPICAL_YEAR * (year - 1)))
    new_year - 1 + 30 * (month - 1) + day
  end

  # see lines 4269-4278 in calendrica-3.0.cl
  # Return French Revolutionary date of fixed date, date."""
  def to_calendar(date):
    new_year = french_new_year_on_or_before(date)
    year  = iround((new_year - FRENCH_EPOCH) / MEAN_TROPICAL_YEAR) + 1
    month = quotient(date - new_year, 30) + 1
    day   = mod(date - new_year, 30) + 1
    date(year, month, day)
  end

  # see lines 4280-4286 in calendrica-3.0.cl
  # Return True if year, f_year, is a leap year on the French
  # Revolutionary calendar.
  def leap_year?(f_year)
    (f_year % 4) == 0  && 
    ![100, 200, 300].include?(f_year % 400)  &&
    (f_year % 4000) != 0
  end

  # see lines 4288-4302 in calendrica-3.0.cl
  # Return fixed date of French Revolutionary date, f_date."""
  def fixed_from_arithmetic_french(f_date)
    month = standard_month(f_date)
    day   = standard_day(f_date)
    year  = standard_year(f_date)

    return (FRENCH_EPOCH - 1         +
            365 * (year - 1)         +
            quotient(year - 1, 4)    -
            quotient(year - 1, 100)  +
            quotient(year - 1, 400)  -
            quotient(year - 1, 4000) +
            30 * (month - 1)         +
            day)
  end

  # see lines 4304-4325 in calendrica-3.0.cl
  # Return French Revolutionary date [year, month, day] of fixed
  #   date, date.
  def arithmetic_french_from_fixed(date)
    approx = quotient(date - FRENCH_EPOCH + 2, 1460969/4000) + 1
    year   = (date < fixed_from_arithmetic_french(french_date(approx, 1, 1))) ? (approx - 1) : approx
    month  = 1 + quotient(date - fixed_from_arithmetic_french(french_date(year, 1, 1)), 30)
    day    = date - fixed_from_arithmetic_french(french_date(year, month, 1)) + 1
    date(year, month, day)
  end
end
