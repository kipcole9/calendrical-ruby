#####################################
# modern hindu calendars algorithms #
#####################################
# see lines 4816-4820 in calendrica-3.0.cl
def hindu_lunar_date(year, month, leap_month, day, leap_day):
    """Return a lunar Hindu date data structure."""
    return [year, month, leap_month, day, leap_day]


# see lines 4822-4824 in calendrica-3.0.cl
def hindu_lunar_month(date):
    """Return 'month' element of a lunar Hindu date, date."""
    return date[1]


# see lines 4826-4828 in calendrica-3.0.cl
def hindu_lunar_leap_month(date):
    """Return 'leap_month' element of a lunar Hindu date, date."""
    return date[2]


# see lines 4830-4832 in calendrica-3.0.cl
def hindu_lunar_day(date):
    """Return 'day' element of a lunar Hindu date, date."""
    return date[3]

# see lines 4834-4836 in calendrica-3.0.cl
def hindu_lunar_leap_day(date):
    """Return 'leap_day' element of a lunar Hindu date, date."""
    return date[4]

# see lines 4838-4840 in calendrica-3.0.cl
def hindu_lunar_year(date):
    """Return 'year' element of a lunar Hindu date, date."""
    return date[0]

# see lines 4842-4850 in calendrica-3.0.cl
def hindu_sine_table(entry):
    """Return the value for entry in the Hindu sine table.
    Entry, entry, is an angle given as a multiplier of 225'."""
    exact = 3438 * sin_degrees(entry * angle(0, 225, 0))
    error = 0.215 * signum(exact) * signum(abs(exact) - 1716)
    return iround(exact + error) / 3438


# see lines 4852-4861 in calendrica-3.0.cl
def hindu_sine(theta):
    """Return the linear interpolation for angle, theta, in Hindu table."""
    entry    = theta / angle(0, 225, 0)
    fraction = mod(entry, 1)
    return ((fraction * hindu_sine_table(ceiling(entry))) +
            ((1 - fraction) * hindu_sine_table(ifloor(entry))))


# see lines 4863-4873 in calendrica-3.0.cl
def hindu_arcsin(amp):
    """Return the inverse of Hindu sine function of amp."""
    if (amp < 0):
        return -hindu_arcsin(-amp)
    else:
        pos = next_of(0, lambda k: amp <= hindu_sine_table(k))
        below = hindu_sine_table(pos - 1)
        return (angle(0, 225, 0) *
                (pos - 1 + ((amp - below) / (hindu_sine_table(pos) - below))))


# see lines 4875-4878 in calendrica-3.0.cl
HINDU_SIDEREAL_YEAR = 365 + 279457/1080000

# see lines 4880-4883 in calendrica-3.0.cl
HINDU_CREATION = HINDU_EPOCH - 1955880000 * HINDU_SIDEREAL_YEAR

# see lines 4885-4889 in calendrica-3.0.cl
def hindu_mean_position(tee, period):
    """Return the position in degrees at moment, tee, in uniform circular
    orbit of period days."""
    return deg(360) * mod((tee - HINDU_CREATION) / period, 1)

# see lines 4891-4894 in calendrica-3.0.cl
HINDU_SIDEREAL_MONTH = 27 + 4644439/14438334

# see lines 4896-4899 in calendrica-3.0.cl
HINDU_SYNODIC_MONTH = 29 + 7087771/13358334

# see lines 4901-4904 in calendrica-3.0.cl
HINDU_ANOMALISTIC_YEAR = 1577917828000/(4320000000 - 387)

# see lines 4906-4909 in calendrica-3.0.cl
HINDU_ANOMALISTIC_MONTH = mpf(1577917828)/(57753336 - 488199)

# see lines 4911-4926 in calendrica-3.0.cl
def hindu_true_position(tee, period, size, anomalistic, change):
    """Return the longitudinal position at moment, tee.
    period is the period of mean motion in days.
    size is ratio of radii of epicycle and deferent.
    anomalistic is the period of retrograde revolution about epicycle.
    change is maximum decrease in epicycle size."""
    lam         = hindu_mean_position(tee, period)
    offset      = hindu_sine(hindu_mean_position(tee, anomalistic))
    contraction = abs(offset) * change * size
    equation    = hindu_arcsin(offset * (size - contraction))
    return mod(lam - equation, 360)


