require "#{File.dirname(__FILE__)}/../locations.rb"
require "#{File.dirname(__FILE__)}/../months.rb"
require "#{File.dirname(__FILE__)}/../seasons.rb"
require "#{File.dirname(__FILE__)}/constants.rb"

module Calendrical
  module Astro
    class NoMoment < StandardError; end
    
    module Solar
      include Calendrical::Months
      include Calendrical::Locations
      include Calendrical::Seasons
      include Calendrical::Astro::Angle
      include Constants

      MORNING     = true
      EVENING     = false
      BOGUS       = nil
    
      # see lines 2997-3007 in calendrica-3.0.cl
      # Return Standard time of sunrise on fixed date 'date' at
      # location 'location'.
      def sunrise(date, location)
        alpha = refraction(date, location)
        Moment.new(dawn(date, location, alpha), location)
      end

      # see lines 3009-3019 in calendrica-3.0.cl
      # Return standard time of sunset on fixed date 'date' at
      # location 'location'.
      def sunset(date, location)
        alpha = refraction(date, location)
        Moment.new(dusk(date, location, alpha), location)
      end
    
      # see lines 2851-2857 in calendrica-3.0.cl
      # Return standard time on fixed date, date, of true (apparent)
      # midnight at location, location.
      def midnight(date, location)
        Moment.new(standard_from_local(local_from_apparent(date, location), location))
      end

      # see lines 2859-2864 in calendrica-3.0.cl
      # Return standard time on fixed date, date, of midday
      # at location, location.
      def midday(date, location)
        Moment.new(standard_from_local(local_from_apparent(date + mpf(12).hrs, location), location))
      end
    
      # see lines 460-467 in calendrica-3.0.errata.cl
      # Return the standard time of moonrise on fixed, date,
      # and location, location.
      def moonrise(date, location)
        t = universal_from_standard(date, location)
        waning = (lunar_phase(t) > 180.degrees)
        alt = observed_lunar_altitude(t, location)
        offset = alt / 360.0
        if (waning && (offset > 0))
          approx =  t + 1 - offset
        elsif waning
          approx = t - offset
        else
          approx = t + (1 / 2.0) + offset
        end
        rise = binary_search(
          approx - 3.hrs,
          approx + 3.hrs,
          lambda {|u, l| (u - l) < (1.0 / 60).hrs },
          lambda {|x| observed_lunar_altitude(x, location) > 0.degrees}
        )
        (rise < (t + 1)) ? Moment.new(standard_from_universal(rise, location)) : BOGUS
      end
      
      # Return sunset time in Urbana, Ill, on Gregorian date 'gdate'."""
      def urbana_sunset(gdate = self)
        sunset(gdate.fixed, URBANA)
      end

      # Return sunset time in Urbana, Ill, on Gregorian date 'gdate'."""
      def urbana_sunrise(gdate = self)
        sunrise(gdate.fixed, URBANA)
      end

      # from eq 13.38 pag. 191
      # Return standard time of the winter solstice in Urbana, Illinois, USA.
      def urbana_winter(g_year = self.year)
        standard_from_universal(solar_longitude_after(WINTER, date(g_year, JANUARY, 1).fixed), URBANA)
      end
      
    protected
      
      # see lines 2975-2984 in calendrica-3.0.cl
      # Return standard time in morning on fixed date date at
      # location location when depression angle of sun is alpha.
      def dawn(date, location, alpha)
        moment = moment_of_depression(date + 6.hrs, location, alpha, MORNING)
        raise(Calendrical::Astro::NoMoment, "Dawn: no moment of depression for date #{date + 6.hrs} at location #{location}") if moment.nil?
        standard_from_local(moment, location)
      end
      
      # see lines 2986-2995 in calendrica-3.0.cl
      # Return standard time in evening on fixed date 'date' at
      # location 'location' when depression angle of sun is alpha.
      def dusk(date, location, alpha)
        moment = moment_of_depression(date + 18.hrs, location, alpha, EVENING)
        raise(Calendrical::Astro::NoMoment, "Dusk: no moment of depression for date #{date + 18.hrs} at location #{location}") if moment.nil?
        standard_from_local(moment, location)
      end
      
      # see lines 2811-2815 in calendrica-3.0.cl
      # Return the difference between UT and local mean time at longitude
      # 'phi' as a fraction of a day.
      def zone_from_longitude(phi)
        phi / 360.degrees
      end

      # see lines 2872-2880 in calendrica-3.0.cl
      # Return obliquity of ecliptic at moment tee.
      def obliquity(tee)
        c = julian_centuries(tee)
        (angle(23, 26, mpf(21.448)) +
          poly(c, [mpf(0), angle(0, 0, mpf(-46.8150)), angle(0, 0, mpf(-0.00059)), angle(0, 0, mpf(0.001813))]))
      end

      # see lines 2882-2891 in calendrica-3.0.cl
      # Return declination at moment UT tee of object at
      # longitude 'lam' and latitude 'beta'.
      def declination(tee, beta, lam)
        varepsilon = obliquity(tee)
        arcsin_degrees(
            (sin_degrees(beta) * cosine_degrees(varepsilon)) +
            (cosine_degrees(beta) * sin_degrees(varepsilon) * sin_degrees(lam)))
      end

      # see lines 2893-2903 in calendrica-3.0.cl
      # Return right ascension at moment UT 'tee' of object at
      # latitude 'lam' and longitude 'beta'."""
      def right_ascension(tee, beta, lam)
        varepsilon = obliquity(tee)
        arctan_degrees(
            (sin_degrees(lam) * cosine_degrees(varepsilon)) -
            (tangent_degrees(beta) * sin_degrees(varepsilon)),
            cosine_degrees(lam))
      end

      # see lines 2905-2920 in calendrica-3.0.cl
      # Return sine of angle between position of sun at 
      # local time tee and when its depression is alpha at location, location.
      # Out of range when it does not occur.
      def sine_offset(tee, location, alpha)
        phi = location.latitude
        tee_prime = universal_from_local(tee, location)
        delta = declination(tee_prime, mpf(0).degrees, solar_longitude(tee_prime))
        # puts "Sine_offset: tee_prime: #{tee_prime}, delta: #{delta}, solar_longitude: #{solar_longitude(tee_prime)}"
        result = (tangent_degrees(phi) * tangent_degrees(delta)) +
          (sin_degrees(alpha) / (cosine_degrees(delta) * cosine_degrees(phi)))
        result
      end                                

      # see lines 2922-2947 in calendrica-3.0.cl
      # Return the moment in local time near tee when depression angle
      # of sun is alpha (negative if above horizon) at location;
      # early is true when MORNING event is sought and false for EVENING.
      # Returns BOGUS if depression angle is not reached.
      def approx_moment_of_depression(tee, location, alpha, early)
        ttry  = sine_offset(tee, location, alpha)
        # puts "Approx Moment: Sine_offset: tee: #{tee} => #{ttry}"
        date = fixed_from_moment(tee)
        # puts "Approx moment:  date: #{date}"
      
        alt = if alpha >= 0
          early ? date : date + 1
        else
          date + 12.hrs
        end
        value = ttry.abs > 1 ? sine_offset(alt, location, alpha) : ttry
        # puts "Approx moment:  value: #{value}"
            
        if value.abs <= 1
          temp = (early ? -1 : 1) 
          temp *= ((12.hrs + arcsin_degrees(value) / 360.degrees) % 1) - 6.hrs
          temp += date + 12.hrs
          return local_from_apparent(temp, location)
        else
          raise "[Approx Moment of Depression] No value available (value is #{value.abs})"
        end
      end

      # see lines 2949-2963 in calendrica-3.0.cl
      # Return the moment in local time near approx when depression
      # angle of sun is alpha (negative if above horizon) at location;
      # early is true when MORNING event is sought, and false for EVENING.
      # Returns BOGUS if depression angle is not reached.
      def moment_of_depression(approx, location, alpha, early)
        tee = approx_moment_of_depression(approx, location, alpha, early)
        raise "Moment of Depression: Cannot be reached (Tee: #{tee}, Approx: #{approx}, Location: #{location}, Alpha: #{alpha}, Early: #{early})" if tee.nil?
        mod = (approx - tee).abs < 30.secs ? tee : moment_of_depression(tee, location, alpha, early)
        # puts "Moment of depression: #{mod}"
        mod
      end
    
      # see lines 2777-2797 in calendrica-3.0.cl
      # Return the angle (clockwise from North) to face focus when
      # standing in location, location.  Subject to errors near focus and
      # its antipode.
      def direction(location, focus)
        phi = location.latitude
        phi_prime = focus.latitude
        psi = location.longitude
        psi_prime = focus.longitude
        y = sin_degrees(psi_prime - psi)
        x = ((cosine_degrees(phi) * tangent_degrees(phi_prime)) -
             (sin_degrees(phi)    * cosine_degrees(psi - psi_prime)))
        if ((x == 0 && y == 0) || (phi_prime == 90.degrees))
          return deg(0)
        elsif (phi_prime == -90.degrees)
          return 180.degrees
        else
          return arctan_degrees(y, x)
        end
      end
    
      # see lines 3209-3259 in calendrica-3.0.cl
      # Return the longitude of sun at moment 'tee'.
      # Adapted from 'Planetary Programs and Tables from -4000 to +2800'
      # by Pierre Bretagnon and Jean_Louis Simon, Willmann_Bell, Inc., 1986.
      # See also pag 166 of 'Astronomical Algorithms' by Jean Meeus, 2nd Ed 1998,
      # with corrections Jun 2005.
      def solar_longitude(tee)
        c = julian_centuries(tee)
        lam = (mpf(282.7771834).degrees +
               mpf(36000.76953744).degrees * c +
               mpf(0.000005729577951308232).degrees *
               sigma([COEFFICIENTS, ADDENDS, MULTIPLIERS], lambda{|x, y, z|  mpf(x) * sin_degrees(mpf(y) + (mpf(z) * c))})
              )
        lon = (lam + aberration(tee) + nutation(tee)) % 360
        return lon
      end
      
      # see lines 3283-3295 in calendrica-3.0.cl
      # Return the moment UT of the first time at or after moment, tee,
      # when the solar longitude will be lam degrees."""
      def solar_longitude_after(lam, tee)
        rate = MEAN_TROPICAL_YEAR / deg(360)
        tau = tee + rate * ((lam - solar_longitude(tee)) % 360)
        a = max(tee, tau - 5)
        b = tau + 5
        invert_angular(solar_longitude, lam, a, b)
      end
    
      # see lines 3261-3271 in calendrica-3.0.cl
      # Return the longitudinal nutation at moment, tee.
      def nutation(tee)
        c = julian_centuries(tee)
        cap_A = poly(c, [mpf(124.90), mpf(-1934.134), mpf(0.002063)])
        cap_B = poly(c, [mpf(201.11), mpf(72001.5377), mpf(0.00057)])
        nut = (mpf(-0.004778).degrees  * sin_degrees(cap_A) + 
                mpf(-0.0003667).degrees * sin_degrees(cap_B))
        return nut
      end
    
      # see lines 3140-3176 in calendrica-3.0.cl
      # Return Dynamical Time minus Universal Time (in days) for
      # moment, tee.  Adapted from "Astronomical Algorithms"
      # by Jean Meeus, Willmann_Bell, Inc., 1991.
      def ephemeris_correction(tee)
        yyear = GregorianDate[tee.floor].year
        c = (GregorianDate[yyear, JULY, 1] - GregorianDate[1900, JANUARY, 1]) / mpf(36525)
        if (1988..2019).include?(yyear)
          corr = 1.0/86400.0 * (yyear - 1933)
        elsif (1900..1987).include?(yyear)
          corr = poly(c, [mpf(-0.00002), mpf(0.000297), mpf(0.025184),
                          mpf(-0.181133), mpf(0.553040), mpf(-0.861938),
                          mpf(0.677066), mpf(-0.212591)])
        elsif (1800..1899).include?(yyear)
          corr = poly(c, [mpf(-0.000009), mpf(0.003844), mpf(0.083563),
                          mpf(0.865736), mpf(4.867575), mpf(15.845535),
                          mpf(31.332267), mpf(38.291999), mpf(28.316289),
                          mpf(11.636204), mpf(2.043794)])
        elsif (1700..1799).include?(yyear)
          corr = (1.0/86400 * poly(yyear - 1700, [8.118780842, -0.005092142, 0.003336121, -0.0000266484]))
        elsif (1620..1699).include?(yyear)
          corr = (1.0/86400 * poly(yyear - 1600, [mpf(196.58333), mpf(-4.0675), mpf(0.0219167)]))
        else
          x = mpf(12).hrs + (GregorianDate[yyear, JANUARY, 1] - GregorianDate[1810, JANUARY, 1])
          corr = 1.0/86400.0 * (((x * x) / mpf(41048480.0)) - 15)
        end
        # puts "Ephemeris correction: #{corr}"
        return corr
      end
    end
  end
end