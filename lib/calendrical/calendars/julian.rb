class JulianDate < Calendar
  include Calendrical::Ecclesiastical
  include Calendrical::Kday
  include Calendrical::Dates
  
  def inspect
    "#{year}-#{month}-#{day} Julian"
  end
  
  def to_s
    day_name = I18n.t('julian.days')[day_of_week]
    month_name = I18n.t('julian.months')[month - 1]
    suffix = year > 0 ? 'ce' : 'bce'
    "#{day_name}, #{day} #{month_name} #{year.abs}#{suffix}"
  end
  
  # see lines 1042-1045 in calendrica-3.0.cl
  def self.epoch
    GregorianDate[0, DECEMBER, 30].fixed
  end

  # see lines 1057-1060 in calendrica-3.0.cl
  # Return True if Julian year 'j_year' is a leap year in
  # the Julian calendar.
  def leap_year?(j_year = self.year)
    (j_year % 4) == (j_year > 0 ? 0 : 3)
  end

  # see lines 1062-1082 in calendrica-3.0.cl
  # Return the fixed date equivalent to the Julian date 'j_date'.
  def to_fixed(j_date = self)
    month = j_date.month
    day   = j_date.day
    year  = j_date.year
    y     = year < 0  ? year + 1 : year
    (epoch - 1 + (365 * (y - 1)) + quotient(y - 1, 4) + quotient(367 * month - 362, 12) +
            (if month <= 2
              0
            elsif leap_year?(year)
              -1
            else
              -2
            end) +
    day)
  end

  # see lines 1084-1111 in calendrica-3.0.cl
  # Return the Julian date corresponding to fixed date 'date'.
  def to_calendar(f_date = self.fixed)
    approx     = quotient(((4 * (f_date - epoch))) + 1464, 1461)
    year       = approx <= 0 ? approx - 1 : approx
    prior_days = f_date - date(year, JANUARY, 1).fixed
    correction = if f_date < date(year, MARCH, 1).fixed
                   0
                 elsif leap_year?(year)
                   1
                 else
                   2
                 end
    month      = quotient(12*(prior_days + correction) + 373, 367)
    day        = 1 + (f_date - date(year, month, 1).fixed)
    Date.new(year, month, day)
  end

  # see lines 1250-1266 in calendrica-3.0.cl
  # Return the list of the fixed dates of Julian month 'j_month', day
  # 'j_day' that occur in Gregorian year 'g_year'.
  def julian_in_gregorian
    jan1 = new_year(self.year).fixed
    y    = to_calendar(jan1).year
    y_prime = (y == -1) ? 1 : (y + 1)
    date1 = date(y, self.month, self.day).fixed
    date2 = date(y_prime, self.month, self.day).fixed
    list_range(date1..date2, year_range(self.year))
  end
end