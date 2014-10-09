require "#{File.dirname(__FILE__)}/locations.rb"
require "#{File.dirname(__FILE__)}/months.rb"
require "#{File.dirname(__FILE__)}/seasons.rb"
require "#{File.dirname(__FILE__)}/astro/constants.rb"

module Calendrical
  module Astro
    include Calendrical::Months
    include Calendrical::Locations
    include Calendrical::Seasons
    include Constants

    MORNING     = true
    EVENING     = false
    BOGUS       = nil
    
    # see lines 2997-3007 in calendrica-3.0.cl
    # Return Standard time of sunrise on fixed date 'date' at
    # location 'location'.
    def sunrise(date, location)
      alpha = refraction(date, location)
      dawn(date, location, alpha)
    end
    
    # see lines 2975-2984 in calendrica-3.0.cl
    # Return standard time in morning on fixed date date at
    # location location when depression angle of sun is alpha.
    # Returns BOGUS if there is no dawn on date date.
    def dawn(date, location, alpha)
      moment_of_depression(date + 6.hrs, location, alpha, MORNING)
      return BOGUS if result.nil?
      standard_from_local(result, location)
    end

    # see lines 3009-3019 in calendrica-3.0.cl
    # Return standard time of sunset on fixed date 'date' at
    # location 'location'.
    def sunset(date, location)
      alpha = refraction(date, location)
      # puts "Sunset: alpha: #{alpha}"
      dusk(date, location, alpha)
    end
    
    # see lines 2986-2995 in calendrica-3.0.cl
    # Return standard time in evening on fixed date 'date' at
    # location 'location' when depression angle of sun is alpha.
    # Return BOGUS if there is no dusk on date 'date'.
    def dusk(date, location, alpha)
      # puts date
      result = moment_of_depression(date + 18.hrs, location, alpha, EVENING)
      raise "Dusk:  moment of depression #{date + 18.hrs}, #{location}, #{alpha}, #{EVENING}" if result.nil?
      # puts "Dusk: Moment of Depression: #{result}"
      standard_from_local(result, location)
    end
    
    # see lines 2851-2857 in calendrica-3.0.cl
    # Return standard time on fixed date, date, of true (apparent)
    # midnight at location, location.
    def midnight(date, location)
      standard_from_local(local_from_apparent(date, location), location)
    end

    # see lines 2859-2864 in calendrica-3.0.cl
    # Return standard time on fixed date, date, of midday
    # at location, location.
    def midday(date, location)
      standard_from_local(local_from_apparent(date + mpf(12).hrs, location), location)
    end
    
    # see lines 460-467 in calendrica-3.0.errata.cl
    # Return the standard time of moonrise on fixed, date,
    # and location, location.
    def moonrise(date, location)
      t = universal_from_standard(date, location)
      waning = (lunar_phase(t) > deg(180))
      alt = observed_lunar_altitude(t, location)
      offset = alt / 360
      if (waning and (offset > 0))
        approx =  t + 1 - offset
      elsif waning
        approx = t - offset
      else
        approx = t + (1 / 2) + offset
      end
      rise = binary_search(
        approx - 3.hrs,
        approx + 3.hrs,
        lambda {|u, l| (u - l) < (1.0 / 60).hrs },
        lambda {|x| observed_lunar_altitude(x, location) > deg(0)}
      )
      (rise < (t + 1)) ? standard_from_universal(rise, location) : BOGUS
    end

    # Return an angle data structure
    # from d degrees, m arcminutes and s arcseconds.
    # This assumes that negative angles specifies negative d, m and s.
    def angle(degrees, minutes, seconds)
      degrees.to_f + ((minutes.to_f + (seconds.to_f / 60)) / 60)
    end
  
    # Return a normalized angle theta to range [0,360) degrees.
    def degrees(theta)
      theta % 360.degrees
    end

    # see lines 2799-2803 in calendrica-3.0.cl
    # Return standard time from tee_rom_u in universal time at location.
    def standard_from_universal(tee_rom_u, location)
      tee_rom_u + location.zone
    end

    # see lines 2805-2809 in calendrica-3.0.cl
    # Return universal time from tee_rom_s in standard time at location.
    def universal_from_standard(tee_rom_s, location)
      tee_rom_s - location.zone
    end

    # see lines 2811-2815 in calendrica-3.0.cl
    # Return the difference between UT and local mean time at longitude
    # 'phi' as a fraction of a day.
    def zone_from_longitude(phi)
      phi / 360.degrees
    end

    # see lines 2817-2820 in calendrica-3.0.cl
    # Return local time from universal tee_rom_u at location, location.
    def local_from_universal(tee_rom_u, location)
      tee_rom_u + zone_from_longitude(location.longitude)
    end

    # see lines 2822-2825 in calendrica-3.0.cl
    # Return universal time from local tee_ell at location, location.
    def universal_from_local(tee_ell, location)
      tee_ell - zone_from_longitude(location.longitude)
    end

    # see lines 2827-2832 in calendrica-3.0.cl
    # Return standard time from local tee_ell at locale, location.
    def standard_from_local(tee_ell, location)
      standard_from_universal(universal_from_local(tee_ell, location), location)
    end

    # see lines 2834-2839 in calendrica-3.0.cl
    # Return local time from standard tee_rom_s at location, location.
    def local_from_standard(tee_rom_s, location)
      local_from_universal(universal_from_standard(tee_rom_s, location), location)
    end

    # see lines 2841-2844 in calendrica-3.0.cl
    # Return sundial time at local time tee at location, location.
    def apparent_from_local(tee, location)
      tee + equation_of_time(universal_from_local(tee, location))
    end

    # see lines 2846-2849 in calendrica-3.0.cl
    # Return local time from sundial time tee at location, location.
    def local_from_apparent(tee, location)
      tee - equation_of_time(universal_from_local(tee, location))
    end

    # see lines 2866-2870 in calendrica-3.0.cl
    # Return Julian centuries since 2000 at moment tee.
    def julian_centuries(tee = self.fixed)
      (dynamical_from_universal(tee) - j2000) / mpf(36525.0)
    end
    
    # Return sunset time in Urbana, Ill, on Gregorian date 'gdate'."""
    def urbana_sunset(gdate = self)
      time_from_moment(sunset(gdate.fixed, URBANA))
    end

    # from eq 13.38 pag. 191
    # Return standard time of the winter solstice in Urbana, Illinois, USA.
    def urbana_winter(g_year = self.year)
      standard_from_universal(solar_longitude_after(WINTER, date(g_year, JANUARY, 1).fixed), URBANA)
    end

    # see lines 440-451 in calendrica-3.0.errata.cl
    # Return refraction angle at location 'location' and time 'tee'.
    def refraction(tee, location)
      h     = [0.meters, location.elevation].max
      cap_R = 6.372E6.meters
      dip   = arccos_degrees(cap_R / (cap_R + h))
      angle(0, 50, 0) + dip + 19.secs * Math.sqrt(h)
    end

    # see lines 453-458 in calendrica-3.0.errata.cl
    # Return the observed altitude of moon at moment, tee, and
    # at location, location,  taking refraction into account.
    def observed_lunar_altitude(tee, location)
      topocentric_lunar_altitude(tee, location) + refraction(tee, location)
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
    
    # see lines 2713-2716 in calendrica-3.0.cl
    # Return sine of theta (given in degrees).
    def sin_degrees(theta)
      # puts "Sin degrees: theta: #{theta}; radians: #{theta.to_radians}; sin: #{Math.sin(theta.to_radians)}"
      Math.sin(theta.to_radians)
    end
    
    # see lines 2718-2721 in calendrica-3.0.cl
    # Return cosine of theta (given in degrees).
    def cosine_degrees(theta)
      Math.cos(theta.to_radians)
    end
    
    # see lines 2723-2726 in calendrica-3.0.cl
    # Return tangent of theta (given in degrees).
    def tangent_degrees(theta)
      Math.tan(theta.to_radians)
    end
    
    def signum(a)
      if a > 0.0
        return 1
      elsif a == 0
        return 0
      else
        return -1
      end
    end
    
    #-----------------------------------------------------------
    # NOTE: arc[tan|sin|cos] casted with degrees given CL code
    #       returns angles [0, 360), see email from Dershowitz
    #       after my request for clarification
    #-----------------------------------------------------------
    
    # see lines 2728-2739 in calendrica-3.0.cl
    # def arctan_degrees(y, x):
    #     """ Arctangent of y/x in degrees."""
    #     from math import atan2
    #     return degrees(degrees_from_radians(atan2(x, y)))
    
    # Arctangent of y/x in degrees.
    def arctan_degrees(y, x)
      if (x == 0) && (y != 0)
        return signum(y) * (mpf(90).degrees % 360)
      else
        alpha = Math.atan(y.to_f / x.to_f).to_degrees
        return x >= 0 ? alpha : alpha + (mpf(180).degrees % 360)
      end
    end
    
    # see lines 2741-2744 in calendrica-3.0.cl
    # Return arcsine of x in degrees.
    def arcsin_degrees(x)
      degrees(Math.asin(x).to_degrees)
    end
    
    # see lines 2746-2749 in calendrica-3.0.cl
    # Return arccosine of x in degrees."""
    def arccos_degrees(x)
      degrees(Math.acos(x).to_degrees)
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
      # puts "Tee: #{tee}; Lam: #{lam}; Sigma: #{sigma([COEFFICIENTS, ADDENDS, MULTIPLIERS], lambda{|x, y, z|  x * sin_degrees(y + (z * c))})}"         
      lon = (lam + aberration(tee) + nutation(tee)) % 360
      return lon
    end
    
    # see lines 3261-3271 in calendrica-3.0.cl
    # Return the longitudinal nutation at moment, tee.
    def nutation(tee)
      c = julian_centuries(tee)
      cap_A = poly(c, [mpf(124.90), mpf(-1934.134), mpf(0.002063)])
      cap_B = poly(c, [mpf(201.11), mpf(72001.5377), mpf(0.00057)])
      nut = (mpf(-0.004778).degrees  * sin_degrees(cap_A) + 
              mpf(-0.0003667).degrees * sin_degrees(cap_B))
      # puts "Nutation: #{nut}"
      return nut
    end
    
    # see lines 3106-3109 in calendrica-3.0.cl
    # Return Dynamical time at Universal moment, tee."""
    def dynamical_from_universal(tee)
      tee + ephemeris_correction(tee)
    end
    
    # see lines 3111-3114 in calendrica-3.0.cl
    def j2000
      mpf(12).hrs + GregorianYear[2000].new_year.fixed
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
    
    # see lines 3273-3281 in calendrica-3.0.cl
    # Return the aberration at moment, tee.
    def aberration(tee)
      c = julian_centuries(tee)
      abe = (mpf(0.0000974).degrees * cosine_degrees(mpf(177.63).degrees + mpf(35999.01848).degrees * c) -
             mpf(0.005575).degrees)
      # puts "Aberration: #{abe}"
      return abe
    end
    
    # see lines 3178-3207 in calendrica-3.0.cl
    # Return the equation of time (as fraction of day) for moment, tee.
    # Adapted from "Astronomical Algorithms" by Jean Meeus,
    # Willmann_Bell, Inc., 1991.
    def equation_of_time(tee)
      c = julian_centuries(tee)
      lamb = poly(c, [mpf(280.46645), mpf(36000.76983), mpf(0.0003032)])
      anomaly = poly(c, [mpf(357.52910), mpf(35999.05030), mpf(-0.0001559), mpf(-0.00000048)])
      eccentricity = poly(c, [mpf(0.016708617), mpf(-0.000042037), mpf(-0.0000001236)])
      varepsilon = obliquity(tee)
      y = tangent_degrees(varepsilon / 2.0) ** 2
      equation =  (1.0/2 / Math::PI) * 
                  (y * sin_degrees(2.0 * lamb) + 
                  (-2.0 * eccentricity * sin_degrees(anomaly)) + 
                  (4.0 * eccentricity * y * sin_degrees(anomaly) * cosine_degrees(2.0 * lamb)) +
                  (-0.5 * y * y * sin_degrees(4.0 * lamb)) +
                  (-1.25 * eccentricity * eccentricity * sin_degrees(2.0 * anomaly)))
      # puts "Equation = #{equation}"
      eot = signum(equation) * [equation.abs, mpf(12).hrs].min
      # puts "Equation of time: #{eot}"
      return eot
    end
  end
end
