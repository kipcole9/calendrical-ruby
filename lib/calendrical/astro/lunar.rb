require "#{File.dirname(__FILE__)}/../mpf.rb"

module Calendrical
  module Astro
    module Lunar
      extend Calendrical::Mpf
      include Constants
      using Calendrical::Numeric
      
      # see lines 460-467 in calendrica-3.0.errata.cl
      # Return the standard time of moonrise on fixed, date,
      # and location, location.
      # TODO Not sure moonrise is calculating the right result
      def moonrise(location, date)
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
        # puts "t: #{t}; waning: #{waning}; alt: #{alt}; approx: #{approx}"
        rise = binary_search(
          approx - 3.hrs,
          approx + 3.hrs,
          lambda {|u, l| (u - l) < (1.0 / 60).hrs },
          lambda {|x| observed_lunar_altitude(x, location) > 0.degrees}
        )
        (rise < (t + 1)) ? standard_from_universal(rise, location) : BOGUS
      end
      
      # see lines 3596-3613 in calendrica-3.0.cl
      # Return the lunar phase, as an angle in degrees, at moment tee.
      # An angle of 0 means a new moon, 90 degrees means the
      # first quarter, 180 means a full moon, and 270 degrees
      # means the last quarter.
      def lunar_phase(tee)
        phi = (lunar_longitude(tee) - solar_longitude(tee)) % 360
        # puts "Tee: #{tee}, Lunar long: #{lunar_longitude(tee)}; Solar long: #{solar_longitude(tee)}"
        t0 = nth_new_moon(0)
        n = ((tee - t0) / MEAN_SYNODIC_MONTH).round
        phi_prime = (360.degrees *
                     (((tee - nth_new_moon(n)) / MEAN_SYNODIC_MONTH) % 1))
        # puts "nth: #{nth_new_moon(n)}; mod: #{((tee - nth_new_moon(n)) / MEAN_SYNODIC_MONTH) % 1}"
        # puts "lunar_phase: phi: #{phi}, t0: #{t0}; n: #{n}; phi_prime: #{phi_prime}"             
        if (phi - phi_prime).abs > 180.degrees
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
                (1.0/360.degrees) *
                ((lunar_phase(tee) - phi) % 360)))
        a = tau - 2
        b = [tee, tau + 2].min
        invert_angular(lambda{|x| lunar_phase(x)}, phi, a, b)
      end

      # see lines 3651-3661 in calendrica-3.0.cl
      # Return the moment UT of the next time at or after moment, tee,
      # when the lunar_phase is phi degrees.
      def lunar_phase_at_or_after(phi, tee)
        tau = (tee +
               (MEAN_SYNODIC_MONTH    *
                (1.0/360.degrees) *
                (phi - lunar_phase(tee)) % 360))
        a = [tee, tau - 2].max
        b = tau + 2
        invert_angular(lambda{|x| lunar_phase(x)}, phi, a, b)
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
        l = lambda{|v, w, x, y, z| (v * cap_E ** x.abs * cosine_degrees((w * cap_D) + (x * cap_M) + (y * cap_M_prime) + (z * cap_F)))}
        a = [LUNAR_COSINE_COEFFICIENTS, LUNAR_ELONGATION, SOLAR_ANOMALY, LUNAR_ANOMALY, MOON_MODE]
        correction = sigma(a, l)
        return 385000560.meters + correction
      end
      
      # see lines 5925-5938 in calendrica-3.0.cl
      # Return closest fixed date on or after date, date, on the eve
      # of which crescent moon first became visible at location, location.
      def phasis_on_or_after(f_date, location)
        mean = f_date - (lunar_phase(f_date + 1) / mpf(360).degrees * MEAN_SYNODIC_MONTH).floor
        tau = (f_date - mean) <= 3 && !visible_crescent?(f_date - 1, location) ? date : (mean + 29)
        next_of(tau, lambda{|d| visible_crescent?(d, location)})
      end
      
      # see lines 5847-5860 in calendrica-3.0.cl
      # Return the closest fixed date on or before date 'date', when crescent
      # moon first became visible at location 'location'.
      def phasis_on_or_before(f_date, location)
        mean = f_date - (lunar_phase(f_date + 1) / mpf(360).degrees * MEAN_SYNODIC_MONTH).floor
        tau = (f_date - mean) <= 3 && !visible_crescent?(f_date, location) ? (mean - 30) : (mean - 2)
        next_of(tau, lambda{|d| visible_crescent?(d, location)})
      end
      
      # see lines 5829-5845 in calendrica-3.0.cl
      # Return S. K. Shaukat's criterion for likely
      # visibility of crescent moon on eve of date 'date',
      # at location 'location'.
      def visible_crescent?(date, location)
        tee = universal_from_standard(dusk(date - 1, location, mpf(4.5).degrees), location)
        phase = lunar_phase(tee)
        altitude = lunar_altitude(tee, location)
        arc_of_light = arccos_degrees(cosine_degrees(lunar_latitude(tee)) *
                                      cosine_degrees(phase))
        ((NEW_MOON < phase && phase < FIRST_QUARTER) && (mpf(10.6).degrees <= arc_of_light <= 90.degrees) && 
          (altitude > mpf(4.1).degrees))
      end
      
    protected
      # see lines 453-458 in calendrica-3.0.errata.cl
      # Return the observed altitude of moon at moment, tee, and
      # at location, location,  taking refraction into account.
      def observed_lunar_altitude(tee, location)
        topocentric_lunar_altitude(tee, location) + refraction(tee, location)
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

      # see lines 3367-3376 in calendrica-3.0.cl
      # Return mean longitude of moon (in degrees) at moment
      # given in Julian centuries c (including the constant term of the
      # effect of the light-time (-0".70).
      # Adapted from eq. 47.1 in "Astronomical Algorithms" by Jean Meeus,
      # Willmann_Bell, Inc., 2nd ed. with corrections, 2005.
      def mean_lunar_longitude(c)
        degrees(poly(c,[mpf(218.3164477), mpf(481267.88123421), mpf(-0.0015786), mpf(1/538841), mpf(-1/65194000)]))
      end

      # see lines 3378-3387 in calendrica-3.0.cl
      # Return elongation of moon (in degrees) at moment
      # given in Julian centuries c.
      # Adapted from eq. 47.2 in "Astronomical Algorithms" by Jean Meeus,
      # Willmann_Bell, Inc., 2nd ed. with corrections, 2005.
      def lunar_elongation(c)
        degrees(poly(c, [mpf(297.8501921), mpf(445267.1114034), mpf(-0.0018819), mpf(1.0/545868), mpf(-1.0/113065000)]))
      end

      # see lines 3400-3409 in calendrica-3.0.cl
      # Return mean anomaly of moon (in degrees) at moment
      # given in Julian centuries c.
      # Adapted from eq. 47.4 in "Astronomical Algorithms" by Jean Meeus,
      # Willmann_Bell, Inc., 2nd ed. with corrections, 2005.
      def lunar_anomaly(c)
        degrees(poly(c, [mpf(134.9633964), mpf(477198.8675055), mpf(0.0087414), mpf(1.0/69699), mpf(-1.0/14712000)]))
      end

      # see lines 3411-3420 in calendrica-3.0.cl
      # Return Moon's argument of latitude (in degrees) at moment
      # given in Julian centuries 'c'.
      # Adapted from eq. 47.5 in "Astronomical Algorithms" by Jean Meeus,
      # Willmann_Bell, Inc., 2nd ed. with corrections, 2005.
      def moon_node(c)
        degrees(poly(c, [mpf(93.2720950), mpf(483202.0175233), mpf(-0.0036539), mpf(-1.0/3526000), mpf(1.0/863310000)]))
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
        correction = ((1.0/1000000).degrees *
                      sigma([sine_coefficients, args_lunar_elongation, args_solar_anomaly, args_lunar_anomaly, args_moon_node],
                            lambda{|v, w, x, y, z| v * (cap_E ** x.abs) *
                              sin_degrees((w * cap_D) + (x * cap_M) + (y * cap_M_prime) + (z * cap_F))}))
        a1 = mpf(119.75).degrees + (c * mpf(131.849).degrees)
        venus = ((3958.0/1000000) * sin_degrees(a1))
        a2 = mpf(53.09).degrees + c * mpf(479264.29).degrees
        jupiter = ((318.0/1000000).degrees * sin_degrees(a2))
        flat_earth = ((1962.0/1000000).degrees * sin_degrees(cap_L_prime - cap_F))

        (cap_L_prime + correction + venus + jupiter + flat_earth + nutation(tee)) % 360
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
        cap_E = poly(c, [1.0, mpf(-0.002516), mpf(-0.0000074)])
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
        beta = ((1.0/1000000).degrees *
                sigma([sine_coefficients, args_lunar_elongation, args_solar_anomaly, args_lunar_anomaly, args_moon_node],
                       lambda{|v, w, x, y, z| (v * (cap_E ** x.abs) *
                          sin_degrees((w * cap_D) + (x * cap_M) + (y * cap_M_prime) + (z * cap_F)))}))
        venus = (175.0/1000000.degrees * 
                  (sin_degrees(mpf(119.75).degrees + c * mpf(131.849).degrees + cap_F) +
                   sin_degrees(mpf(119.75).degrees + c * mpf(131.849).degrees - cap_F)))
        flat_earth = ((-2235.0/1000000).degrees *  sin_degrees(cap_L_prime) +
                      (127.0/1000000).degrees * sin_degrees(cap_L_prime - cap_M_prime) +
                      (-115.0/1000000).degrees * sin_degrees(cap_L_prime + cap_M_prime))
        extra = ((382.0/1000000).degrees * sin_degrees(mpf(313.45).degrees + c * mpf(481266.484).degrees))
        beta + venus + flat_earth + extra
      end

      # see lines 192-197 in calendrica-3.0.errata.cl
      # Return Angular distance of the node from the equinoctal point
      # at fixed moment, tee.
      # Adapted from eq. 47.7 in "Astronomical Algorithms"
      # by Jean Meeus, Willmann_Bell, Inc., 2nd ed., 1998
      # with corrections June 2005.
      def lunar_node(tee)
        ((moon_node(julian_centuries(tee)) + 90.degrees) % 180) - 90
      end

      # Return Angular distance of the node from the equinoctal point
      # at fixed moment, tee.
      # Adapted from eq. 47.7 in "Astronomical Algorithms"
      # by Jean Meeus, Willmann_Bell, Inc., 2nd ed., 1998
      # with corrections June 2005.
      def alt_lunar_node(tee)
        degrees(poly(julian_centuries(tee), 
          [mpf(125.0445479), mpf(-1934.1362891), mpf(0.0020754), mpf(1.0/467441), mpf(-1.0/60616000)].degrees))
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
        degrees(poly(julian_centuries(tee), [mpf(83.3532465), mpf(4069.0137287), mpf(-0.0103200), mpf(-1.0/80053), mpf(1.0/18999000)]))
      end

      # see lines 199-206 in calendrica-3.0.errata.cl
      # Return sidereal lunar longitude at moment, tee.
      def sidereal_lunar_longitude(tee)
        (lunar_longitude(tee) - precession(tee) + SIDEREAL_START) % 360
      end

      # see lines 99-190 in calendrica-3.0.errata.cl
      # Return the moment of n-th new moon after (or before) the new moon
      # of January 11, 1.  Adapted from "Astronomical Algorithms"
      # by Jean Meeus, Willmann_Bell, Inc., 2nd ed., 1998.
      def nth_new_moon(n)
        n0 = 24724
        k = n - n0
        c = k / mpf(1236.85)
        approx = j2000 + poly(c, [mpf(5.09766), MEAN_SYNODIC_MONTH * mpf(1236.85), mpf(0.0001437), mpf(-0.000000150), mpf(0.00000000073)])
        cap_E = poly(c, [1.0, mpf(-0.002516), mpf(-0.0000074)])
        solar_anomaly = poly(c, [mpf(2.5534), (mpf(1236.85) * mpf(29.10535669)), mpf(-0.0000014), mpf(-0.00000011)])
        lunar_anomaly = poly(c, [mpf(201.5643), (mpf(385.81693528) * mpf(1236.85)), mpf(0.0107582), mpf(0.00001238), mpf(-0.000000058)])
        moon_argument = poly(c, [mpf(160.7108), (mpf(390.67050284) * mpf(1236.85)), mpf(-0.0016118), mpf(-0.00000227), mpf(0.000000011)])
        cap_omega     = poly(c, [mpf(124.7746), (mpf(-1.56375588) * mpf(1236.85)), mpf(0.0020672), mpf(0.00000215)])
        e_factor      = [0, 1, 0, 0, 1, 1, 2, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        solar_coeff   = [0, 1, 0, 0, -1, 1, 2, 0, 0, 1, 0, 1, 1, -1, 2, 0, 3, 1, 0, 1, -1, -1, 1, 0]
        lunar_coeff   = [1, 0, 2, 0, 1, 1, 0, 1, 1, 2, 3, 0, 0, 2, 1, 2, 0, 1, 2, 1, 1, 1, 3, 4]
        moon_coeff    = [0, 0, 0, 2, 0, 0, 0, -2, 2, 0, 0, 2, -2, 0, 0, -2, 0, -2, 2, 2, 2, -2, 0, 0]
        sine_coeff    = [mpf(-0.40720), mpf(0.17241), mpf(0.01608), mpf(0.01039),  mpf(0.00739), mpf(-0.00514),
                          mpf(0.00208), mpf(-0.00111), mpf(-0.00057), mpf(0.00056), mpf(-0.00042), mpf(0.00042),
                          mpf(0.00038), mpf(-0.00024), mpf(-0.00007), mpf(0.00004), mpf(0.00004), mpf(0.00003),
                          mpf(0.00003), mpf(-0.00003), mpf(0.00003),  mpf(-0.00002), mpf(-0.00002), mpf(0.00002)]
        correction = (mpf(-0.00017) * sin_degrees(cap_omega)) +
                      sigma([sine_coeff, e_factor, solar_coeff, lunar_coeff, moon_coeff],
                             lambda{|v, w, x, y, z| (v * (cap_E ** w) *
                                    sin_degrees((x * solar_anomaly) + (y * lunar_anomaly) + (z * moon_argument)))})
        add_const  = [mpf(251.88), mpf(251.83), mpf(349.42), mpf(84.66), mpf(141.74), mpf(207.14), mpf(154.84), mpf(34.52),
                     mpf(207.19), mpf(291.34), mpf(161.72), mpf(239.56), mpf(331.55)]
        add_coeff  = [mpf(0.016321), mpf(26.651886), mpf(36.412478), mpf(18.206239), mpf(53.303771), mpf(2.453732),
                     mpf(7.306860), mpf(27.261239), mpf(0.121824), mpf(1.844379), mpf(24.198154), mpf(25.513099), mpf(3.592518)]
        add_factor = [mpf(0.000165), mpf(0.000164), mpf(0.000126), mpf(0.000110), mpf(0.000062), mpf(0.000060),
                      mpf(0.000056), mpf(0.000047), mpf(0.000042), mpf(0.000040), mpf(0.000037), mpf(0.000035), mpf(0.000023)]
        extra = (mpf(0.000325).degrees *
                 sin_degrees(poly(c, [mpf(299.77), mpf(132.8475848), mpf(-0.009173)])))
        additional = sigma([add_const, add_coeff, add_factor],
                           lambda{|i, j, l| l * sin_degrees(i + j * k)})

        return universal_from_dynamical(approx + correction + extra + additional)
      end

      # see lines 3578-3585 in calendrica-3.0.cl
      # Return the moment UT of last new moon before moment tee.
      def new_moon_before(tee)
        t0 = nth_new_moon(0)
        phi = lunar_phase(tee)
        n = (((tee - t0) / MEAN_SYNODIC_MONTH) - (phi / 360.degrees)).round
        nth_new_moon(final_of(n - 1, lambda{|k| nth_new_moon(k) < tee}))
      end

      # see lines 3587-3594 in calendrica-3.0.cl
      # Return the moment UT of first new moon at or after moment, tee.
      def new_moon_at_or_after(tee)
        t0 = nth_new_moon(0)
        phi = lunar_phase(tee)
        n = ((tee - t0) / MEAN_SYNODIC_MONTH - phi / 360.degrees).round
        nth_new_moon(next_of(n, lambda{|k| nth_new_moon(k) >= tee }))
      end

      # see lines 3734-3762 in calendrica-3.0.cl
      # Return the geocentric altitude of moon at moment, tee,
      # at location, location, as a small positive/negative angle in degrees,
      # ignoring parallax and refraction.  Adapted from 'Astronomical
      # Algorithms' by Jean Meeus, Willmann_Bell, Inc., 1998.
      def lunar_altitude(tee, location)
        phi     = location.latitude
        psi     = location.longitude
        lamb    = lunar_longitude(tee)
        beta    = lunar_latitude(tee)
        alpha   = right_ascension(tee, beta, lamb)
        delta   = declination(tee, beta, lamb)
        theta0  = sidereal_from_moment(tee)
        cap_H   = (theta0 + psi - alpha) % 360
        altitude = arcsin_degrees(
            (sin_degrees(phi) * sin_degrees(delta)) +
            (cosine_degrees(phi) * cosine_degrees(delta) * cosine_degrees(cap_H)))
        # puts "lamb: #{lamb}; beta: #{beta}; alpha: #{alpha}; delta: #{delta}; theta0: #{theta0}; cap_H: #{cap_H}; alt: #{altitude}"    
        return ((altitude + 180.degrees) % 360) - 180.degrees
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
        delta = lunar_distance(tee)
        alt = 6378140.meters / delta
        arg = alt * cosine_degrees(geo)
        arcsin_degrees(arg)
      end

      # see lines 3826-3832 in calendrica-3.0.cl
      # Return the topocentric altitude of moon at moment, tee,
      # at location, location, as a small positive/negative angle in degrees,
      # ignoring refraction.
      def topocentric_lunar_altitude(tee, location)
        # puts "Lunar alt: #{lunar_altitude(tee, location)}; lunar parallax: #{lunar_parallax(tee, location)}"
        lunar_altitude(tee, location) - lunar_parallax(tee, location)
      end

      # see lines 3834-3839 in calendrica-3.0.cl
      # Return the geocentric apparent lunar diameter of the moon (in
      # degrees) at moment, tee.  Adapted from 'Astronomical
      # Algorithms' by Jean Meeus, Willmann_Bell, Inc., 2nd ed.
      def lunar_diameter(tee)
        (1792367000 / 9.0).degrees / lunar_distance(tee)
      end
    end
  end
end