module Calendrical
  module Kday
    include Calendrical::Days
    include Calendrical::Months
        
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
        kday_before(k, g_date) + 7*n
      elsif n < 0
        kday_after(k, g_date) + 7*n
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
    # Return the range of fixed dates in year 'c_year'
    # of the current calendar
    def year_range(c_year = self.year)
      interval(new_year(c_year).fixed, year_end(c_year).fixed)
    end

    # see lines 729-733 in calendrica-3.0.cl
    # Return the range of fixed dates in Gregorian year 'g_year'.
    def gregorian_year_range(g_year = self.year)
      interval(GregorianDate[g_year].new_year.fixed, GregorianDate[g_year].year_end.fixed)
    end
    
    # see lines 758-763 in calendrica-3.0.cl
    # Return the number of days from Gregorian date 'g_date1'
    # till Gregorian date 'g_date2'.
    def date_difference(g_date1, g_date2 = self)
      g_date2.fixed - g_date1.fixed
    end
  end
end