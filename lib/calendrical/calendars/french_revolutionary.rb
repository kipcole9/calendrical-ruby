class FrenchRevolutionaryDate < Calendar
  
  # see lines 4222-4226 in calendrica-3.0.cl
  # Fixed date of start of the French Revolutionary calendar.
  def self.epoch
    GregorianDate[1792, SEPTEMBER, 22].fixed
  end

  # see lines 4235-4241 in calendrica-3.0.cl
  # Return Universal Time of true midnight at the end of
  # fixed date, date.
  def midnight_in_paris(f_date)
    # tricky bug: I was using midDAY!!! So French Revolutionary was failing...
    universal_from_standard(midnight(f_date + 1, PARIS).moment, PARIS)
  end

  # see lines 4243-4252 in calendrica-3.0.cl
  # Return fixed date of French Revolutionary New Year on or
  # before fixed date, date.
  def french_new_year_on_or_before(f_date)
    approx = estimate_prior_solar_longitude(AUTUMN, midnight_in_paris(f_date))
    next_of(approx.floor - 1, 
        lambda {|day| AUTUMN <= solar_longitude(midnight_in_paris(day))})
  end

  # see lines 4254-4267 in calendrica-3.0.cl
  # Return fixed date of French Revolutionary date, f_date
  def to_fixed(fr_date)
    mmonth = fr_date.month
    dday   = fr_date.day
    yyear  = fr_date.year
    new_year = french_new_year_on_or_before((epoch + 180 + MEAN_TROPICAL_YEAR * (yyear - 1)).floor)
    new_year - 1 + 30 * (mmonth - 1) + dday
  end

  # see lines 4269-4278 in calendrica-3.0.cl
  # Return French Revolutionary date of fixed date, date.
  def to_calendar(f_date = self.fixed)
    new_year = french_new_year_on_or_before(f_date)
    yyear  = ((new_year - epoch) / MEAN_TROPICAL_YEAR).round + 1
    mmonth = quotient(f_date - new_year, 30) + 1
    dday   = ((f_date - new_year) % 30) + 1
    Date.new(yyear, mmonth, dday)
  end

  # see lines 4280-4286 in calendrica-3.0.cl
  # Return True if year, f_year, is a leap year on the French
  # Revolutionary calendar.
  def leap_year?(f_year)
    (f_year % 4) == 0  && 
    ![100, 200, 300].include?(f_year % 400)  &&
    (f_year % 4000) != 0
  end

protected

  # see lines 4288-4302 in calendrica-3.0.cl
  # Return fixed date of French Revolutionary date, f_date."""
  def fixed_from_arithmetic_french(fr_date)
    mmonth = fr_date.month
    dday   = fr_date.day
    yyear  = fr_date.year

    (epoch - 1  +
      365 * (yyear - 1)         +
      quotient(yyear - 1, 4)    -
      quotient(yyear - 1, 100)  +
      quotient(yyear - 1, 400)  -
      quotient(yyear - 1, 4000) +
      30 * (mmonth - 1)         +
      dday)
  end

  # see lines 4304-4325 in calendrica-3.0.cl
  # Return French Revolutionary date [year, month, day] of fixed date, date.
  def arithmetic_french_from_fixed(f_date)
    approx = quotient(f_date - epoch + 2, 1460969/4000.0) + 1
    yyear   = (f_date < fixed_from_arithmetic_french(date(approx, 1, 1))) ? (approx - 1) : approx
    mmonth  = 1 + quotient(f_date - fixed_from_arithmetic_french(date(yyyear, 1, 1)), 30)
    dday    = date - fixed_from_arithmetic_french(date(yyear, mmonth, 1)) + 1
    date(yyear, mmonth, dday)
  end
end