# see lines 4928-4932 in calendrica-3.0.cl
def hindu_solar_longitude(tee):
    """Return the solar longitude at moment, tee."""
    return hindu_true_position(tee,
                               HINDU_SIDEREAL_YEAR,
                               14/360,
                               HINDU_ANOMALISTIC_YEAR,
                               1/42)


# see lines 4934-4938 in calendrica-3.0.cl
def hindu_zodiac(tee):
    """Return the zodiacal sign of the sun, as integer in range 1..12,
    at moment tee."""
    return quotient(float(hindu_solar_longitude(tee)), deg(30)) + 1


# see lines 4940-4944 in calendrica-3.0.cl
def hindu_lunar_longitude(tee):
    """Return the lunar longitude at moment, tee."""
    return hindu_true_position(tee,
                               HINDU_SIDEREAL_MONTH,
                               32/360,
                               HINDU_ANOMALISTIC_MONTH,
                               1/96)


# see lines 4946-4952 in calendrica-3.0.cl
def hindu_lunar_phase(tee):
    """Return the longitudinal distance between the sun and moon
    at moment, tee."""
    return mod(hindu_lunar_longitude(tee) - hindu_solar_longitude(tee), 360)


# see lines 4954-4958 in calendrica-3.0.cl
def hindu_lunar_day_from_moment(tee):
    """Return the phase of moon (tithi) at moment, tee, as an integer in
    the range 1..30."""
    return quotient(hindu_lunar_phase(tee), deg(12)) + 1


# see lines 4960-4973 in calendrica-3.0.cl
def hindu_new_moon_before(tee):
    """Return the approximate moment of last new moon preceding moment, tee,
    close enough to determine zodiacal sign."""
    varepsilon = pow(2, -1000)
    tau = tee - ((1/deg(360))   *
                 hindu_lunar_phase(tee) *
                 HINDU_SYNODIC_MONTH)
    return binary_search(tau - 1, min(tee, tau + 1),
                         lambda l, u: ((hindu_zodiac(l) == hindu_zodiac(u)) or
                                       ((u - l) < varepsilon)),
                         lambda x: hindu_lunar_phase(x) < deg(180))


# see lines 4975-4988 in calendrica-3.0.cl
def hindu_lunar_day_at_or_after(k, tee):
    """Return the time lunar_day (tithi) number, k, begins at or after
    moment, tee.  k can be fractional (for karanas)."""
    phase = (k - 1) * deg(12)
    tau   = tee + ((1/deg(360)) *
                   mod(phase - hindu_lunar_phase(tee), 360) *
                   HINDU_SYNODIC_MONTH)
    a = max(tee, tau - 2)
    b = tau + 2
    return invert_angular(hindu_lunar_phase, phase, a, b)


# see lines 4990-4996 in calendrica-3.0.cl
def hindu_calendar_year(tee):
    """Return the solar year at given moment, tee."""
    return iround(((tee - HINDU_EPOCH) / HINDU_SIDEREAL_YEAR) -
                 (hindu_solar_longitude(tee) / deg(360)))


# see lines 4998-5001 in calendrica-3.0.cl
HINDU_SOLAR_ERA = 3179

# see lines 5003-5020 in calendrica-3.0.cl
def hindu_solar_from_fixed(date):
    """Return the Hindu (Orissa) solar date equivalent to fixed date, date."""
    critical = hindu_sunrise(date + 1)
    month    = hindu_zodiac(critical)
    year     = hindu_calendar_year(critical) - HINDU_SOLAR_ERA
    approx   = date - 3 - mod(ifloor(hindu_solar_longitude(critical)), deg(30))
    begin    = next_of(approx,
                    lambda i: (hindu_zodiac(hindu_sunrise(i + 1)) ==  month))
    day      = date - begin + 1
    return hindu_solar_date(year, month, day)


