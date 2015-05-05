module Korean
  class Date < Chinese::Date
    using Calendrical::Numeric
    
    def inspect
      "#{korean_year(cycle, year)}-#{month}-#{day} Korean"
    end

    def to_s
      inspect
    end
  
    # see lines 4771-4795 in calendrica-3.0.cl
    # Return the location for Korean calendar; varies with moment, tee.
    def location(tee)
      # Seoul city hall at a varying time zone.
      if tee < Gregorian::Date[1908, APRIL, 1].fixed
         #local mean time for longitude 126 deg 58 min
         z = 3809.0/450
      elsif tee < Gregorian::Date[1912, JANUARY, 1].fixed
         z = 8.5
      elsif tee < Gregorian::Date[1954, MARCH, 21].fixed
         z = 9
      elsif tee < Gregorian::Date[1961, AUGUST, 10].fixed
         z = 8.5
      else
         z = 9
      end
      Location.new(angle(37, 34, 0), angle(126, 58, 0), 0.meters, z.hrs)
    end

  protected
  
    # see lines 4797-4800 in calendrica-3.0.cl
    # apparently not used for any date calculations
    def korean_year(cycle, yyear)
      # Return equivalent Korean year to Chinese cycle, cycle, and year, year.
      (60 * cycle) + yyear - 364
    end
  end
end