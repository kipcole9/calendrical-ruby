module Calendrical
  module Holidays
    module US
      # see lines 843-847 in calendrica-3.0.cl
      # Return the fixed date of United States Independence Day in
      # Gregorian year 'g_year'.
      def independence_day(g_year = self.year)
        date(g_year, JULY, 4)
      end

      # see lines 906-910 in calendrica-3.0.cl
      # Return the fixed date of United States Labor Day in Gregorian
      # year 'g_year' (the first Monday in September).
      def labor_day(g_year = self.year)
        first_kday(MONDAY, date(g_year, SEPTEMBER, 1))
      end

      # see lines 912-916 in calendrica-3.0.cl
      # Return the fixed date of United States' Memorial Day in Gregorian
      # year 'g_year' (the last Monday in May).
      def memorial_day(g_year = self.year)
        last_kday(MONDAY, date(g_year, MAY, 31))
      end

      # see lines 918-923 in calendrica-3.0.cl
      # Return the fixed date of United States' Election Day in Gregorian
      # year 'g_year' (the Tuesday after the first Monday in November)."""
      def election_day(g_year = self.year)
        first_kday(TUESDAY, date(g_year, NOVEMBER, 2))
      end
      
      # see lines 925-930 in calendrica-3.0.cl
      # Return the fixed date of the start of United States daylight
      # saving time in Gregorian year 'g_year' (the second Sunday in March).
      def daylight_saving_start(g_year = self.year)
        nth_kday(2, SUNDAY, date(g_year, MARCH, 1))
      end

      # see lines 932-937 in calendrica-3.0.cl
      # Return the fixed date of the end of United States daylight saving
      # time in Gregorian year 'g_year' (the first Sunday in November).
      def daylight_saving_end(g_year = self.year)
        first_kday(SUNDAY, date(g_year, NOVEMBER, 1))
      end

      # see lines 959-974 in calendrica-3.0.cl
      # Return the list of Fridays within range 'range' of fixed dates that
      # are day 13 of the relevant Gregorian months.
      def unlucky_fridays_in_range(range)
        a    = range.first
        b    = range.last
        fri  = kday_on_or_after(FRIDAY, a)
        date = to_calendar(fri)
        ell  = (date.day == 13) ? [fri] : []
        if range.include?(fri)
          ell << unlucky_fridays_in_range(interval(fri + 1, b))
          return ell
        else
          return []
        end
      end
    end
  end
end