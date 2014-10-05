module Calendrical
  module Astro
    Location = Struct.new(:latitude, :longitude, :elevation, :zone)

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
      dusk(date, location, alpha)
    end
    
    # see lines 2986-2995 in calendrica-3.0.cl
    # Return standard time in evening on fixed date 'date' at
    # location 'location' when depression angle of sun is alpha.
    # Return BOGUS if there is no dusk on date 'date'.
    def dusk(date, location, alpha)
      result = moment_of_depression(date + 18.hrs, location, alpha, EVENING)
      return BOGUS if result.nil?
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
      phi / deg(360)
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
    # Return Julian centuries since 2000 at moment tee."""
    def julian_centuries(tee)
      (dynamical_from_universal(tee) - J2000) / mpf(36525)
    end

  protected
    # Seconds in angle x
    def seconds_in_angle(x)
      x / 3600
    end

    # see lines 440-451 in calendrica-3.0.errata.cl
    # Return refraction angle at location 'location' and time 'tee'.
    def refraction(tee, location)
      h     = max(meters(0), location.elevation)
      cap_R = meters(6.372E6)
      dip   = arccos_degrees(cap_R / (cap_R + h))
      angle(0, 50, 0) + dip + secs(19) * Math.sqrt(h)
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
          poly(c, [mpf(0),
               angle(0, 0, mpf(-46.8150)),
               angle(0, 0, mpf(-0.00059)),
               angle(0, 0, mpf(0.001813))]))
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
      phi = latitude(location)
      tee_prime = universal_from_local(tee, location)
      delta = declination(tee_prime, deg(mpf(0)), solar_longitude(tee_prime))
      ((tangent_degrees(phi) * tangent_degrees(delta)) +
          (sin_degrees(alpha) / (cosine_degrees(delta) *
          cosine_degrees(phi))))
    end

    # see lines 2922-2947 in calendrica-3.0.cl
    # Return the moment in local time near tee when depression angle
    # of sun is alpha (negative if above horizon) at location;
    # early is true when MORNING event is sought and false for EVENING.
    # Returns BOGUS if depression angle is not reached.
    def approx_moment_of_depression(tee, location, alpha, early)
      ttry  = sine_offset(tee, location, alpha)
      date = fixed_from_moment(tee)

      if alpha >= 0
        alt = early ? date : date + 1
      else
        alt = date + 12.hrs
      end

      if abs(ttry) > 1
        value = sine_offset(alt, location, alpha)
      else
        value = ttry
      end

      if (abs(value) <= 1)
        temp = early ? -1 : 1
        temp *= ((12.hrs + arcsin_degrees(value)) / 360.degrees % 1) - 6.hrs
        temp += date + 12.hrs
        return local_from_apparent(temp, location)
      else
        return BOGUS
      end
    end

    # see lines 2949-2963 in calendrica-3.0.cl
    # Return the moment in local time near approx when depression
    # angle of sun is alpha (negative if above horizon) at location;
    # early is true when MORNING event is sought, and false for EVENING.
    # Returns BOGUS if depression angle is not reached.
    def moment_of_depression(approx, location, alpha, early)
      tee = approx_moment_of_depression(approx, location, alpha, early)
      return BOGUS if tee.nil?
      if (abs(approx - tee) < 30.secs)
        tee
      else
        moment_of_depression(tee, location, alpha, early)
      end
    end

    # see lines 2713-2716 in calendrica-3.0.cl
    # Return sine of theta (given in degrees).
    def sin_degrees(theta)
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
      case a
      when a > 0
        return 1
      when 0
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
        return signum(y) * (deg(mpf(90)) % 360)
      else
        alpha = Math.atan(y / x).to_degrees
        if x >= 0
          return alpha
        else
          return alpha + (deg(mpf(180)) % 360)
        end
      end
    end

    # see lines 2741-2744 in calendrica-3.0.cl
    # Return arcsine of x in degrees.
    def arcsin_degrees(x)
      #from math import asin
      degrees(asin(x).to_degrees)
    end

    # see lines 2746-2749 in calendrica-3.0.cl
    # Return arccosine of x in degrees."""
    def arccos_degrees(x)
      degrees(acos(x).to_degrees)
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
  end
end
