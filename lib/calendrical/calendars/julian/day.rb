module Julian
  class Date < Calendar
    # include Calendrical::Kday
    # include Calendrical::Dates
  
    # see lines 1042-1045 in calendrica-3.0.cl
    def self.epoch
      Gregorian::Date[0, DECEMBER, 30].fixed
    end
  
    def inspect
      "#{year}-#{month}-#{day} J"
    end
  
    def to_s
      day_name = I18n.t('julian.days')[day_of_week]
      month_name = I18n.t('julian.months')[month - 1]
      suffix = year > 0 ? 'ce' : 'bce'
      "#{day_name}, #{day} #{month_name} #{year.abs}#{suffix}"
    end

    # see lines 1062-1082 in calendrica-3.0.cl
    # Return the fixed date equivalent to the Julian date 'j_date'.
    def to_fixed(j_date = self)
      mmonth = j_date.month
      dday   = j_date.day
      yyear  = j_date.year
      y     = yyear < 0  ? yyear + 1 : yyear
      (epoch - 1 + (365 * (y - 1)) + quotient(y - 1, 4) + quotient(367 * mmonth - 362, 12) +
              (if mmonth <= 2
                0
              elsif Julian::Year[yyear].leap_year?
                -1
              else
                -2
              end) +
      dday)
    end

    # see lines 1084-1111 in calendrica-3.0.cl
    # Return the Julian date corresponding to fixed date 'date'.
    def to_calendar(f_date = self.fixed)
      approx     = quotient(((4 * (f_date - epoch))) + 1464, 1461)
      yyear       = approx <= 0 ? approx - 1 : approx
      prior_days = f_date - date(yyear, JANUARY, 1).fixed
      correction = if f_date < date(yyear, MARCH, 1).fixed
                     0
                   elsif Julian::Year[yyear].leap_year?
                     1
                   else
                     2
                   end
      mmonth      = quotient(12*(prior_days + correction) + 373, 367)
      dday        = 1 + (f_date - date(yyear, mmonth, 1).fixed)
      Calendar::Date.new(yyear, mmonth, dday)
    end
  end
end