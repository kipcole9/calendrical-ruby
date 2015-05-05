module Coptic
  def self.Date(*args)
    Coptic::Date[*args]
  end
  
  class Date < Calendar
    # see lines 1281-1284 in calendrica-3.0.cl
    def self.epoch
      Julian::Date[284, AUGUST, 29].fixed
    end
  
    def inspect
      "#{year}-#{month}-#{day} Coptic"
    end
  
    def to_s
      month_name = I18n.t('coptic.months')[month - 1]
      "#{day} #{month_name}, #{year}"
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
      mmonth = c_date.month
      dday   = c_date.day
      yyear  = c_date.year
      (epoch - 1  +
              365 * (yyear - 1)  +
              quotient(yyear, 4.0) +
              30 * (mmonth - 1)  +
              dday)
    end

    # see lines 1303-1318 in calendrica-3.0.cl
    # Return the Coptic date equivalent of fixed date 'f_date'.
    def to_calendar(f_date = self.fixed)
      yyear  = quotient((4 * (f_date - epoch) + 1463), 1461.0)
      mmonth = 1 + quotient(f_date - date(yyear, 1, 1).fixed, 30.0)
      dday   = f_date + 1 - date(yyear, mmonth, 1).fixed
      Calendar::Date.new(yyear, mmonth, dday)
    end

    # see lines 1362-1366 in calendrica-3.0.cl
    # Return the list of zero or one fixed dates of Coptic Christmas
    # dates in Gregorian year 'g_year'.
    def christmas(g_year = self.year)
      Coptic::Date[g_year, 4, 29]
    end
  end
end