# see lines 5022-5039 in calendrica-3.0.cl
def fixed_from_hindu_solar(s_date):
    """Return the fixed date corresponding to Hindu solar date, s_date,
    (Saka era; Orissa rule.)"""
    month = standard_month(s_date)
    day   = standard_day(s_date)
    year  = standard_year(s_date)
    begin = ifloor((year + HINDU_SOLAR_ERA + ((month - 1)/12)) *
                  HINDU_SIDEREAL_YEAR + HINDU_EPOCH)
    return (day - 1 +
            next_of(begin - 3,
                 lambda d: (hindu_zodiac(hindu_sunrise(d + 1)) == month)))


# see lines 5041-5044 in calendrica-3.0.cl
HINDU_LUNAR_ERA = 3044

# see lines 5046-5074 in calendrica-3.0.cl
def hindu_lunar_from_fixed(date):
    """Return the Hindu lunar date, new_moon scheme, 
    equivalent to fixed date, date."""
    critical = hindu_sunrise(date)
    day      = hindu_lunar_day_from_moment(critical)
    leap_day = (day == hindu_lunar_day_from_moment(hindu_sunrise(date - 1)))
    last_new_moon = hindu_new_moon_before(critical)
    next_new_moon = hindu_new_moon_before(ifloor(last_new_moon) + 35)
    solar_month   = hindu_zodiac(last_new_moon)
    leap_month    = (solar_month == hindu_zodiac(next_new_moon))
    month    = amod(solar_month + 1, 12)
    year     = (hindu_calendar_year((date + 180) if (month <= 2) else date) -
                HINDU_LUNAR_ERA)
    return hindu_lunar_date(year, month, leap_month, day, leap_day)


# see lines 5076-5123 in calendrica-3.0.cl
def fixed_from_hindu_lunar(l_date):
    """Return the Fixed date corresponding to Hindu lunar date, l_date."""
    year       = hindu_lunar_year(l_date)
    month      = hindu_lunar_month(l_date)
    leap_month = hindu_lunar_leap_month(l_date)
    day        = hindu_lunar_day(l_date)
    leap_day   = hindu_lunar_leap_day(l_date)
    approx = HINDU_EPOCH + (HINDU_SIDEREAL_YEAR *
                            (year + HINDU_LUNAR_ERA + ((month - 1) / 12)))
    s = ifloor(approx - ((1/deg(360)) *
                        HINDU_SIDEREAL_YEAR *
                        mod(hindu_solar_longitude(approx) -
                            ((month - 1) * deg(30)) +
                            deg(180), 360) -
                        deg(180)))
    k = hindu_lunar_day_from_moment(s + hr(6))
    if (3 < k < 27):
        temp = k
    else:
        mid = hindu_lunar_from_fixed(s - 15)
        if ((hindu_lunar_month(mid) != month) or
            (hindu_lunar_leap_month(mid) and not leap_month)):
            temp = mod(k + 15, 30) - 15
        else:
            temp = mod(k - 15, 30) + 15
    
    est = s + day - temp
    tau = (est -
           mod(hindu_lunar_day_from_moment(est + hr(6)) - day + 15, 30) +
           15)
    date = next_of(tau - 1,
                lambda d: (hindu_lunar_day_from_moment(hindu_sunrise(d)) in
                           [day, amod(day + 1, 30)]))
    return (date + 1) if leap_day else date


# see lines 5125-5139 in calendrica-3.0.cl
def hindu_equation_of_time(date):
    """Return the time from true to mean midnight of date, date."""
    offset = hindu_sine(hindu_mean_position(date, HINDU_ANOMALISTIC_YEAR))
    equation_sun = (offset *
                    angle(57, 18, 0) *
                    (14/360 - (abs(offset) / 1080)))
    return ((hindu_daily_motion(date) / deg(360)) *
            (equation_sun / deg(360)) *
            HINDU_SIDEREAL_YEAR)


