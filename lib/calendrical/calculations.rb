module Calendrical
  module Calculations
    include Calendrical::Days
    include Calendrical::Months
    
    def +(other)
      value = other.respond_to?(:fixed) ? other.fixed : other
      date(self.fixed + other)
    end
    
    def -(other)
      value = other.respond_to?(:fixed) ? other.fixed : other
      date(self.fixed - value)
    end
    
    # Conversion handy when doing date arithmetic
    def to_i
      to_fixed
    end
    
    # Convert to date, but since the system works only in Gregorian
    # we convert to that first
    def to_d
      GregorianDate[self.fixed].to_date
    end
    
    # see lines 717-721 in calendrica-3.0.cl
    # Return the fixed date of January 1 in Gregorian year 'g_year'.
    def new_year(g_year = self.year)
      date(g_year, JANUARY, 1)
    end

    # see lines 723-727 in calendrica-3.0.cl
    # Return the fixed date of December 31 in Gregorian year 'g_year'."""
    def year_end(g_year = self.year)
      date(g_year, DECEMBER, 31)
    end

    # see lines 42-49 in calendrica-3.0.errata.cl
    # Return the day number in the year of Gregorian date 'g_date'."""
    def day_number(g_date = self)
      date_difference(date(g_date.year - 1, DECEMBER, 31), g_date)
    end

    # see lines 53-58 in calendrica-3.0.cl
    # Return the days remaining in the year after Gregorian date 'g_date'.
    def days_remaining(g_date = self)
      date_difference(g_date, date(g_date.year, DECEMBER, 31))
    end

    # see lines 849-853 in calendrica-3.0.cl
    # Return the fixed date of the k-day on or before fixed date 'date'.
    # k=0 means Sunday, k=1 means Monday, and so on."""
    def kday_on_or_before(k, g_date = self)
      g_date - day_of_week_from_fixed(g_date - k)
    end

    # see lines 855-859 in calendrica-3.0.cl
    # Return the fixed date of the k-day on or after fixed date 'date'.
    # k=0 means Sunday, k=1 means Monday, and so on.
    def kday_on_or_after(k, g_date = self)
      kday_on_or_before(k, g_date + 6)
    end

    # see lines 861-865 in calendrica-3.0.cl
    # Return the fixed date of the k-day nearest fixed date 'date'.
    # k=0 means Sunday, k=1 means Monday, and so on.
    def kday_nearest(k, g_date = self)
      kday_on_or_before(k, g_date + 3)
    end

    # see lines 867-871 in calendrica-3.0.cl
    # Return the fixed date of the k-day after fixed date 'date'.
    # k=0 means Sunday, k=1 means Monday, and so on.
    def kday_after(k, g_date = self)
      kday_on_or_before(k, g_date + 7)
    end

    # see lines 873-877 in calendrica-3.0.cl
    # Return the fixed date of the k-day before fixed date 'date'.
    # k=0 means Sunday, k=1 means Monday, and so on.
    def kday_before(k, g_date = self)
      kday_on_or_before(k, g_date - 1)
    end

    # see lines 62-74 in calendrica-3.0.errata.cl
    # Return the fixed date of n-th k-day after Gregorian date 'g_date'.
    # If n>0, return the n-th k-day on or after  'g_date'.
    # If n<0, return the n-th k-day on or before 'g_date'.
    # If n=0, return BOGUS.
    # A k-day of 0 means Sunday, 1 means Monday, and so on.
    def nth_kday(n, k, g_date = self)
      if n > 0
        date(kday_before(k, g_date).fixed + 7*n)
      elsif n < 0
        date(kday_after(k, g_date).fixed + 7*n)
      else
        return BOGUS
      end
    end

    # see lines 892-897 in calendrica-3.0.cl
    # Return the fixed date of first k-day on or after Gregorian date 'g_date'.
    # A k-day of 0 means Sunday, 1 means Monday, and so on.
    def first_kday(k, g_date = self)
      nth_kday(1, k, g_date)
    end

    # see lines 899-904 in calendrica-3.0.cl
    # Return the fixed date of last k-day on or before Gregorian date 'g_date'.
    # A k-day of 0 means Sunday, 1 means Monday, and so on.
    def last_kday(k, g_date = self)
      nth_kday(-1, k - 1, g_date)
    end

    # see lines 729-733 in calendrica-3.0.cl
    # Return the range of fixed dates in Gregorian year 'g_year'.
    def year_range(g_year = self.year)
      interval(new_year(g_year).fixed, year_end(g_year).fixed)
    end

    # see lines 758-763 in calendrica-3.0.cl
    # Return the number of days from Gregorian date 'g_date1'
    # till Gregorian date 'g_date2'.
    def date_difference(g_date1, g_date2 = self)
      g_date2.fixed - g_date1.fixed
    end

    # Return sunset time in Urbana, Ill, on Gregorian date 'gdate'."""
    def urbana_sunset(gdate)
      time_from_moment(sunset(gdate.fixed), URBANA)
    end

    # from eq 13.38 pag. 191
    # Return standard time of the winter solstice in Urbana, Illinois, USA.
    def urbana_winter(g_year)
      standard_from_universal(solar_longitude_after(WINTER, date(g_year, JANUARY, 1).fixed), URBANA)
    end
  end
end