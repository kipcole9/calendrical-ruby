module Calendrical
  module LunarCalculations
    def self.mpf(x); x; end
    
    # see lines 3128-3130 in calendrica-3.0.cl
    MEAN_TROPICAL_YEAR = mpf(365.242189)

    # see lines 3132-3134 in calendrica-3.0.cl
    MEAN_SIDEREAL_YEAR = mpf(365.25636)

    # see lines 93-97 in calendrica-3.0.errata.cl
    MEAN_SYNODIC_MONTH = mpf(29.530588861)
    
    # see lines 3627-3631 in calendrica-3.0.cl
    NEW = deg(0)

    # see lines 3633-3637 in calendrica-3.0.cl
    FIRST_QUARTER = deg(90)

    # see lines 3639-3643 in calendrica-3.0.cl
    FULL = deg(180)

    # see lines 3645-3649 in calendrica-3.0.cl
    LAST_QUARTER = deg(270)

    # see lines 3021-3025 in calendrica-3.0.cl
    # Return standard time of Jewish dusk on fixed date, date,
    # at location, location, (as per Vilna Gaon).
    def jewish_dusk(date, location)
      dusk(date, location, angle(4, 40, 0))
    end

    # see lines 3027-3031 in calendrica-3.0.cl
    # Return standard time of end of Jewish sabbath on fixed date, date,
    # at location, location, (as per Berthold Cohn).
    def jewish_sabbath_ends(date, location)
      dusk(date, location, angle(7, 5, 0)) 
    end

    # see lines 3033-3042 in calendrica-3.0.cl
    # Return the length of daytime temporal hour on fixed date, date
    # at location, location.
    # Return BOGUS if there no sunrise or sunset on date, date.
    def daytime_temporal_hour(date, location)
      if (sunrise(date, location) == BOGUS) || (sunset(date, location) == BOGUS)
        BOGUS
      else
        (sunset(date, location) - sunrise(date, location)) / 12
      end
    end

    # see lines 3044-3053 in calendrica-3.0.cl
    # Return the length of nighttime temporal hour on fixed date, date,
    # at location, location.
    # Return BOGUS if there no sunrise or sunset on date, date.
    def nighttime_temporal_hour(date, location):
      if ((sunrise(date + 1, location) == BOGUS) || (sunset(date, location) == BOGUS))
        BOGUS
      else
        (sunrise(date + 1, location) - sunset(date, location)) / 12
      end
    end

    # see lines 3055-3073 in calendrica-3.0.cl
    # Return standard time of temporal moment, tee, at location, location.
    # Return BOGUS if temporal hour is undefined that day.
    def standard_from_sundial(tee, location)
      date = fixed_from_moment(tee)
      hour = 24 * mod(tee, 1)
      h = if (6..18.include?(hour))
        daytime_temporal_hour(date, location)
      elsif (hour < 6)
        nighttime_temporal_hour(date - 1, location)
      else
        nighttime_temporal_hour(date, location)
      end

      return BOGUS                                          if (h == BOGUS)
      return sunrise(date, location) + ((hour - 6) * h)     if (6 <= hour <= 18)
      return sunset(date - 1, location) + ((hour + 6) * h)  if (hour < 6)
      return sunset(date, location) + ((hour - 18) * h)
    end


    # see lines 3075-3079 in calendrica-3.0.cl
    # Return standard time on fixed date, date, at location, location,
    # of end of morning according to Jewish ritual."""
    def jewish_morning_end(date, location)
      standard_from_sundial(date + 10.hrs, location)
    end

    # see lines 3081-3099 in calendrica-3.0.cl
    # Return standard time of asr on fixed date, date,
    # at location, location.
    def asr(date, location)
      noon = universal_from_standard(midday(date, location), location)
      phi = location.latitude
      delta = declination(noon, 0.degrees, solar_longitude(noon))
      altitude = delta - phi - 90.degrees
      h = arctan_degrees(tangent_degrees(altitude),
                         2 * tangent_degrees(altitude) + 1)
      # For Shafii use instead:
      # tangent_degrees(altitude) + 1)
      dusk(date, location, -h)
    end

    ############ here start the code inspired by Meeus
    # see lines 3101-3104 in calendrica-3.0.cl
    # Return Universal moment from Dynamical time, tee."""
    def universal_from_dynamical(tee)
      tee - ephemeris_correction(tee)
    end


    # see lines 3116-3126 in calendrica-3.0.cl
    # Return the mean sidereal time of day from moment tee expressed
    # as hour angle.  Adapted from "Astronomical Algorithms"
    # by Jean Meeus, Willmann_Bell, Inc., 1991."""
    def sidereal_from_moment(tee)
      c = (tee - j2000) / mpf(36525)
      poly(c, [mpf(280.46061837), mpf(36525) * mpf(360.98564736629), mpf(0.000387933), mpf(-1) / mpf(38710000)]) % 360
    end


    # see lines 3178-3207 in calendrica-3.0.cl
    # Return the equation of time (as fraction of day) for moment, tee.
    # Adapted from "Astronomical Algorithms" by Jean Meeus,
    # Willmann_Bell, Inc., 1991."""
    def equation_of_time(tee)
      c = julian_centuries(tee)
      lamb = poly(c, deg([mpf(280.46645), mpf(36000.76983), mpf(0.0003032)]))
      anomaly = poly(c, deg([mpf(357.52910), mpf(35999.05030),
                                 mpf(-0.0001559), mpf(-0.00000048)]))
      eccentricity = poly(c, [mpf(0.016708617),
                              mpf(-0.000042037),
                              mpf(-0.0000001236)])
      varepsilon = obliquity(tee)
      y = pow(tangent_degrees(varepsilon / 2), 2)
      equation = ((1/2 / pi) *
                  (y * sin_degrees(2 * lamb) +
                   -2 * eccentricity * sin_degrees(anomaly) +
                   (4 * eccentricity * y * sin_degrees(anomaly) *
                    cosine_degrees(2 * lamb)) +
                   -0.5 * y * y * sin_degrees(4 * lamb) +
                   -1.25 * eccentricity * eccentricity * sin_degrees(2 * anomaly)))
      signum(equation) * min(abs(equation), hr(mpf(12)))
    end



    # see lines 3283-3295 in calendrica-3.0.cl
    # Return the moment UT of the first time at or after moment, tee,
    # when the solar longitude will be lam degrees."""
    def solar_longitude_after(lam, tee)
      rate = MEAN_TROPICAL_YEAR / deg(360)
      tau = tee + rate * mod(lam - solar_longitude(tee), 360)
      a = max(tee, tau - 5)
      b = tau + 5
      return invert_angular(solar_longitude, lam, a, b)
    end

    # see lines 3317-3339 in calendrica-3.0.cl
    # Return the precession at moment tee using 0,0 as J2000 coordinates.
    # Adapted from "Astronomical Algorithms" by Jean Meeus,
    # Willmann-Bell, Inc., 1991.
    def precession(tee)
      c = julian_centuries(tee)
      eta = mod(poly(c, [0,
                         secs(mpf(47.0029)),
                         secs(mpf(-0.03302)),
                         secs(mpf(0.000060))]),
                360)
      cap_P = mod(poly(c, [deg(mpf(174.876384)), 
                           secs(mpf(-869.8089)), 
                           secs(mpf(0.03536))]),
                  360)
      p = mod(poly(c, [0,
                       secs(mpf(5029.0966)),
                       secs(mpf(1.11113)),
                       secs(mpf(0.000006))]),
              360)
      cap_A = cosine_degrees(eta) * sin_degrees(cap_P)
      cap_B = cosine_degrees(cap_P)
      arg = arctan_degrees(cap_A, cap_B)

      return mod(p + cap_P - arg, 360)
    end

    # see lines 3341-3347 in calendrica-3.0.cl
    # Return sidereal solar longitude at moment, tee.
    def sidereal_solar_longitude(tee):
      mod(solar_longitude(tee) - precession(tee) + SIDEREAL_START, 360)
    end

    # see lines 3349-3365 in calendrica-3.0.cl
    # Return approximate moment at or before tee
    # when solar longitude just exceeded lam degrees.
    def estimate_prior_solar_longitude(lam, tee)
      rate = MEAN_TROPICAL_YEAR / deg(360)
      tau = tee - (rate * mod(solar_longitude(tee) - lam, 360))
      cap_Delta = mod(solar_longitude(tau) - lam + deg(180), 360) - deg(180)
      return min(tee, tau - (rate * cap_Delta))
    end

    # see lines 3367-3376 in calendrica-3.0.cl
    # Return mean longitude of moon (in degrees) at moment
    # given in Julian centuries c (including the constant term of the
    # effect of the light-time (-0".70).
    # Adapted from eq. 47.1 in "Astronomical Algorithms" by Jean Meeus,
    # Willmann_Bell, Inc., 2nd ed. with corrections, 2005.
    def mean_lunar_longitude(c)
      return degrees(poly(c,deg([mpf(218.3164477), mpf(481267.88123421),
                                 mpf(-0.0015786), mpf(1/538841),
                                 mpf(-1/65194000)])))
    end

    # see lines 3378-3387 in calendrica-3.0.cl
    # Return elongation of moon (in degrees) at moment
    # given in Julian centuries c.
    # Adapted from eq. 47.2 in "Astronomical Algorithms" by Jean Meeus,
    # Willmann_Bell, Inc., 2nd ed. with corrections, 2005.
    def lunar_elongation(c)
      return degrees(poly(c, deg([mpf(297.8501921), mpf(445267.1114034),
                                  mpf(-0.0018819), mpf(1/545868),
                                  mpf(-1/113065000)])))
    end

    # see lines 3389-3398 in calendrica-3.0.cl
    # Return mean anomaly of sun (in degrees) at moment
    # given in Julian centuries c.
    # Adapted from eq. 47.3 in "Astronomical Algorithms" by Jean Meeus,
    # Willmann_Bell, Inc., 2nd ed. with corrections, 2005.
    def solar_anomaly(c)
      return degrees(poly(c,deg([mpf(357.5291092), mpf(35999.0502909),
                                 mpf(-0.0001536), mpf(1/24490000)])))
    end

    # see lines 3400-3409 in calendrica-3.0.cl
    # Return mean anomaly of moon (in degrees) at moment
    # given in Julian centuries c.
    # Adapted from eq. 47.4 in "Astronomical Algorithms" by Jean Meeus,
    # Willmann_Bell, Inc., 2nd ed. with corrections, 2005.
    def lunar_anomaly(c)
      return degrees(poly(c, deg([mpf(134.9633964), mpf(477198.8675055),
                                  mpf(0.0087414), mpf(1/69699),
                                  mpf(-1/14712000)])))
    end


    # see lines 3411-3420 in calendrica-3.0.cl
    # Return Moon's argument of latitude (in degrees) at moment
    # given in Julian centuries 'c'.
    # Adapted from eq. 47.5 in "Astronomical Algorithms" by Jean Meeus,
    # Willmann_Bell, Inc., 2nd ed. with corrections, 2005.
    def moon_node(c)
      return degrees(poly(c, deg([mpf(93.2720950), mpf(483202.0175233),
                                  mpf(-0.0036539), mpf(-1/3526000),
                                  mpf(1/863310000)])))
    end

    # see lines 3422-3485 in calendrica-3.0.cl
    # Return longitude of moon (in degrees) at moment tee.
    # Adapted from "Astronomical Algorithms" by Jean Meeus,
    # Willmann_Bell, Inc., 2nd ed., 1998.
    def lunar_longitude(tee)
      c = julian_centuries(tee)
      cap_L_prime = mean_lunar_longitude(c)
      cap_D = lunar_elongation(c)
      cap_M = solar_anomaly(c)
      cap_M_prime = lunar_anomaly(c)
      cap_F = moon_node(c)
      # see eq. 47.6 in Meeus
      cap_E = poly(c, [1, mpf(-0.002516), mpf(-0.0000074)])
      args_lunar_elongation = \
              [0, 2, 2, 0, 0, 0, 2, 2, 2, 2, 0, 1, 0, 2, 0, 0, 4, 0, 4, 2, 2, 1,
               1, 2, 2, 4, 2, 0, 2, 2, 1, 2, 0, 0, 2, 2, 2, 4, 0, 3, 2, 4, 0, 2,
               2, 2, 4, 0, 4, 1, 2, 0, 1, 3, 4, 2, 0, 1, 2]
      args_solar_anomaly = \
              [0, 0, 0, 0, 1, 0, 0, -1, 0, -1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1,
               0, 1, -1, 0, 0, 0, 1, 0, -1, 0, -2, 1, 2, -2, 0, 0, -1, 0, 0, 1,
               -1, 2, 2, 1, -1, 0, 0, -1, 0, 1, 0, 1, 0, 0, -1, 2, 1, 0]
      args_lunar_anomaly = \
              [1, -1, 0, 2, 0, 0, -2, -1, 1, 0, -1, 0, 1, 0, 1, 1, -1, 3, -2,
               -1, 0, -1, 0, 1, 2, 0, -3, -2, -1, -2, 1, 0, 2, 0, -1, 1, 0,
               -1, 2, -1, 1, -2, -1, -1, -2, 0, 1, 4, 0, -2, 0, 2, 1, -2, -3,
               2, 1, -1, 3]
      args_moon_node = \
              [0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, -2, 2, -2, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, -2, 2, 0, 2, 0, 0, 0, 0,
               0, 0, -2, 0, 0, 0, 0, -2, -2, 0, 0, 0, 0, 0, 0, 0]
      sine_coefficients = \
              [6288774,1274027,658314,213618,-185116,-114332,
               58793,57066,53322,45758,-40923,-34720,-30383,
               15327,-12528,10980,10675,10034,8548,-7888,
               -6766,-5163,4987,4036,3994,3861,3665,-2689,
               -2602, 2390,-2348,2236,-2120,-2069,2048,-1773,
               -1595,1215,-1110,-892,-810,759,-713,-700,691,
               596,549,537,520,-487,-399,-381,351,-340,330,
               327,-323,299,294]
      correction = (deg(1/1000000) *
                    sigma([sine_coefficients, args_lunar_elongation,
                           args_solar_anomaly, args_lunar_anomaly,
                           args_moon_node],
                          lambda v, w, x, y, z:
                          v * pow(cap_E, abs(x)) *
                          sin_degrees((w * cap_D) +
                                      (x * cap_M) +
                                      (y * cap_M_prime) +
                                      (z * cap_F))))
      a1 = deg(mpf(119.75)) + (c * deg(mpf(131.849)))
      venus = (deg(3958/1000000) * sin_degrees(a1))
      a2 = deg(mpf(53.09)) + c * deg(mpf(479264.29))
      jupiter = (deg(318/1000000) * sin_degrees(a2))
      flat_earth = (deg(1962/1000000) * sin_degrees(cap_L_prime - cap_F))

      return mod(cap_L_prime + correction + venus +
                 jupiter + flat_earth + nutation(tee), 360)
    end

    # see lines 3663-3732 in calendrica-3.0.cl
    # Return the latitude of moon (in degrees) at moment, tee.
    # Adapted from "Astronomical Algorithms" by Jean Meeus,
    # Willmann_Bell, Inc., 1998.
    def lunar_latitude(tee)
      c = julian_centuries(tee)
      cap_L_prime = mean_lunar_longitude(c)
      cap_D = lunar_elongation(c)
      cap_M = solar_anomaly(c)
      cap_M_prime = lunar_anomaly(c)
      cap_F = moon_node(c)
      cap_E = poly(c, [1, mpf(-0.002516), mpf(-0.0000074)])
      args_lunar_elongation = \
              [0, 0, 0, 2, 2, 2, 2, 0, 2, 0, 2, 2, 2, 2, 2, 2, 2, 0, 4, 0, 0, 0,
               1, 0, 0, 0, 1, 0, 4, 4, 0, 4, 2, 2, 2, 2, 0, 2, 2, 2, 2, 4, 2, 2,
               0, 2, 1, 1, 0, 2, 1, 2, 0, 4, 4, 1, 4, 1, 4, 2]
      args_solar_anomaly = \
              [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 1, -1, -1, -1, 1, 0, 1,
               0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 1,
               0, -1, -2, 0, 1, 1, 1, 1, 1, 0, -1, 1, 0, -1, 0, 0, 0, -1, -2]
      args_lunar_anomaly = \
              [0, 1, 1, 0, -1, -1, 0, 2, 1, 2, 0, -2, 1, 0, -1, 0, -1, -1, -1,
               0, 0, -1, 0, 1, 1, 0, 0, 3, 0, -1, 1, -2, 0, 2, 1, -2, 3, 2, -3,
               -1, 0, 0, 1, 0, 1, 1, 0, 0, -2, -1, 1, -2, 2, -2, -1, 1, 1, -2,
               0, 0]
      args_moon_node = \
              [1, 1, -1, -1, 1, -1, 1, 1, -1, -1, -1, -1, 1, -1, 1, 1, -1, -1,
               -1, 1, 3, 1, 1, 1, -1, -1, -1, 1, -1, 1, -3, 1, -3, -1, -1, 1,
               -1, 1, -1, 1, 1, 1, 1, -1, 3, -1, -1, 1, -1, -1, 1, -1, 1, -1,
               -1, -1, -1, -1, -1, 1]
      sine_coefficients = \
              [5128122, 280602, 277693, 173237, 55413, 46271, 32573,
               17198, 9266, 8822, 8216, 4324, 4200, -3359, 2463, 2211,
               2065, -1870, 1828, -1794, -1749, -1565, -1491, -1475,
               -1410, -1344, -1335, 1107, 1021, 833, 777, 671, 607,
               596, 491, -451, 439, 422, 421, -366, -351, 331, 315,
               302, -283, -229, 223, 223, -220, -220, -185, 181,
               -177, 176, 166, -164, 132, -119, 115, 107]
      beta = (deg(1/1000000) *
              sigma([sine_coefficients, 
                     args_lunar_elongation,
                     args_solar_anomaly,
                     args_lunar_anomaly,
                     args_moon_node],
                     lambda{|v, w, x, y, z| (v *
                                           pow(cap_E, abs(x)) *
                                           sin_degrees((w * cap_D) +
                                                       (x * cap_M) +
                                                       (y * cap_M_prime) +
                                                       (z * cap_F)))}))
      venus = (deg(175/1000000) *
               (sin_degrees(deg(mpf(119.75)) + c * deg(mpf(131.849)) + cap_F) +
                sin_degrees(deg(mpf(119.75)) + c * deg(mpf(131.849)) - cap_F)))
      flat_earth = (deg(-2235/1000000) *  sin_degrees(cap_L_prime) +
                    deg(127/1000000) * sin_degrees(cap_L_prime - cap_M_prime) +
                    deg(-115/1000000) * sin_degrees(cap_L_prime + cap_M_prime))
      extra = (deg(382/1000000) *
               sin_degrees(deg(mpf(313.45)) + c * deg(mpf(481266.484))))
      return beta + venus + flat_earth + extra
    end

    # see lines 192-197 in calendrica-3.0.errata.cl
    # Return Angular distance of the node from the equinoctal point
    # at fixed moment, tee.
    # Adapted from eq. 47.7 in "Astronomical Algorithms"
    # by Jean Meeus, Willmann_Bell, Inc., 2nd ed., 1998
    # with corrections June 2005.
    def lunar_node(tee)
      return mod(moon_node(julian_centuries(tee)) + deg(90), 180) - 90
    end

    # Return Angular distance of the node from the equinoctal point
    # at fixed moment, tee.
    # Adapted from eq. 47.7 in "Astronomical Algorithms"
    # by Jean Meeus, Willmann_Bell, Inc., 2nd ed., 1998
    # with corrections June 2005.
    def alt_lunar_node(tee)
      return degrees(poly(julian_centuries(tee), deg([mpf(125.0445479),
                                                       mpf(-1934.1362891),
                                                       mpf(0.0020754),
                                                       mpf(1/467441),
                                                       mpf(-1/60616000)])))
    end

    # Return Angular distance of the true node (the node of the instantaneus
    # lunar orbit) from the equinoctal point at moment, tee.
    # Adapted from eq. 47.7 and pag. 344 in "Astronomical Algorithms"
    # by Jean Meeus, Willmann_Bell, Inc., 2nd ed., 1998
    # with corrections June 2005.
    def lunar_true_node(tee)
      c = julian_centuries(tee)
      cap_D = lunar_elongation(c)
      cap_M = solar_anomaly(c)
      cap_M_prime = lunar_anomaly(c)
      cap_F = moon_node(c)
      periodic_terms = (deg(-1.4979) * sin_degrees(2 * (cap_D - cap_F)) +
                        deg(-0.1500) * sin_degrees(cap_M) +
                        deg(-0.1226) * sin_degrees(2 * cap_D) +
                        deg(0.1176)  * sin_degrees(2 * cap_F) +
                        deg(-0.0801) * sin_degrees(2 * (cap_M_prime - cap_F)))
      return alt_lunar_node(tee) + periodic_terms
    end

    # Return Angular distance of the perigee from the equinoctal point
    # at moment, tee.
    # Adapted from eq. 47.7 in "Astronomical Algorithms"
    # by Jean Meeus, Willmann_Bell, Inc., 2nd ed., 1998
    # with corrections June 2005.
    def lunar_perigee(tee)
      return degrees(poly(julian_centuries(tee), deg([mpf(83.3532465),
                                                       mpf(4069.0137287),
                                                       mpf(-0.0103200),
                                                       mpf(-1/80053),
                                                       mpf(1/18999000)])))
    end


    # see lines 199-206 in calendrica-3.0.errata.cl
    # Return sidereal lunar longitude at moment, tee.
    def sidereal_lunar_longitude(tee)
      return (lunar_longitude(tee) - precession(tee) + SIDEREAL_START) % 360)
    end


    # see lines 99-190 in calendrica-3.0.errata.cl
    # Return the moment of n-th new moon after (or before) the new moon
    # of January 11, 1.  Adapted from "Astronomical Algorithms"
    # by Jean Meeus, Willmann_Bell, Inc., 2nd ed., 1998.
    def nth_new_moon(n)
      n0 = 24724
      k = n - n0
      c = k / mpf(1236.85)
      approx = (j2000 +
                poly(c, [mpf(5.09766),
                         MEAN_SYNODIC_MONTH * mpf(1236.85),
                         mpf(0.0001437),
                         mpf(-0.000000150),
                         mpf(0.00000000073)]))
      cap_E = poly(c, [1, mpf(-0.002516), mpf(-0.0000074)])
      solar_anomaly = poly(c, deg([mpf(2.5534),
                                   (mpf(1236.85) * mpf(29.10535669)),
                                   mpf(-0.0000014), mpf(-0.00000011)]))
      lunar_anomaly = poly(c, deg([mpf(201.5643),
                                   (mpf(385.81693528) * mpf(1236.85)),
                                   mpf(0.0107582), mpf(0.00001238),
                                   mpf(-0.000000058)]))
      moon_argument = poly(c, deg([mpf(160.7108),
                                   (mpf(390.67050284) * mpf(1236.85)),
                                   mpf(-0.0016118), mpf(-0.00000227),
                                   mpf(0.000000011)]))
      cap_omega = poly(c, [mpf(124.7746),
                           (mpf(-1.56375588) * mpf(1236.85)),
                           mpf(0.0020672), mpf(0.00000215)])
      e_factor = [0, 1, 0, 0, 1, 1, 2, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0,
                  0, 0, 0, 0, 0, 0]
      solar_coeff = [0, 1, 0, 0, -1, 1, 2, 0, 0, 1, 0, 1, 1, -1, 2,
                     0, 3, 1, 0, 1, -1, -1, 1, 0]
      lunar_coeff = [1, 0, 2, 0, 1, 1, 0, 1, 1, 2, 3, 0, 0, 2, 1, 2,
                     0, 1, 2, 1, 1, 1, 3, 4]
      moon_coeff = [0, 0, 0, 2, 0, 0, 0, -2, 2, 0, 0, 2, -2, 0, 0,
                    -2, 0, -2, 2, 2, 2, -2, 0, 0]
      sine_coeff = [mpf(-0.40720), mpf(0.17241), mpf(0.01608),
                    mpf(0.01039),  mpf(0.00739), mpf(-0.00514),
                    mpf(0.00208), mpf(-0.00111), mpf(-0.00057),
                    mpf(0.00056), mpf(-0.00042), mpf(0.00042),
                    mpf(0.00038), mpf(-0.00024), mpf(-0.00007),
                    mpf(0.00004), mpf(0.00004), mpf(0.00003),
                    mpf(0.00003), mpf(-0.00003), mpf(0.00003),
                    mpf(-0.00002), mpf(-0.00002), mpf(0.00002)]
      correction = ((deg(mpf(-0.00017)) * sin_degrees(cap_omega)) +
                    sigma([sine_coeff, e_factor, solar_coeff,
                           lunar_coeff, moon_coeff],
                          lambda{|v, w, x, y, z| (v *
                                      pow(cap_E, w) *
                                      sin_degrees((x * solar_anomaly) + 
                                                  (y * lunar_anomaly) +
                                                  (z * moon_argument)))}))
      add_const = [mpf(251.88), mpf(251.83), mpf(349.42), mpf(84.66),
                   mpf(141.74), mpf(207.14), mpf(154.84), mpf(34.52),
                   mpf(207.19), mpf(291.34), mpf(161.72), mpf(239.56),
                   mpf(331.55)]
      add_coeff = [mpf(0.016321), mpf(26.651886), mpf(36.412478),
                   mpf(18.206239), mpf(53.303771), mpf(2.453732),
                   mpf(7.306860), mpf(27.261239), mpf(0.121824),
                   mpf(1.844379), mpf(24.198154), mpf(25.513099),
                   mpf(3.592518)]
      add_factor = [mpf(0.000165), mpf(0.000164), mpf(0.000126),
                    mpf(0.000110), mpf(0.000062), mpf(0.000060),
                    mpf(0.000056), mpf(0.000047), mpf(0.000042),
                    mpf(0.000040), mpf(0.000037), mpf(0.000035),
                    mpf(0.000023)]
      extra = (deg(mpf(0.000325)) *
               sin_degrees(poly(c, deg([mpf(299.77), mpf(132.8475848),
                                        mpf(-0.009173)]))))
      additional = sigma([add_const, add_coeff, add_factor],
                         lambda{|i, j, l| l * sin_degrees(i + j * k)})

      return universal_from_dynamical(approx + correction + extra + additional)
    end

    # see lines 3578-3585 in calendrica-3.0.cl
    # Return the moment UT of last new moon before moment tee.
    def new_moon_before(tee)
      t0 = nth_new_moon(0)
      phi = lunar_phase(tee)
      n = iround(((tee - t0) / MEAN_SYNODIC_MONTH) - (phi / deg(360)))
      nth_new_moon(final(n - 1, lambda{|k| nth_new_moon(k) < tee}))
    end


    # see lines 3587-3594 in calendrica-3.0.cl
    # Return the moment UT of first new moon at or after moment, tee.
    def new_moon_at_or_after(tee)
      t0 = nth_new_moon(0)
      phi = lunar_phase(tee)
      n = iround((tee - t0) / MEAN_SYNODIC_MONTH - phi / deg(360))
      nth_new_moon(next(n, lambda{|k| nth_new_moon(k) >= tee}))
    end


    # see lines 3596-3613 in calendrica-3.0.cl
    # Return the lunar phase, as an angle in degrees, at moment tee.
    # An angle of 0 means a new moon, 90 degrees means the
    # first quarter, 180 means a full moon, and 270 degrees
    # means the last quarter.
    def lunar_phase(tee)
      phi = mod(lunar_longitude(tee) - solar_longitude(tee), 360)
      t0 = nth_new_moon(0)
      n = iround((tee - t0) / MEAN_SYNODIC_MONTH)
      phi_prime = (deg(360) *
                   mod((tee - nth_new_moon(n)) / MEAN_SYNODIC_MONTH, 1))
      if abs(phi - phi_prime) > 180.degrees
        return phi_prime
      else
        return phi
      end
    end

    # see lines 3615-3625 in calendrica-3.0.cl
    # Return the moment UT of the last time at or before moment, tee,
    # when the lunar_phase was phi degrees.
    def lunar_phase_at_or_before(phi, tee)
      tau = (tee -
             (MEAN_SYNODIC_MONTH  *
              (1/deg(360)) *
              ((lunar_phase(tee) - phi) % 360)))
      a = tau - 2
      b = min(tee, tau + 2)
      return invert_angular(lunar_phase, phi, a, b)
    end

    # see lines 3651-3661 in calendrica-3.0.cl
    # Return the moment UT of the next time at or after moment, tee,
    # when the lunar_phase is phi degrees.
    def lunar_phase_at_or_after(phi, tee)
      tau = (tee +
             (MEAN_SYNODIC_MONTH    *
              (1/deg(360)) *
              mod(phi - lunar_phase(tee), 360)))
      a = max(tee, tau - 2)
      b = tau + 2
      return invert_angular(lunar_phase, phi, a, b)
    end

    # see lines 3734-3762 in calendrica-3.0.cl
    # Return the geocentric altitude of moon at moment, tee,
    # at location, location, as a small positive/negative angle in degrees,
    # ignoring parallax and refraction.  Adapted from 'Astronomical
    # Algorithms' by Jean Meeus, Willmann_Bell, Inc., 1998.
    def lunar_altitude(tee, location)
      phi = latitude(location)
      psi = longitude(location)
      lamb = lunar_longitude(tee)
      beta = lunar_latitude(tee)
      alpha = right_ascension(tee, beta, lamb)
      delta = declination(tee, beta, lamb)
      theta0 = sidereal_from_moment(tee)
      cap_H = mod(theta0 + psi - alpha, 360)
      altitude = arcsin_degrees(
          (sin_degrees(phi) * sin_degrees(delta)) +
          (cosine_degrees(phi) * cosine_degrees(delta) * cosine_degrees(cap_H)))
      return ((altitude + 180.degrees) % 360) - 180.degrees
    end

    # see lines 3764-3813 in calendrica-3.0.cl
    # Return the distance to moon (in meters) at moment, tee.
    # Adapted from "Astronomical Algorithms" by Jean Meeus,
    # Willmann_Bell, Inc., 2nd ed.
    def lunar_distance(tee)
      c = julian_centuries(tee)
      cap_D = lunar_elongation(c)
      cap_M = solar_anomaly(c)
      cap_M_prime = lunar_anomaly(c)
      cap_F = moon_node(c)
      cap_E = poly(c, [1, mpf(-0.002516), mpf(-0.0000074)])
      args_lunar_elongation = \
          [0, 2, 2, 0, 0, 0, 2, 2, 2, 2, 0, 1, 0, 2, 0, 0, 4, 0, 4, 2, 2, 1,
           1, 2, 2, 4, 2, 0, 2, 2, 1, 2, 0, 0, 2, 2, 2, 4, 0, 3, 2, 4, 0, 2,
           2, 2, 4, 0, 4, 1, 2, 0, 1, 3, 4, 2, 0, 1, 2, 2,]
      args_solar_anomaly = \
          [0, 0, 0, 0, 1, 0, 0, -1, 0, -1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1,
           0, 1, -1, 0, 0, 0, 1, 0, -1, 0, -2, 1, 2, -2, 0, 0, -1, 0, 0, 1,
           -1, 2, 2, 1, -1, 0, 0, -1, 0, 1, 0, 1, 0, 0, -1, 2, 1, 0, 0]
      args_lunar_anomaly = \
          [1, -1, 0, 2, 0, 0, -2, -1, 1, 0, -1, 0, 1, 0, 1, 1, -1, 3, -2,
           -1, 0, -1, 0, 1, 2, 0, -3, -2, -1, -2, 1, 0, 2, 0, -1, 1, 0,
           -1, 2, -1, 1, -2, -1, -1, -2, 0, 1, 4, 0, -2, 0, 2, 1, -2, -3,
           2, 1, -1, 3, -1]
      args_moon_node = \
          [0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, -2, 2, -2, 0, 0, 0, 0, 0,
           0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, -2, 2, 0, 2, 0, 0, 0, 0,
           0, 0, -2, 0, 0, 0, 0, -2, -2, 0, 0, 0, 0, 0, 0, 0, -2]
      cosine_coefficients = \
          [-20905355, -3699111, -2955968, -569925, 48888, -3149,
           246158, -152138, -170733, -204586, -129620, 108743,
           104755, 10321, 0, 79661, -34782, -23210, -21636, 24208,
           30824, -8379, -16675, -12831, -10445, -11650, 14403,
           -7003, 0, 10056, 6322, -9884, 5751, 0, -4950, 4130, 0,
           -3958, 0, 3258, 2616, -1897, -2117, 2354, 0, 0, -1423,
           -1117, -1571, -1739, 0, -4421, 0, 0, 0, 0, 1165, 0, 0,
           8752]
      correction = sigma ([cosine_coefficients,
                           args_lunar_elongation,
                           args_solar_anomaly,
                           args_lunar_anomaly,
                           args_moon_node],
                          lambda{|v, w, x, y, z| (v *
                                      pow(cap_E, abs(x)) * 
                                      cosine_degrees((w * cap_D) +
                                                     (x * cap_M) +
                                                     (y * cap_M_prime) +
                                                     (z * cap_F)))})
      return mt(385000560) + correction
    end


    # Return the moon position (geocentric latitude and longitude [in degrees]
    # and distance [in meters]) at moment, tee.
    # Adapted from "Astronomical Algorithms" by Jean Meeus,
    # Willmann_Bell, Inc., 2nd ed.
    def lunar_position(tee)
      return [lunar_latitude(tee), lunar_longitude(tee), lunar_distance(tee)]
    end

    # see lines 3815-3824 in calendrica-3.0.cl
    # Return the parallax of moon at moment, tee, at location, location.
    # Adapted from "Astronomical Algorithms" by Jean Meeus,
    # Willmann_Bell, Inc., 1998.
    def lunar_parallax(tee, location)
      geo = lunar_altitude(tee, location)
      Delta = lunar_distance(tee)
      alt = mt(6378140) / Delta
      arg = alt * cosine_degrees(geo)
      arcsin_degrees(arg)
    end

    # see lines 3826-3832 in calendrica-3.0.cl
    # Return the topocentric altitude of moon at moment, tee,
    # at location, location, as a small positive/negative angle in degrees,
    # ignoring refraction."""    
    def topocentric_lunar_altitude(tee, location)
      lunar_altitude(tee, location) - lunar_parallax(tee, location)
    end

    # see lines 3834-3839 in calendrica-3.0.cl
    # Return the geocentric apparent lunar diameter of the moon (in
    # degrees) at moment, tee.  Adapted from 'Astronomical
    # Algorithms' by Jean Meeus, Willmann_Bell, Inc., 2nd ed."""
    def lunar_diameter(tee):
      (1792367000 / 9.0).degrees / lunar_distance(tee)
    end
  end
end