# see lines 5141-5155 in calendrica-3.0.cl
def hindu_ascensional_difference(date, location):
    """Return the difference between right and oblique ascension
    of sun on date, date, at loacel, location."""
    sin_delta = (1397/3438) * hindu_sine(hindu_tropical_longitude(date))
    phi = latitude(location)
    diurnal_radius = hindu_sine(deg(90) + hindu_arcsin(sin_delta))
    tan_phi = hindu_sine(phi) / hindu_sine(deg(90) + phi)
    earth_sine = sin_delta * tan_phi
    return hindu_arcsin(-earth_sine / diurnal_radius)


# see lines 5157-5172 in calendrica-3.0.cl
def hindu_tropical_longitude(date):
    """Return the Hindu tropical longitude on fixed date, date.
    Assumes precession with maximum of 27 degrees
    and period of 7200 sidereal years (= 1577917828/600 days)."""
    days = ifloor(date - HINDU_EPOCH)
    precession = (deg(27) -
                  (abs(deg(54) -
                       mod(deg(27) +
                           (deg(108) * 600/1577917828 * days),
                           108))))
    return mod(hindu_solar_longitude(date) - precession, 360)


# see lines 5174-5183 in calendrica-3.0.cl
def hindu_rising_sign(date):
    """Return the tabulated speed of rising of current zodiacal sign on
    date, date."""
    i = quotient(float(hindu_tropical_longitude(date)), deg(30))
    return [1670/1800, 1795/1800, 1935/1800, 1935/1800,
            1795/1800, 1670/1800][mod(i, 6)]


# see lines 5185-5200 in calendrica-3.0.cl
def hindu_daily_motion(date):
    """Return the sidereal daily motion of sun on date, date."""
    mean_motion = deg(360) / HINDU_SIDEREAL_YEAR
    anomaly     = hindu_mean_position(date, HINDU_ANOMALISTIC_YEAR)
    epicycle    = 14/360 - abs(hindu_sine(anomaly)) / 1080
    entry       = quotient(float(anomaly), angle(0, 225, 0))
    sine_table_step = hindu_sine_table(entry + 1) - hindu_sine_table(entry)
    factor = -3438/225 * sine_table_step * epicycle
    return mean_motion * (factor + 1)


# see lines 5202-5205 in calendrica-3.0.cl
def hindu_solar_sidereal_difference(date):
    """Return the difference between solar and sidereal day on date, date."""
    return hindu_daily_motion(date) * hindu_rising_sign(date)


# see lines 5207-5211 in calendrica-3.0.cl
UJJAIN = location(angle(23, 9, 0), angle(75, 46, 6),
                  mt(0), hr(5 + 461/9000))

# see lines 5213-5216 in calendrica-3.0.cl
# see lines 217-218 in calendrica-3.0.errata.cl
HINDU_LOCATION = UJJAIN

# see lines 5218-5228 in calendrica-3.0.cl
def hindu_sunrise(date):
    """Return the sunrise at hindu_location on date, date."""
    return (date + hr(6) + 
            ((longitude(UJJAIN) - longitude(HINDU_LOCATION)) / deg(360)) -
            hindu_equation_of_time(date) +
            ((1577917828/1582237828 / deg(360)) *
             (hindu_ascensional_difference(date, HINDU_LOCATION) +
              (1/4 * hindu_solar_sidereal_difference(date)))))


# see lines 5230-5244 in calendrica-3.0.cl
def hindu_fullmoon_from_fixed(date):
    """Return the Hindu lunar date, full_moon scheme, 
    equivalent to fixed date, date."""
    l_date     = hindu_lunar_from_fixed(date)
    year       = hindu_lunar_year(l_date)
    month      = hindu_lunar_month(l_date)
    leap_month = hindu_lunar_leap_month(l_date)
    day        = hindu_lunar_day(l_date)
    leap_day   = hindu_lunar_leap_day(l_date)
    m = (hindu_lunar_month(hindu_lunar_from_fixed(date + 20))
         if (day >= 16)
         else month)
    return hindu_lunar_date(year, m, leap_month, day, leap_day)


# see lines 5246-5255 in calendrica-3.0.cl
def is_hindu_expunged(l_month, l_year):
    """Return True if Hindu lunar month l_month in year, l_year
    is expunged."""
    return (l_month !=
            hindu_lunar_month(
                hindu_lunar_from_fixed(
                    fixed_from_hindu_lunar(
                        [l_year, l_month, False, 15, False]))))


