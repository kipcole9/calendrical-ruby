module Calendar
  module Japanese
    class Date < Chinese::Date
      using Calendrical::Numeric
  
      def inspect
        "#{cycle}-#{year}-#{month}-#{day} Japanese"
      end

      def to_s
        inspect
      end
  
      # see lines 4760-4769 in calendrica-3.0.cl
      # Return the location for Japanese calendar; varies with moment, tee.
      def location(tee)
        yyear = Gregorian::Date[tee.floor].year
        if (yyear < 1888)
          # Tokyo (139 deg 46 min east) local time
          loc = Location.new(mpf(35.7).degrees, angle(139, 46, 0), 24.meters, (9 + 143.0/450).hrs)
        else
          # Longitude 135 time zone
          loc = Location.new(35.degrees, 135.degrees, 0.meters, 9.hrs)
        end
        return loc
      end
  
    end
  end
end