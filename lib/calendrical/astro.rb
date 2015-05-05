require "#{File.dirname(__FILE__)}/astro/solar.rb"
require "#{File.dirname(__FILE__)}/astro/lunar.rb"

module Calendrical
  module Astro
    using Calendrical::Numeric
    class NoMoment < StandardError; end
    
  protected
    # see lines 3111-3114 in calendrica-3.0.cl
    def j2000
      mpf(12).hrs + Gregorian::Year[2000].new_year.fixed
    end
    
    def fixed_from_moment(tee)
      tee.floor
    end

    # see lines 407-410 in calendrica-3.0.cl
    # Return time from moment 'tee'.
    def time_from_moment(tee)
      tee % 1
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

    # see lines 3106-3109 in calendrica-3.0.cl
    # Return Dynamical time at Universal moment, tee."""
    def dynamical_from_universal(tee)
      tee + ephemeris_correction(tee)
    end
    
    # see lines 2805-2809 in calendrica-3.0.cl
    # Return universal time from tee_rom_s in standard time at location.
    def universal_from_standard(tee_rom_s, location)
      tee_rom_s - location.zone
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

    # see lines 3101-3104 in calendrica-3.0.cl
    # Return Universal moment from Dynamical time, tee.
    def universal_from_dynamical(tee)
      tee - ephemeris_correction(tee)
    end

    # see lines 3116-3126 in calendrica-3.0.cl
    # Return the mean sidereal time of day from moment tee expressed
    # as hour angle.  Adapted from "Astronomical Algorithms"
    # by Jean Meeus, Willmann_Bell, Inc., 1991.
    def sidereal_from_moment(tee)
      c = (tee - j2000) / mpf(36525)
      poly(c, [mpf(280.46061837), mpf(36525) * mpf(360.98564736629), mpf(0.000387933), mpf(-1.0) / mpf(38710000)]) % 360
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
      signum(equation) * [equation.abs, mpf(12).hrs].min
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
    
    # see lines 2866-2870 in calendrica-3.0.cl
    # Return Julian centuries since 2000 at moment tee.
    def julian_centuries(tee = self.fixed)
      (dynamical_from_universal(tee) - j2000) / mpf(36525.0)
    end
  
    # see lines 440-451 in calendrica-3.0.errata.cl
    # Return refraction angle at location 'location' and time 'tee'.
    def refraction(tee, location)
      h     = [0.meters, location.elevation].max
      cap_R = 6.372E6.meters
      dip   = arccos_degrees(cap_R / (cap_R + h))
      angle(0, 50, 0) + dip + 19.secs * Math.sqrt(h)
    end
    
    # see lines 3317-3339 in calendrica-3.0.cl
    # Return the precession at moment tee using 0,0 as J2000 coordinates.
    # Adapted from "Astronomical Algorithms" by Jean Meeus,
    # Willmann-Bell, Inc., 1991.
    def precession(tee)
      c = julian_centuries(tee)
      eta   = poly(c, [0, mpf(47.0029).secs, mpf(-0.03302).secs, mpf(0.000060).secs]) % 360
      cap_P = poly(c, [mpf(174.876384).degrees, mpf(-869.8089).secs, mpf(0.03536).secs]) % 360
      p     = poly(c, [0, secs(mpf(5029.0966)), secs(mpf(1.11113)), mpf(0.000006).secs]) % 360
      cap_A = cosine_degrees(eta) * sin_degrees(cap_P)
      cap_B = cosine_degrees(cap_P)
      arg   = arctan_degrees(cap_A, cap_B)

      return (p + cap_P - arg) % 360
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
    
    
    # see lines 3178-3207 in calendrica-3.0.cl
     # Return the equation of time (as fraction of day) for moment, tee.
     # Adapted from "Astronomical Algorithms" by Jean Meeus,
     # Willmann_Bell, Inc., 1991."""
     # def equation_of_time(tee)
     #   c = julian_centuries(tee)
     #   lamb = poly(c, deg([mpf(280.46645), mpf(36000.76983), mpf(0.0003032)]))
     #   anomaly = poly(c, deg([mpf(357.52910), mpf(35999.05030),
     #                              mpf(-0.0001559), mpf(-0.00000048)]))
     #   eccentricity = poly(c, [mpf(0.016708617),
     #                           mpf(-0.000042037),
     #                           mpf(-0.0000001236)])
     #   varepsilon = obliquity(tee)
     #   y = pow(tangent_degrees(varepsilon / 2), 2)
     #   equation = ((1/2 / pi) *
     #               (y * sin_degrees(2 * lamb) +
     #                -2 * eccentricity * sin_degrees(anomaly) +
     #                (4 * eccentricity * y * sin_degrees(anomaly) *
     #                 cosine_degrees(2 * lamb)) +
     #                -0.5 * y * y * sin_degrees(4 * lamb) +
     #                -1.25 * eccentricity * eccentricity * sin_degrees(2 * anomaly)))
     #   signum(equation) * min(abs(equation), hr(mpf(12)))
     # end
  end
end
  