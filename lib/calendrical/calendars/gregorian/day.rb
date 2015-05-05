module Gregorian
  class Date < Calendar
    include Calendrical::Dates
  
    def inspect
      to_date.inspect
    end
  
    def to_s
      day_name = I18n.t('gregorian.days')[day_of_week]
      month_name = I18n.t('gregorian.months')[month - 1]
      "#{day_name}, #{day} #{month_name} #{year}"
    end
  
    def self.epoch
      rd(1)
    end
    
    def range
      @range ||= self..self
    end
  
    def to_date
      return nil unless year.present?
      ::Date.new(year, month, day)
    end

    def leap_year?(yyear = self.year)
      Gregorian::Year[yyear].leap_year?
    end

    # see lines 665-687 in calendrica-3.0.cl
    # Return the fixed date equivalent to the Gregorian date 'g_date'.
    def to_fixed(g_date = self)
      mmonth = g_date.month
      dday   = g_date.day
      yyear  = g_date.year
      ((epoch - 1) + 
        (365 * (yyear - 1)) + 
        quotient(yyear - 1, 4) - 
        quotient(yyear - 1, 100) + 
        quotient(yyear - 1, 400) + 
        quotient((367 * mmonth) - 362, 12) +
          (if mmonth <= 2
            0
          elsif leap_year?(yyear)
            -1
          else
            -2
          end) + 
        dday)
    end
  
    # see lines 735-756 in calendrica-3.0.cl
    # Return the Gregorian date corresponding to fixed date 'date'.
    def to_calendar(f_date = self.to_fixed)
      yyear   = year_from_fixed(f_date)
      prior_days  = f_date - Gregorian::Date[yyear, 1, 1].fixed
      correction  = (if f_date < date(yyear, MARCH, 1).fixed
                      0
                    elsif leap_year?(yyear)
                      1
                    else
                      2
                    end)
      month = quotient((12 * (prior_days + correction)) + 373, 367)
      day = 1 + f_date - date(yyear, month, 1).fixed
      Calendar::Date.new(yyear, month, day)
    end

  protected
  
    def validate_date!
      ::Date.new(year, month, day)
    end
  
    # see lines 689-715 in calendrica-3.0.cl
    # Return the Gregorian year corresponding to the fixed date 'date'.
    def year_from_fixed(date)
      d0   = date - epoch
      n400 = quotient(d0, 146097)
      d1   = d0 % 146097
      n100 = quotient(d1, 36524)
      d2   = d1 % 36524
      n4   = quotient(d2, 1461)
      d3   = d2 % 1461
      n1   = quotient(d3, 365)
      year = (400 * n400) + (100 * n100) + (4 * n4) + n1
      ((n100 == 4) || (n1 == 4)) ? year : (year + 1)
    end

    # see lines 779-801 in calendrica-3.0.cl
    # Return the fixed date equivalent to the Gregorian date 'g_date'.
    # Alternative calculation.
    def alt_to_fixed(g_date)
      month = standard_month(g_date)
      day   = standard_day(g_date)
      year  = standard_year(g_date)
      m     = amod(month - 2, 12)
      y     = year + quotient(month + 9, 12)
      ((gregorian_epoch - 1)  +
        -306                   +
        365 * (y - 1)          +
        quotient(y - 1, 4)     +
        -quotient(y - 1, 100)  +
        quotient(y - 1, 400)   +
        quotient(3 * m - 1, 5) +
        30 * (m - 1)           +
        day)
    end
  
    # see lines 803-825 in calendrica-3.0.cl
    # Return the Gregorian date corresponding to fixed date 'date'.
    # Alternative calculation.
    def alt_to_calendar(date)
      y = to_calendar(gregorian_epoch - 1 + date + 306)
      prior_days = date - to_fixed(date(y - 1, MARCH, 1))
      month = amod(quotient(5 * prior_days + 2, 153) + 3, 12)
      year  = y - quotient(month + 9, 12)
      day   = date - to_fixed(date(year, month, 1)) + 1
      date(year, month, day)
    end
  
    # see lines 827-841 in calendrica-3.0.cl
    # Return the Gregorian year corresponding to the fixed date 'date'.
    # Alternative calculation.
    def alt_year_from_fixed(date)
      approx = quotient(date - gregorian_epoch + 2, 146097/400.0)
      start  = (gregorian_epoch +
        (365 * approx)         +
        quotient(approx, 4)    +
        -quotient(approx, 100) +
        quotient(approx, 400))
      (date < start) ? approx : (approx + 1)
    end
  end
end

