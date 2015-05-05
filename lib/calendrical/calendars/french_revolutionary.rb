require "#{File.dirname(__FILE__)}/../roman_numerals.rb"

module FrenchRevolutionary
  def self.Date(*args)
    FrenchRevolutionary::Date[*args]
  end
  
  class Date < Calendar
    
    # see lines 4222-4226 in calendrica-3.0.cl
    # Fixed date of start of the French Revolutionary calendar.
    def self.epoch
      Gregorian::Date[1792, SEPTEMBER, 22].fixed
    end
  
    def inspect
      "#{year}-#{month}-#{day} French Revolutionary"
    end
  
    def to_s
      day_name = I18n.t('french_revolutionary.days')[day_of_week]
      month_name = I18n.t('french_revolutionary.months')[month - 1]
      "#{day_name}, #{day} #{month_name} #{year.to_s_roman}"
    end

    # see lines 4254-4267 in calendrica-3.0.cl
    # Return fixed date of French Revolutionary date, f_date
    def to_fixed(fr_date = self)
      mmonth = fr_date.month
      dday   = fr_date.day
      yyear  = fr_date.year
      new_year = new_year_on_or_before((epoch + 180 + MEAN_TROPICAL_YEAR * (yyear - 1)).floor)
      new_year - 1 + 30 * (mmonth - 1) + dday
    end

    # see lines 4269-4278 in calendrica-3.0.cl
    # Return French Revolutionary date of fixed date, date.
    def to_calendar(f_date = self.fixed)
      new_year = new_year_on_or_before(f_date)
      yyear  = ((new_year - epoch) / MEAN_TROPICAL_YEAR).round + 1
      mmonth = quotient(f_date - new_year, 30) + 1
      dday   = ((f_date - new_year) % 30) + 1
      self.class::Date.new(yyear, mmonth, dday)
    end

    # 10 day weeks, first day of the month is also
    # first day of the week
    def day_of_week
      dnum = day
      dnum -= 10 if dnum > 20
      dnum -= 10 if dnum > 10
      dnum -= 1
      dnum
    end
  
    # see lines 4243-4252 in calendrica-3.0.cl
    # Return fixed date of French Revolutionary New Year on or
    # before fixed date, date.
    def new_year_on_or_before(f_date = self.fixed)
      approx = estimate_prior_solar_longitude(AUTUMN, midnight_in_paris(f_date))
      next_of(approx.floor - 1, 
          lambda {|day| AUTUMN <= solar_longitude(midnight_in_paris(day))})
    end

  protected

    # see lines 4235-4241 in calendrica-3.0.cl
    # Return Universal Time of true midnight at the end of
    # fixed date, date.
    def midnight_in_paris(f_date = self.fixed)
      universal_from_standard(midnight(f_date + 1, PARIS).moment, PARIS)
    end

    # see lines 4280-4286 in calendrica-3.0.cl
    # Return True if year, f_year, is a leap year on the French
    # Revolutionary calendar.
    def arithmetic_leap_year?(f_year = self.year)
      (f_year % 4) == 0  && 
      ![100, 200, 300].include?(f_year % 400)  &&
      (f_year % 4000) != 0
    end

    # see lines 4288-4302 in calendrica-3.0.cl
    # Return fixed date of French Revolutionary date, f_date.
    def fixed_from_arithmetic_french(fr_date = self)
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
    def arithmetic_french_from_fixed(f_date = self.fixed)
      approx = quotient(f_date - epoch + 2, 1460969/4000.0) + 1
      yyear   = (f_date < fixed_from_arithmetic_french(date(approx, 1, 1))) ? (approx - 1) : approx
      mmonth  = 1 + quotient(f_date - fixed_from_arithmetic_french(date(yyear, 1, 1)), 30)
      dday    = f_date - fixed_from_arithmetic_french(date(yyear, mmonth, 1)) + 1
      Date.new(yyear, mmonth, dday)
    end
  end
end