# see lines 5257-5272 in calendrica-3.0.cl
def fixed_from_hindu_fullmoon(l_date):
    """Return the fixed date equivalent to Hindu lunar date, l_date,
    in full_moon scheme."""
    year       = hindu_lunar_year(l_date)
    month      = hindu_lunar_month(l_date)
    leap_month = hindu_lunar_leap_month(l_date)
    day        = hindu_lunar_day(l_date)
    leap_day   = hindu_lunar_leap_day(l_date)
    if (leap_month or (day <= 15)):
        m = month
    elif (is_hindu_expunged(amod(month - 1, 12), year)):
        m = amod(month - 2, 12)
    else:
        m = amod(month - 1, 12)
    return fixed_from_hindu_lunar(
        hindu_lunar_date(year, m, leap_month, day, leap_day))


# see lines 5274-5280 in calendrica-3.0.cl
def alt_hindu_sunrise(date):
    """Return the astronomical sunrise at Hindu location on date, date,
    per Lahiri, rounded to nearest minute, as a rational number."""
    rise = dawn(date, HINDU_LOCATION, angle(0, 47, 0))
    return 1/24 * 1/60 * iround(rise * 24 * 60)


# see lines 5282-5292 in calendrica-3.0.cl
def hindu_sunset(date):
    """Return sunset at HINDU_LOCATION on date, date."""
    return (date + hr(18) + 
            ((longitude(UJJAIN) - longitude(HINDU_LOCATION)) / deg(360)) -
            hindu_equation_of_time(date) +
            (((1577917828/1582237828) / deg(360)) *
             (- hindu_ascensional_difference(date, HINDU_LOCATION) +
              (3/4 * hindu_solar_sidereal_difference(date)))))


# see lines 5294-5313 in calendrica-3.0.cl
def hindu_sundial_time(tee):
    """Return Hindu local time of temporal moment, tee."""
    date = fixed_from_moment(tee)
    time = mod(tee, 1)
    q    = ifloor(4 * time)
    if (q == 0):
        a = hindu_sunset(date - 1)
        b = hindu_sunrise(date)
        t = hr(-6)
    elif (q == 3):
        a = hindu_sunset(date)
        b = hindu_sunrise(date + 1)
        t = hr(18)
    else:
        a = hindu_sunrise(date)
        b = hindu_sunset(date)
        t = hr(6)
    return a + (2 * (b - a) * (time - t))


# see lines 5315-5318 in calendrica-3.0.cl
def ayanamsha(tee):
    """Return the difference between tropical and sidereal solar longitude."""
    return solar_longitude(tee) - sidereal_solar_longitude(tee)


# see lines 5320-5323 in calendrica-3.0.cl
def astro_hindu_sunset(date):
    """Return the geometrical sunset at Hindu location on date, date."""
    return dusk(date, HINDU_LOCATION, deg(0))


# see lines 5325-5329 in calendrica-3.0.cl
def sidereal_zodiac(tee):
    """Return the sidereal zodiacal sign of the sun, as integer in range
    1..12, at moment, tee."""
    return quotient(int(sidereal_solar_longitude(tee)), deg(30)) + 1


# see lines 5331-5337 in calendrica-3.0.cl
def astro_hindu_calendar_year(tee):
    """Return the astronomical Hindu solar year KY at given moment, tee."""
    return iround(((tee - HINDU_EPOCH) / MEAN_SIDEREAL_YEAR) -
                 (sidereal_solar_longitude(tee) / deg(360)))


# see lines 5339-5357 in calendrica-3.0.cl
def astro_hindu_solar_from_fixed(date):
    """Return the Astronomical Hindu (Tamil) solar date equivalent to
    fixed date, date."""
    critical = astro_hindu_sunset(date)
    month    = sidereal_zodiac(critical)
    year     = astro_hindu_calendar_year(critical) - HINDU_SOLAR_ERA
    approx   = (date - 3 -
                mod(ifloor(sidereal_solar_longitude( critical)), deg(30)))
    begin    = next_of(approx,
                    lambda i: (sidereal_zodiac(astro_hindu_sunset(i)) == month))
    day      = date - begin + 1
    return hindu_solar_date(year, month, day)


