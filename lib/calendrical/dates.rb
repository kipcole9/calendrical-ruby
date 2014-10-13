module Calendrical
  module Dates
    include Calendrical::Days
    include Calendrical::Months
    
    # see lines 717-721 in calendrica-3.0.cl
    # Return the fixed date of January 1 in Gregorian year 'g_year'.
    def new_year(g_year = self.year)
      date(g_year, JANUARY, 1)
    end
    alias :first_day :new_year

    # see lines 723-727 in calendrica-3.0.cl
    # Return the fixed date of December 31 in Gregorian year 'g_year'.
    def year_end(g_year = self.year)
      date(g_year, DECEMBER, 31)
    end
    alias :last_day :year_end

    # see lines 42-49 in calendrica-3.0.errata.cl
    # Return the day number in the year of Gregorian date 'g_date'.
    # TODO this is gregorian specific and shouldn't be 
    # (although most calendars are 12 months hence this will work
    def day_number(g_date = self)
      date_difference(date(g_date.year - 1, DECEMBER, 31), g_date)
    end

    # see lines 53-58 in calendrica-3.0.cl
    # Return the days remaining in the year after Gregorian date 'g_date'.
    # TODO this is gregorian specific and shouldn't be
    # (although most calendars are 12 months hence this will work
    def days_remaining(g_date = self)
      date_difference(g_date, date(g_date.year, DECEMBER, 31))
    end
  end
end