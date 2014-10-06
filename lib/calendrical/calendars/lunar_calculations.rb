module Calendrical
  module LunarCalculations

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
    def jewish_morning_end(date, location):
        """Return standard time on fixed date, date, at location, location,
        of end of morning according to Jewish ritual."""
        return standard_from_sundial(date + hr(10), location)

    # see lines 3081-3099 in calendrica-3.0.cl
    def asr(date, location):
        """Return standard time of asr on fixed date, date,
        at location, location."""
        noon = universal_from_standard(midday(date, location), location)
        phi = latitude(location)
        delta = declination(noon, deg(0), solar_longitude(noon))
        altitude = delta - phi - deg(90)
        h = arctan_degrees(tangent_degrees(altitude),
                           2 * tangent_degrees(altitude) + 1)
        # For Shafii use instead:
        # tangent_degrees(altitude) + 1)

        return dusk(date, location, -h)

    ############ here start the code inspired by Meeus
    # see lines 3101-3104 in calendrica-3.0.cl
    def universal_from_dynamical(tee):
        """Return Universal moment from Dynamical time, tee."""
        return tee - ephemeris_correction(tee)

    # see lines 3106-3109 in calendrica-3.0.cl
    def dynamical_from_universal(tee):
        """Return Dynamical time at Universal moment, tee."""
        return tee + ephemeris_correction(tee)


    # see lines 3111-3114 in calendrica-3.0.cl
    J2000 = hr(mpf(12)) + gregorian_new_year(2000)

    # see lines 3116-3126 in calendrica-3.0.cl
    def sidereal_from_moment(tee):
        """Return the mean sidereal time of day from moment tee expressed
        as hour angle.  Adapted from "Astronomical Algorithms"
        by Jean Meeus, Willmann_Bell, Inc., 1991."""
        c = (tee - J2000) / mpf(36525)
        return mod(poly(c, deg([mpf(280.46061837),
                                mpf(36525) * mpf(360.98564736629),
                                mpf(0.000387933),
                                mpf(-1)/mpf(38710000)])),
                   360)

    # see lines 3128-3130 in calendrica-3.0.cl
    MEAN_TROPICAL_YEAR = mpf(365.242189)

    # see lines 3132-3134 in calendrica-3.0.cl
    MEAN_SIDEREAL_YEAR = mpf(365.25636)

    # see lines 93-97 in calendrica-3.0.errata.cl
    MEAN_SYNODIC_MONTH = mpf(29.530588861)

    # see lines 3140-3176 in calendrica-3.0.cl
    def ephemeris_correction(tee):
        """Return Dynamical Time minus Universal Time (in days) for
        moment, tee.  Adapted from "Astronomical Algorithms"
        by Jean Meeus, Willmann_Bell, Inc., 1991."""
        year = gregorian_year_from_fixed(ifloor(tee))
        c = gregorian_date_difference(gregorian_date(1900, JANUARY, 1),
                                      gregorian_date(year, JULY, 1)) / mpf(36525)
        if (1988 <= year <= 2019):
            return 1/86400 * (year - 1933)
        elif (1900 <= year <= 1987):
            return poly(c, [mpf(-0.00002), mpf(0.000297), mpf(0.025184),
                            mpf(-0.181133), mpf(0.553040), mpf(-0.861938),
                            mpf(0.677066), mpf(-0.212591)])
        elif (1800 <= year <= 1899):
            return poly(c, [mpf(-0.000009), mpf(0.003844), mpf(0.083563),
                            mpf(0.865736), mpf(4.867575), mpf(15.845535),
                            mpf(31.332267), mpf(38.291999), mpf(28.316289),
                            mpf(11.636204), mpf(2.043794)])
        elif (1700 <= year <= 1799):
            return (1/86400 *
                    poly(year - 1700, [8.118780842, -0.005092142,
                                       0.003336121, -0.0000266484]))
        elif (1620 <= year <= 1699):
            return (1/86400 *
                    poly(year - 1600,
                         [mpf(196.58333), mpf(-4.0675), mpf(0.0219167)]))
        else:
            x = (hr(mpf(12)) +
                 gregorian_date_difference(gregorian_date(1810, JANUARY, 1),
                                           gregorian_date(year, JANUARY, 1)))
            return 1/86400 * (((x * x) / mpf(41048480)) - 15)

    # see lines 3178-3207 in calendrica-3.0.cl
    def equation_of_time(tee):
        """Return the equation of time (as fraction of day) for moment, tee.
        Adapted from "Astronomical Algorithms" by Jean Meeus,
        Willmann_Bell, Inc., 1991."""
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
        return signum(equation) * min(abs(equation), hr(mpf(12)))

    # see lines 3209-3259 in calendrica-3.0.cl
    def solar_longitude(tee):
        """Return the longitude of sun at moment 'tee'.
        Adapted from 'Planetary Programs and Tables from -4000 to +2800'
        by Pierre Bretagnon and Jean_Louis Simon, Willmann_Bell, Inc., 1986.
        See also pag 166 of 'Astronomical Algorithms' by Jean Meeus, 2nd Ed 1998,
        with corrections Jun 2005."""
        c = julian_centuries(tee)
        coefficients = [403406, 195207, 119433, 112392, 3891, 2819, 1721,
                        660, 350, 334, 314, 268, 242, 234, 158, 132, 129, 114,
                        99, 93, 86, 78,72, 68, 64, 46, 38, 37, 32, 29, 28, 27, 27,
                        25, 24, 21, 21, 20, 18, 17, 14, 13, 13, 13, 12, 10, 10, 10,
                        10]
        multipliers = [mpf(0.9287892), mpf(35999.1376958), mpf(35999.4089666),
                       mpf(35998.7287385), mpf(71998.20261), mpf(71998.4403),
                       mpf(36000.35726), mpf(71997.4812), mpf(32964.4678),
                       mpf(-19.4410), mpf(445267.1117), mpf(45036.8840), mpf(3.1008),
                       mpf(22518.4434), mpf(-19.9739), mpf(65928.9345),
                       mpf(9038.0293), mpf(3034.7684), mpf(33718.148), mpf(3034.448),
                       mpf(-2280.773), mpf(29929.992), mpf(31556.493), mpf(149.588),
                       mpf(9037.750), mpf(107997.405), mpf(-4444.176), mpf(151.771),
                       mpf(67555.316), mpf(31556.080), mpf(-4561.540),
                       mpf(107996.706), mpf(1221.655), mpf(62894.167),
                       mpf(31437.369), mpf(14578.298), mpf(-31931.757),
                       mpf(34777.243), mpf(1221.999), mpf(62894.511),
                       mpf(-4442.039), mpf(107997.909), mpf(119.066), mpf(16859.071),
                       mpf(-4.578), mpf(26895.292), mpf(-39.127), mpf(12297.536),
                       mpf(90073.778)]
        addends = [mpf(270.54861), mpf(340.19128), mpf(63.91854), mpf(331.26220),
                   mpf(317.843), mpf(86.631), mpf(240.052), mpf(310.26), mpf(247.23),
                   mpf(260.87), mpf(297.82), mpf(343.14), mpf(166.79), mpf(81.53),
                   mpf(3.50), mpf(132.75), mpf(182.95), mpf(162.03), mpf(29.8),
                   mpf(266.4), mpf(249.2), mpf(157.6), mpf(257.8),mpf(185.1),
                   mpf(69.9),  mpf(8.0), mpf(197.1), mpf(250.4), mpf(65.3),
                   mpf(162.7), mpf(341.5), mpf(291.6), mpf(98.5), mpf(146.7),
                   mpf(110.0), mpf(5.2), mpf(342.6), mpf(230.9), mpf(256.1),
                   mpf(45.3), mpf(242.9), mpf(115.2), mpf(151.8), mpf(285.3),
                   mpf(53.3), mpf(126.6), mpf(205.7), mpf(85.9), mpf(146.1)]
        lam = (deg(mpf(282.7771834)) +
               deg(mpf(36000.76953744)) * c +
               deg(mpf(0.000005729577951308232)) *
               sigma([coefficients, addends, multipliers],
                     lambda x, y, z:  x * sin_degrees(y + (z * c))))
        return mod(lam + aberration(tee) + nutation(tee), 360)

    # see lines 3261-3271 in calendrica-3.0.cl
    def nutation(tee):
        """Return the longitudinal nutation at moment, tee."""
        c = julian_centuries(tee)
        cap_A = poly(c, deg([mpf(124.90), mpf(-1934.134), mpf(0.002063)]))
        cap_B = poly(c, deg([mpf(201.11), mpf(72001.5377), mpf(0.00057)]))
        return (deg(mpf(-0.004778))  * sin_degrees(cap_A) + 
                deg(mpf(-0.0003667)) * sin_degrees(cap_B))

    # see lines 3273-3281 in calendrica-3.0.cl
    def aberration(tee):
        """Return the aberration at moment, tee."""
        c = julian_centuries(tee)
        return ((deg(mpf(0.0000974)) *
                 cosine_degrees(deg(mpf(177.63)) + deg(mpf(35999.01848)) * c)) -
                deg(mpf(0.005575)))

    # see lines 3283-3295 in calendrica-3.0.cl
    def solar_longitude_after(lam, tee):
        """Return the moment UT of the first time at or after moment, tee,
        when the solar longitude will be lam degrees."""
        rate = MEAN_TROPICAL_YEAR / deg(360)
        tau = tee + rate * mod(lam - solar_longitude(tee), 360)
        a = max(tee, tau - 5)
        b = tau + 5
        return invert_angular(solar_longitude, lam, a, b)

    # see lines 3297-3300 in calendrica-3.0.cl
    SPRING = deg(0)

    # see lines 3302-3305 in calendrica-3.0.cl
    SUMMER = deg(90)

    # see lines 3307-3310 in calendrica-3.0.cl
    AUTUMN = deg(180)

    # see lines 3312-3315 in calendrica-3.0.cl
    WINTER = deg(270)

    # see lines 3317-3339 in calendrica-3.0.cl
    def precession(tee):
        """Return the precession at moment tee using 0,0 as J2000 coordinates.
        Adapted from "Astronomical Algorithms" by Jean Meeus,
        Willmann-Bell, Inc., 1991."""
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

    # see lines 3341-3347 in calendrica-3.0.cl
    def sidereal_solar_longitude(tee):
        """Return sidereal solar longitude at moment, tee."""
        return mod(solar_longitude(tee) - precession(tee) + SIDEREAL_START, 360)

    # see lines 3349-3365 in calendrica-3.0.cl
    def estimate_prior_solar_longitude(lam, tee):
        """Return approximate moment at or before tee
        when solar longitude just exceeded lam degrees."""
        rate = MEAN_TROPICAL_YEAR / deg(360)
        tau = tee - (rate * mod(solar_longitude(tee) - lam, 360))
        cap_Delta = mod(solar_longitude(tau) - lam + deg(180), 360) - deg(180)
        return min(tee, tau - (rate * cap_Delta))

    # see lines 3367-3376 in calendrica-3.0.cl
    def mean_lunar_longitude(c):
        """Return mean longitude of moon (in degrees) at moment
        given in Julian centuries c (including the constant term of the
        effect of the light-time (-0".70).
        Adapted from eq. 47.1 in "Astronomical Algorithms" by Jean Meeus,
        Willmann_Bell, Inc., 2nd ed. with corrections, 2005."""
        return degrees(poly(c,deg([mpf(218.3164477), mpf(481267.88123421),
                                   mpf(-0.0015786), mpf(1/538841),
                                   mpf(-1/65194000)])))

    # see lines 3378-3387 in calendrica-3.0.cl
    def lunar_elongation(c):
        """Return elongation of moon (in degrees) at moment
        given in Julian centuries c.
        Adapted from eq. 47.2 in "Astronomical Algorithms" by Jean Meeus,
        Willmann_Bell, Inc., 2nd ed. with corrections, 2005."""
        return degrees(poly(c, deg([mpf(297.8501921), mpf(445267.1114034),
                                    mpf(-0.0018819), mpf(1/545868),
                                    mpf(-1/113065000)])))

    # see lines 3389-3398 in calendrica-3.0.cl
    def solar_anomaly(c):
        """Return mean anomaly of sun (in degrees) at moment
        given in Julian centuries c.
        Adapted from eq. 47.3 in "Astronomical Algorithms" by Jean Meeus,
        Willmann_Bell, Inc., 2nd ed. with corrections, 2005."""
        return degrees(poly(c,deg([mpf(357.5291092), mpf(35999.0502909),
                                   mpf(-0.0001536), mpf(1/24490000)])))

    # see lines 3400-3409 in calendrica-3.0.cl
    def lunar_anomaly(c):
        """Return mean anomaly of moon (in degrees) at moment
        given in Julian centuries c.
        Adapted from eq. 47.4 in "Astronomical Algorithms" by Jean Meeus,
        Willmann_Bell, Inc., 2nd ed. with corrections, 2005."""
        return degrees(poly(c, deg([mpf(134.9633964), mpf(477198.8675055),
                                    mpf(0.0087414), mpf(1/69699),
                                    mpf(-1/14712000)])))


    # see lines 3411-3420 in calendrica-3.0.cl
    def moon_node(c):
        """Return Moon's argument of latitude (in degrees) at moment
        given in Julian centuries 'c'.
        Adapted from eq. 47.5 in "Astronomical Algorithms" by Jean Meeus,
        Willmann_Bell, Inc., 2nd ed. with corrections, 2005."""
        return degrees(poly(c, deg([mpf(93.2720950), mpf(483202.0175233),
                                    mpf(-0.0036539), mpf(-1/3526000),
                                    mpf(1/863310000)])))

    # see lines 3422-3485 in calendrica-3.0.cl
    def lunar_longitude(tee):
        """Return longitude of moon (in degrees) at moment tee.
        Adapted from "Astronomical Algorithms" by Jean Meeus,
        Willmann_Bell, Inc., 2nd ed., 1998."""
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
        A1 = deg(mpf(119.75)) + (c * deg(mpf(131.849)))
        venus = (deg(3958/1000000) * sin_degrees(A1))
        A2 = deg(mpf(53.09)) + c * deg(mpf(479264.29))
        jupiter = (deg(318/1000000) * sin_degrees(A2))
        flat_earth = (deg(1962/1000000) * sin_degrees(cap_L_prime - cap_F))

        return mod(cap_L_prime + correction + venus +
                   jupiter + flat_earth + nutation(tee), 360)

    # see lines 3663-3732 in calendrica-3.0.cl
    def lunar_latitude(tee):
        """Return the latitude of moon (in degrees) at moment, tee.
        Adapted from "Astronomical Algorithms" by Jean Meeus,
        Willmann_Bell, Inc., 1998."""
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
                      lambda v, w, x, y, z: (v *
                                             pow(cap_E, abs(x)) *
                                             sin_degrees((w * cap_D) +
                                                         (x * cap_M) +
                                                         (y * cap_M_prime) +
                                                         (z * cap_F)))))
        venus = (deg(175/1000000) *
                 (sin_degrees(deg(mpf(119.75)) + c * deg(mpf(131.849)) + cap_F) +
                  sin_degrees(deg(mpf(119.75)) + c * deg(mpf(131.849)) - cap_F)))
        flat_earth = (deg(-2235/1000000) *  sin_degrees(cap_L_prime) +
                      deg(127/1000000) * sin_degrees(cap_L_prime - cap_M_prime) +
                      deg(-115/1000000) * sin_degrees(cap_L_prime + cap_M_prime))
        extra = (deg(382/1000000) *
                 sin_degrees(deg(mpf(313.45)) + c * deg(mpf(481266.484))))
        return beta + venus + flat_earth + extra


    # see lines 192-197 in calendrica-3.0.errata.cl
    def lunar_node(tee):
        """Return Angular distance of the node from the equinoctal point
        at fixed moment, tee.
        Adapted from eq. 47.7 in "Astronomical Algorithms"
        by Jean Meeus, Willmann_Bell, Inc., 2nd ed., 1998
        with corrections June 2005."""
        return mod(moon_node(julian_centuries(tee)) + deg(90), 180) - 90

    def alt_lunar_node(tee):
        """Return Angular distance of the node from the equinoctal point
        at fixed moment, tee.
        Adapted from eq. 47.7 in "Astronomical Algorithms"
        by Jean Meeus, Willmann_Bell, Inc., 2nd ed., 1998
        with corrections June 2005."""
        return degrees(poly(julian_centuries(tee), deg([mpf(125.0445479),
                                                         mpf(-1934.1362891),
                                                         mpf(0.0020754),
                                                         mpf(1/467441),
                                                         mpf(-1/60616000)])))

    def lunar_true_node(tee):
        """Return Angular distance of the true node (the node of the instantaneus
        lunar orbit) from the equinoctal point at moment, tee.
        Adapted from eq. 47.7 and pag. 344 in "Astronomical Algorithms"
        by Jean Meeus, Willmann_Bell, Inc., 2nd ed., 1998
        with corrections June 2005."""
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

    def lunar_perigee(tee):
        """Return Angular distance of the perigee from the equinoctal point
        at moment, tee.
        Adapted from eq. 47.7 in "Astronomical Algorithms"
        by Jean Meeus, Willmann_Bell, Inc., 2nd ed., 1998
        with corrections June 2005."""
        return degrees(poly(julian_centuries(tee), deg([mpf(83.3532465),
                                                         mpf(4069.0137287),
                                                         mpf(-0.0103200),
                                                         mpf(-1/80053),
                                                         mpf(1/18999000)])))


    # see lines 199-206 in calendrica-3.0.errata.cl
    def sidereal_lunar_longitude(tee):
        """Return sidereal lunar longitude at moment, tee."""
        return mod(lunar_longitude(tee) - precession(tee) + SIDEREAL_START, 360)


    # see lines 99-190 in calendrica-3.0.errata.cl
    def nth_new_moon(n):
        """Return the moment of n-th new moon after (or before) the new moon
        of January 11, 1.  Adapted from "Astronomical Algorithms"
        by Jean Meeus, Willmann_Bell, Inc., 2nd ed., 1998."""
        n0 = 24724
        k = n - n0
        c = k / mpf(1236.85)
        approx = (J2000 +
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
        E_factor = [0, 1, 0, 0, 1, 1, 2, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0,
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
                      sigma([sine_coeff, E_factor, solar_coeff,
                             lunar_coeff, moon_coeff],
                            lambda v, w, x, y, z: (v *
                                        pow(cap_E, w) *
                                        sin_degrees((x * solar_anomaly) + 
                                                    (y * lunar_anomaly) +
                                                    (z * moon_argument)))))
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
                           lambda i, j, l: l * sin_degrees(i + j * k))

        return universal_from_dynamical(approx + correction + extra + additional)


    # see lines 3578-3585 in calendrica-3.0.cl
    def new_moon_before(tee):
        """Return the moment UT of last new moon before moment tee."""
        t0 = nth_new_moon(0)
        phi = lunar_phase(tee)
        n = iround(((tee - t0) / MEAN_SYNODIC_MONTH) - (phi / deg(360)))
        return nth_new_moon(final(n - 1, lambda k: nth_new_moon(k) < tee))


    # see lines 3587-3594 in calendrica-3.0.cl
    def new_moon_at_or_after(tee):
        """Return the moment UT of first new moon at or after moment, tee."""
        t0 = nth_new_moon(0)
        phi = lunar_phase(tee)
        n = iround((tee - t0) / MEAN_SYNODIC_MONTH - phi / deg(360))
        return nth_new_moon(next(n, lambda k: nth_new_moon(k) >= tee))


    # see lines 3596-3613 in calendrica-3.0.cl
    def lunar_phase(tee):
        """Return the lunar phase, as an angle in degrees, at moment tee.
        An angle of 0 means a new moon, 90 degrees means the
        first quarter, 180 means a full moon, and 270 degrees
        means the last quarter."""
        phi = mod(lunar_longitude(tee) - solar_longitude(tee), 360)
        t0 = nth_new_moon(0)
        n = iround((tee - t0) / MEAN_SYNODIC_MONTH)
        phi_prime = (deg(360) *
                     mod((tee - nth_new_moon(n)) / MEAN_SYNODIC_MONTH, 1))
        if abs(phi - phi_prime) > deg(180):
            return phi_prime
        else:
            return phi


    # see lines 3615-3625 in calendrica-3.0.cl
    def lunar_phase_at_or_before(phi, tee):
        """Return the moment UT of the last time at or before moment, tee,
        when the lunar_phase was phi degrees."""
        tau = (tee -
               (MEAN_SYNODIC_MONTH  *
                (1/deg(360)) *
                mod(lunar_phase(tee) - phi, 360)))
        a = tau - 2
        b = min(tee, tau +2)
        return invert_angular(lunar_phase, phi, a, b)


    # see lines 3627-3631 in calendrica-3.0.cl
    NEW = deg(0)

    # see lines 3633-3637 in calendrica-3.0.cl
    FIRST_QUARTER = deg(90)

    # see lines 3639-3643 in calendrica-3.0.cl
    FULL = deg(180)

    # see lines 3645-3649 in calendrica-3.0.cl
    LAST_QUARTER = deg(270)

    # see lines 3651-3661 in calendrica-3.0.cl
    def lunar_phase_at_or_after(phi, tee):
        """Return the moment UT of the next time at or after moment, tee,
        when the lunar_phase is phi degrees."""
        tau = (tee +
               (MEAN_SYNODIC_MONTH    *
                (1/deg(360)) *
                mod(phi - lunar_phase(tee), 360)))
        a = max(tee, tau - 2)
        b = tau + 2
        return invert_angular(lunar_phase, phi, a, b)




    # see lines 3734-3762 in calendrica-3.0.cl
    def lunar_altitude(tee, location):
        """Return the geocentric altitude of moon at moment, tee,
        at location, location, as a small positive/negative angle in degrees,
        ignoring parallax and refraction.  Adapted from 'Astronomical
        Algorithms' by Jean Meeus, Willmann_Bell, Inc., 1998."""
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
        return mod(altitude + deg(180), 360) - deg(180)
 

    # see lines 3764-3813 in calendrica-3.0.cl
    def lunar_distance(tee):
        """Return the distance to moon (in meters) at moment, tee.
        Adapted from "Astronomical Algorithms" by Jean Meeus,
        Willmann_Bell, Inc., 2nd ed."""
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
                            lambda v, w, x, y, z: (v *
                                        pow(cap_E, abs(x)) * 
                                        cosine_degrees((w * cap_D) +
                                                       (x * cap_M) +
                                                       (y * cap_M_prime) +
                                                       (z * cap_F))))
        return mt(385000560) + correction


    def lunar_position(tee):
        """Return the moon position (geocentric latitude and longitude [in degrees]
        and distance [in meters]) at moment, tee.
        Adapted from "Astronomical Algorithms" by Jean Meeus,
        Willmann_Bell, Inc., 2nd ed."""
        return (lunar_latitude(tee), lunar_longitude(tee), lunar_distance(tee))

    # see lines 3815-3824 in calendrica-3.0.cl
    def lunar_parallax(tee, location):
        """Return the parallax of moon at moment, tee, at location, location.
        Adapted from "Astronomical Algorithms" by Jean Meeus,
        Willmann_Bell, Inc., 1998."""
        geo = lunar_altitude(tee, location)
        Delta = lunar_distance(tee)
        alt = mt(6378140) / Delta
        arg = alt * cosine_degrees(geo)
        return arcsin_degrees(arg)


    # see lines 3826-3832 in calendrica-3.0.cl
    def topocentric_lunar_altitude(tee, location):
        """Return the topocentric altitude of moon at moment, tee,
        at location, location, as a small positive/negative angle in degrees,
        ignoring refraction."""
        return lunar_altitude(tee, location) - lunar_parallax(tee, location)


    # see lines 3834-3839 in calendrica-3.0.cl
    def lunar_diameter(tee):
        """Return the geocentric apparent lunar diameter of the moon (in
        degrees) at moment, tee.  Adapted from 'Astronomical
        Algorithms' by Jean Meeus, Willmann_Bell, Inc., 2nd ed."""
        return deg(1792367000/9) / lunar_distance(tee)

        ###########################################
        # astronomical lunar calendars algorithms #
        ###########################################
        # see lines 5829-5845 in calendrica-3.0.cl
        def visible_crescent(date, location):
            """Return S. K. Shaukat's criterion for likely
            visibility of crescent moon on eve of date 'date',
            at location 'location'."""
            tee = universal_from_standard(dusk(date - 1, location, deg(mpf(4.5))),
                                          location)
            phase = lunar_phase(tee)
            altitude = lunar_altitude(tee, location)
            arc_of_light = arccos_degrees(cosine_degrees(lunar_latitude(tee)) *
                                          cosine_degrees(phase))
            return ((NEW < phase < FIRST_QUARTER) and
                    (deg(mpf(10.6)) <= arc_of_light <= deg(90)) and
                    (altitude > deg(mpf(4.1))))

        # see lines 5847-5860 in calendrica-3.0.cl
        def phasis_on_or_before(date, location):
            """Return the closest fixed date on or before date 'date', when crescent
            moon first became visible at location 'location'."""
            mean = date - ifloor(lunar_phase(date + 1) / deg(360) *
                                 MEAN_SYNODIC_MONTH)
            tau = ((mean - 30)
                   if (((date - mean) <= 3) and (not visible_crescent(date, location)))
                   else (mean - 2))
            return  next(tau, lambda d: visible_crescent(d, location))

        # see lines 5862-5866 in calendrica-3.0.cl
        # see lines 220-221 in calendrica-3.0.errata.cl
        # Sample location for Observational Islamic calendar
        # (Cairo, Egypt).
        ISLAMIC_LOCATION = location(deg(mpf(30.1)), deg(mpf(31.3)), mt(200), hr(2))

        # see lines 5868-5882 in calendrica-3.0.cl
        def fixed_from_observational_islamic(i_date):
            """Return fixed date equivalent to Observational Islamic date, i_date."""
            month    = standard_month(i_date)
            day      = standard_day(i_date)
            year     = standard_year(i_date)
            midmonth = ISLAMIC_EPOCH + ifloor((((year - 1) * 12) + month - 0.5) *
                                              MEAN_SYNODIC_MONTH)
            return (phasis_on_or_before(midmonth, ISLAMIC_LOCATION) +
                    day - 1)

        # see lines 5884-5896 in calendrica-3.0.cl
        def observational_islamic_from_fixed(date):
            """Return Observational Islamic date (year month day)
            corresponding to fixed date, date."""
            crescent = phasis_on_or_before(date, ISLAMIC_LOCATION)
            elapsed_months = iround((crescent - ISLAMIC_EPOCH) / MEAN_SYNODIC_MONTH)
            year = quotient(elapsed_months, 12) + 1
            month = mod(elapsed_months, 12) + 1
            day = (date - crescent) + 1
            return islamic_date(year, month, day)

        # see lines 5898-5901 in calendrica-3.0.cl
        JERUSALEM = location(deg(mpf(31.8)), deg(mpf(35.2)), mt(800), hr(2))

        # see lines 5903-5918 in calendrica-3.0.cl
        def astronomical_easter(g_year):
            """Return date of (proposed) astronomical Easter in Gregorian
            year, g_year."""
            jan1 = gregorian_new_year(g_year)
            equinox = solar_longitude_after(SPRING, jan1)
            paschal_moon = ifloor(apparent_from_local(
                                     local_from_universal(
                                        lunar_phase_at_or_after(FULL, equinox),
                                        JERUSALEM),
                                     JERUSALEM))
            # Return the Sunday following the Paschal moon.
            return kday_after(SUNDAY, paschal_moon)

        # see lines 5920-5923 in calendrica-3.0.cl
        JAFFA = location(angle(32, 1, 60), angle(34, 45, 0), mt(0), hr(2))

        # see lines 5925-5938 in calendrica-3.0.cl
        def phasis_on_or_after(date, location):
            """Return closest fixed date on or after date, date, on the eve
            of which crescent moon first became visible at location, location."""
            mean = date - ifloor(lunar_phase(date + 1) / deg(mpf(360)) *
                                MEAN_SYNODIC_MONTH)
            tau = (date if (((date - mean) <= 3) and
                            (not visible_crescent(date - 1, location)))
                   else (mean + 29))
            return next(tau, lambda d: visible_crescent(d, location))

        # see lines 5940-5955 in calendrica-3.0.cl
        def observational_hebrew_new_year(g_year):
            """Return fixed date of Observational (classical)
            Nisan 1 occurring in Gregorian year, g_year."""
            jan1 = gregorian_new_year(g_year)
            equinox = solar_longitude_after(SPRING, jan1)
            sset = universal_from_standard(sunset(ifloor(equinox), JAFFA), JAFFA)
            return phasis_on_or_after(ifloor(equinox) - (14 if (equinox < sset) else 13),
                                      JAFFA)

        # see lines 5957-5973 in calendrica-3.0.cl
        def fixed_from_observational_hebrew(h_date):
            """Return fixed date equivalent to Observational Hebrew date."""
            month = standard_month(h_date)
            day = standard_day(h_date)
            year = standard_year(h_date)
            year1 = (year - 1) if (month >= TISHRI) else year
            start = fixed_from_hebrew(hebrew_date(year1, NISAN, 1))
            g_year = gregorian_year_from_fixed(start + 60)
            new_year = observational_hebrew_new_year(g_year)
            midmonth = new_year + iround(29.5 * (month - 1)) + 15
            return phasis_on_or_before(midmonth, JAFFA) + day - 1

        # see lines 5975-5991 in calendrica-3.0.cl
        def observational_hebrew_from_fixed(date):
            """Return Observational Hebrew date (year month day)
            corresponding to fixed date, date."""
            crescent = phasis_on_or_before(date, JAFFA)
            g_year = gregorian_year_from_fixed(date)
            ny = observational_hebrew_new_year(g_year)
            new_year = observational_hebrew_new_year(g_year - 1) if (date < ny) else ny
            month = iround((crescent - new_year) / 29.5) + 1
            year = (standard_year(hebrew_from_fixed(new_year)) +
                    (1 if (month >= TISHRI) else 0))
            day = date - crescent + 1
            return hebrew_date(year, month, day)

        # see lines 5993-5997 in calendrica-3.0.cl
        def classical_passover_eve(g_year):
            """Return fixed date of Classical (observational) Passover Eve
            (Nisan 14) occurring in Gregorian year, g_year."""
            return observational_hebrew_new_year(g_year) + 13
  end
end