# see lines 5359-5375 in calendrica-3.0.cl
def fixed_from_astro_hindu_solar(s_date):
    """Return the fixed date corresponding to Astronomical 
    Hindu solar date (Tamil rule; Saka era)."""
    month = standard_month(s_date)
    day   = standard_day(s_date)
    year  = standard_year(s_date)
    approx = (HINDU_EPOCH - 3 +
              ifloor(((year + HINDU_SOLAR_ERA) + ((month - 1) / 12)) *
                    MEAN_SIDEREAL_YEAR))
    begin = next_of(approx,
                 lambda i: (sidereal_zodiac(astro_hindu_sunset(i)) == month))
    return begin + day - 1


# see lines 5377-5381 in calendrica-3.0.cl
def astro_lunar_day_from_moment(tee):
    """Return the phase of moon (tithi) at moment, tee, as an integer in
    the range 1..30."""
    return quotient(lunar_phase(tee), deg(12)) + 1


# see lines 5383-5410 in calendrica-3.0.cl
def astro_hindu_lunar_from_fixed(date):
    """Return the astronomical Hindu lunar date equivalent to
    fixed date, date."""
    critical = alt_hindu_sunrise(date)
    day      = astro_lunar_day_from_moment(critical)
    leap_day = (day == astro_lunar_day_from_moment(
        alt_hindu_sunrise(date - 1)))
    last_new_moon = new_moon_before(critical)
    next_new_moon = new_moon_at_or_after(critical)
    solar_month   = sidereal_zodiac(last_new_moon)
    leap_month    = solar_month == sidereal_zodiac(next_new_moon)
    month    = amod(solar_month + 1, 12)
    year     = astro_hindu_calendar_year((date + 180)
                                         if (month <= 2)
                                         else date) - HINDU_LUNAR_ERA
    return hindu_lunar_date(year, month, leap_month, day, leap_day)


# see lines 5412-5460 in calendrica-3.0.cl
def fixed_from_astro_hindu_lunar(l_date):
    """Return the fixed date corresponding to Hindu lunar date, l_date."""
    year  = hindu_lunar_year(l_date)
    month = hindu_lunar_month(l_date)
    leap_month = hindu_lunar_leap_month(l_date)
    day   = hindu_lunar_day(l_date)
    leap_day = hindu_lunar_leap_day(l_date)
    approx = (HINDU_EPOCH +
              MEAN_SIDEREAL_YEAR *
              (year + HINDU_LUNAR_ERA + ((month - 1) / 12)))
    s = ifloor(approx -
              1/deg(360) * MEAN_SIDEREAL_YEAR *
              (mod(sidereal_solar_longitude(approx) -
                  (month - 1) * deg(30) + deg(180), 360) - deg(180)))
    k = astro_lunar_day_from_moment(s + hr(6))
    if (3 < k < 27):
        temp = k
    else:
        mid = astro_hindu_lunar_from_fixed(s - 15)
        if ((hindu_lunar_month(mid) != month) or
            (hindu_lunar_leap_month(mid) and not leap_month)):
            temp = mod(k + 15, 30) - 15
        else:
            temp = mod(k - 15, 30) + 15
    est = s + day - temp
    tau = (est -
           mod(astro_lunar_day_from_moment(est + hr(6)) - day + 15, 30) +
           15)
    date = next_of(tau - 1,
                lambda d: (astro_lunar_day_from_moment(alt_hindu_sunrise(d)) in
                           [day, amod(day + 1, 30)]))
    return (date + 1) if leap_day else date


# see lines 5462-5467 in calendrica-3.0.cl
def hindu_lunar_station(date):
    """Return the Hindu lunar station (nakshatra) at sunrise on date, date."""
    critical = hindu_sunrise(date)
    return quotient(hindu_lunar_longitude(critical), angle(0, 800, 0)) + 1


