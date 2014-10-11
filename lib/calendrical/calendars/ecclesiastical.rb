module Calendrical
  module Ecclesiastical
    include Calendrical::Days
    include Calendrical::Months
    
    # see lines 939-943 in calendrica-3.0.cl
    # Return the fixed date of Christmas in Gregorian year 'g_year'.
    def christmas(g_year = self.year)
      date(GregorianDate[g_year, DECEMBER, 25].fixed)
    end
    
    # see lines 1268-1272 in calendrica-3.0.cl
    # Return the list of zero or one fixed dates of Eastern Orthodox Christmas
    # in Gregorian year 'g_year'.
    def eastern_orthodox_christmas(g_year = self.year)
      JulianDate[g_year, DECEMBER, 25]
    end

    # see lines 945-951 in calendrica-3.0.cl
    # Return the fixed date of Advent in Gregorian year 'g_year'
    # (the Sunday closest to November 30).
    def advent(g_year = self.year)
      date(GregorianDate[kday_nearest(SUNDAY, date(g_year, NOVEMBER, 30).fixed)].fixed)
    end

    # see lines 953-957 in calendrica-3.0.cl
    # Return the fixed date of Epiphany in U.S. in Gregorian year 'g_year'
    # (the first Sunday after January 1).
    def epiphany(g_year = self.year)
      date(GregorianDate[first_kday(SUNDAY, date(g_year, JANUARY, 2).fixed)].fixed)
    end

    # Return fixed date of Epiphany in Italy in Gregorian year 'g_year'.
    def epiphany_it(g_year = self.year)
      date(GregorianDate[g_year, JANUARY, 6].fixed)
    end
    
    # see lines 1371-1385 in calendrica-3.0.cl
    # Return fixed date of Orthodox Easter in Gregorian year g_year.
    def eastern_orthodox_easter(g_year = self.year)
      shifted_epact = (14 + 11 * (g_year % 19)) % 30
      j_year        = g_year > 0 ? g_year : g_year - 1
      paschal_moon  = JulianDate[j_year, APRIL, 19].fixed - shifted_epact
      date(kday_after(SUNDAY, paschal_moon))
    end

    # see lines 76-91 in calendrica-3.0.errata.cl
    # Return fixed date of Orthodox Easter in Gregorian year g_year.
    # Alternative calculation.
    def alt_orthodox_easter(g_year = self.year)
      paschal_moon = (354 * g_year +
                      30 * quotient((7 * g_year) + 8, 19) +
                      quotient(g_year, 4)  -
                      quotient(g_year, 19) -
                      273 +
                      epoch)
      date(kday_after(SUNDAY, paschal_moon))
    end

    # see lines 1401-1426 in calendrica-3.0.cl
    # Return fixed date of Easter in Gregorian year g_year.
    def easter(g_year = self.year)
      century = quotient(g_year, 100) + 1
      shifted_epact = (14 + 11 * (g_year % 19) - quotient(3 * century, 4) + quotient(5 + (8 * century), 25)) % 30
      adjusted_epact = ((shifted_epact == 0) || ((shifted_epact == 1) && (10 < (g_year % 19)))) ? (shifted_epact + 1) : shifted_epact
      paschal_moon = date(g_year, APRIL, 19).fixed - adjusted_epact
      date(kday_after(SUNDAY, paschal_moon))
    end

    # see lines 1429-1431 in calendrica-3.0.cl
    # Return fixed date of Pentecost in Gregorian year g_year.
    def pentecost(g_year = self.year)
      date(easter(g_year).fixed + 49)
    end
    
    def good_friday(g_year = self.year)
      date(easter(g_year).fixed - 2)      
    end
  end
end