# see lines 5469-5480 in calendrica-3.0.cl
def hindu_solar_longitude_at_or_after(lam, tee):
    """Return the moment of the first time at or after moment, tee
    when Hindu solar longitude will be lam degrees."""
    tau = tee + (HINDU_SIDEREAL_YEAR *
                 (1 / deg(360)) *
                 mod(lam - hindu_solar_longitude(tee), 360))
    a = max(tee, tau - 5)
    b = tau +5
    return invert_angular(hindu_solar_longitude, lam, a, b)


# see lines 5482-5487 in calendrica-3.0.cl
def mesha_samkranti(g_year):
    """Return the fixed moment of Mesha samkranti (Vernal equinox)
    in Gregorian year, g_year."""
    jan1 = gregorian_new_year(g_year)
    return hindu_solar_longitude_at_or_after(deg(0), jan1)


# see lines 5489-5493 in calendrica-3.0.cl
SIDEREAL_START = precession(universal_from_local(mesha_samkranti(ce(285)),
                                                 HINDU_LOCATION))

# see lines 5495-5513 in calendrica-3.0.cl
def hindu_lunar_new_year(g_year):
    """Return the fixed date of Hindu lunisolar new year in
    Gregorian year, g_year."""
    jan1     = gregorian_new_year(g_year)
    mina     = hindu_solar_longitude_at_or_after(deg(330), jan1)
    new_moon = hindu_lunar_day_at_or_after(1, mina)
    h_day    = ifloor(new_moon)
    critical = hindu_sunrise(h_day)
    return (h_day +
            (0 if ((new_moon < critical) or
                   (hindu_lunar_day_from_moment(hindu_sunrise(h_day + 1)) == 2))
             else 1))


# see lines 5515-5539 in calendrica-3.0.cl
def is_hindu_lunar_on_or_before(l_date1, l_date2):
    """Return True if Hindu lunar date, l_date1 is on or before
    Hindu lunar date, l_date2."""
    month1 = hindu_lunar_month(l_date1)
    month2 = hindu_lunar_month(l_date2)
    leap1  = hindu_lunar_leap_month(l_date1)
    leap2  = hindu_lunar_leap_month(l_date2)
    day1   = hindu_lunar_day(l_date1)
    day2   = hindu_lunar_day(l_date2)
    leap_day1 = hindu_lunar_leap_day(l_date1)
    leap_day2 = hindu_lunar_leap_day(l_date2)
    year1  = hindu_lunar_year(l_date1)
    year2  = hindu_lunar_year(l_date2)
    return ((year1 < year2) or
            ((year1 == year2) and
             ((month1 < month2) or
              ((month1 == month2) and
               ((leap1 and not leap2) or
                ((leap1 == leap2) and
                 ((day1 < day2) or
                  ((day1 == day2) and
                   ((not leap_day1) or
                    leap_day2)))))))))


# see lines 5941-5967 in calendrica-3.0.cl
def hindu_date_occur(l_month, l_day, l_year):
    """Return the fixed date of occurrence of Hindu lunar month, l_month,
    day, l_day, in Hindu lunar year, l_year, taking leap and
    expunged days into account.  When the month is
    expunged, then the following month is used."""
    lunar = hindu_lunar_date(l_year, l_month, False, l_day, False)
    ttry   = fixed_from_hindu_lunar(lunar)
    mid   = hindu_lunar_from_fixed((ttry - 5) if (l_day > 15) else ttry)
    expunged = l_month != hindu_lunar_month(mid)
    l_date = hindu_lunar_date(hindu_lunar_year(mid),
                              hindu_lunar_month(mid),
                              hindu_lunar_leap_month(mid),
                              l_day,
                              False)
    if (expunged):
        return next_of(ttry,
                    lambda d: (not is_hindu_lunar_on_or_before(
                        hindu_lunar_from_fixed(d),
                        l_date))) - 1
    elif (l_day != hindu_lunar_day(hindu_lunar_from_fixed(ttry))):
        return ttry - 1
    else:
        return ttry


# see lines 5969-5980 in calendrica-3.0.cl
def hindu_lunar_holiday(l_month, l_day, g_year):
    """Return the list of fixed dates of occurrences of Hindu lunar
    month, month, day, day, in Gregorian year, g_year."""
    l_year = hindu_lunar_year(
        hindu_lunar_from_fixed(gregorian_new_year(g_year)))
    date1  = hindu_date_occur(l_month, l_day, l_year)
    date2  = hindu_date_occur(l_month, l_day, l_year + 1)
    return list_range([date1, date2], gregorian_year_range(g_year))


# see lines 5582-5586 in calendrica-3.0.cl
def diwali(g_year):
    """Return the list of fixed date(s) of Diwali in Gregorian year, g_year."""
    return hindu_lunar_holiday(8, 1, g_year)


# see lines 5588-5605 in calendrica-3.0.cl
def hindu_tithi_occur(l_month, tithi, tee, l_year):
    """Return the fixed date of occurrence of Hindu lunar tithi prior
    to sundial time, tee, in Hindu lunar month, l_month, and
    year, l_year."""
    approx = hindu_date_occur(l_month, ifloor(tithi), l_year)
    lunar  = hindu_lunar_day_at_or_after(tithi, approx - 2)
    ttry    = fixed_from_moment(lunar)
    tee_h  = standard_from_sundial(ttry + tee, UJJAIN)
    if ((lunar <= tee_h) or
        (hindu_lunar_phase(standard_from_sundial(ttry + 1 + tee, UJJAIN)) >
         (12 * tithi))):
        return ttry
    else:
        return ttry + 1


# see lines 5607-5620 in calendrica-3.0.cl
def hindu_lunar_event(l_month, tithi, tee, g_year):
    """Return the list of fixed dates of occurrences of Hindu lunar tithi
    prior to sundial time, tee, in Hindu lunar month, l_month,
    in Gregorian year, g_year."""
    l_year = hindu_lunar_year(
        hindu_lunar_from_fixed(gregorian_new_year(g_year)))
    date1  = hindu_tithi_occur(l_month, tithi, tee, l_year)
    date2  = hindu_tithi_occur(l_month, tithi, tee, l_year + 1)
    return list_range([date1, date2],
                      gregorian_year_range(g_year))


# see lines 5622-5626 in calendrica-3.0.cl
def shiva(g_year):
    """Return the list of fixed date(s) of Night of Shiva in Gregorian
    year, g_year."""
    return hindu_lunar_event(11, 29, hr(24), g_year)


# see lines 5628-5632 in calendrica-3.0.cl
def rama(g_year):
    """Return the list of fixed date(s) of Rama's Birthday in Gregorian
    year, g_year."""
    return hindu_lunar_event(1, 9, hr(12), g_year)


# see lines 5634-5640 in calendrica-3.0.cl
def karana(n):
    """Return the number (0-10) of the name of the n-th (1-60) Hindu
    karana."""
    if (n == 1):
        return 0
    elif (n > 57):
        return n - 50
    else:
        return amod(n - 1, 7)


# see lines 5642-5648 in calendrica-3.0.cl
def yoga(date):
    """Return the Hindu yoga on date, date."""
    return ifloor(mod((hindu_solar_longitude(date) +
                 hindu_lunar_longitude(date)) / angle(0, 800, 0), 27)) + 1


# see lines 5650-5655 in calendrica-3.0.cl
def sacred_wednesdays(g_year):
    """Return the list of Wednesdays in Gregorian year, g_year,
    that are day 8 of Hindu lunar months."""
    return sacred_wednesdays_in_range(gregorian_year_range(g_year))


# see lines 5657-5672 in calendrica-3.0.cl
def sacred_wednesdays_in_range(range):
    """Return the list of Wednesdays within range of dates
    that are day 8 of Hindu lunar months."""
    a      = start(range)
    b      = end(range)
    wed    = kday_on_or_after(WEDNESDAY, a)
    h_date = hindu_lunar_from_fixed(wed)
    ell  = [wed] if (hindu_lunar_day(h_date) == 8) else []
    if is_in_range(wed, range):
        ell[:0] = sacred_wednesdays_in_range(interval(wed + 1, b))
        return ell
    else:
        return []
