###############################
# tibetan calendar algorithms #
###############################
# see lines 5677-5681 in calendrica-3.0.cl
def tibetan_date(year, month, leap_month, day, leap_day):
    """Return a Tibetan date data structure."""
    return [year, month, leap_month, day, leap_day]


# see lines 5683-5685 in calendrica-3.0.cl
def tibetan_month(date):
    """Return 'month' element of a Tibetan date, date."""
    return date[1]


# see lines 5687-5689 in calendrica-3.0.cl
def tibetan_leap_month(date):
    """Return 'leap month' element of a Tibetan date, date."""
    return date[2]

# see lines 5691-5693 in calendrica-3.0.cl
def tibetan_day(date):
    """Return 'day' element of a Tibetan date, date."""
    return date[3]

# see lines 5695-5697 in calendrica-3.0.cl
def tibetan_leap_day(date):
    """Return 'leap day' element of a Tibetan date, date."""
    return date[4]

# see lines 5699-5701 in calendrica-3.0.cl
def tibetan_year(date):
    """Return 'year' element of a Tibetan date, date."""
    return date[0]

# see lines 5703-5705 in calendrica-3.0.cl
TIBETAN_EPOCH = fixed_from_gregorian(gregorian_date(-127, DECEMBER, 7))

# see lines 5707-5717 in calendrica-3.0.cl
def tibetan_sun_equation(alpha):
    """Return the interpolated tabular sine of solar anomaly, alpha."""
    if (alpha > 6):
        return -tibetan_sun_equation(alpha - 6)
    elif (alpha > 3):
        return tibetan_sun_equation(6 - alpha)
    elif isinstance(alpha, int):
        return [0, 6/60, 10/60, 11/60][alpha]
    else:
        return ((mod(alpha, 1) * tibetan_sun_equation(ceiling(alpha))) +
                (mod(-alpha, 1) * tibetan_sun_equation(ifloor(alpha))))


# see lines 5719-5731 in calendrica-3.0.cl
def tibetan_moon_equation(alpha):
    """Return the interpolated tabular sine of lunar anomaly, alpha."""
    if (alpha > 14):
        return -tibetan_moon_equation(alpha - 14)
    elif (alpha > 7):
        return tibetan_moon_equation(14 -alpha)
    elif isinstance(alpha, int):
        return [0, 5/60, 10/60, 15/60,
                19/60, 22/60, 24/60, 25/60][alpha]
    else:
        return ((mod(alpha, 1) * tibetan_moon_equation(ceiling(alpha))) +
                (mod(-alpha, 1) * tibetan_moon_equation(ifloor(alpha))))
    

# see lines 5733-5755 in calendrica-3.0.cl
def fixed_from_tibetan(t_date):
    """Return the fixed date corresponding to Tibetan lunar date, t_date."""
    year       = tibetan_year(t_date)
    month      = tibetan_month(t_date)
    leap_month = tibetan_leap_month(t_date)
    day        = tibetan_day(t_date)
    leap_day   = tibetan_leap_day(t_date)
    months = ifloor((804/65 * (year - 1)) +
                   (67/65 * month) +
                   (-1 if leap_month else 0) +
                   64/65)
    days = (30 * months) + day
    mean = ((days * 11135/11312) -30 +
            (0 if leap_day else -1) +
            1071/1616)
    solar_anomaly = mod((days * 13/4824) + 2117/4824, 1)
    lunar_anomaly = mod((days * 3781/105840) +
                        2837/15120, 1)
    sun  = -tibetan_sun_equation(12 * solar_anomaly)
    moon = tibetan_moon_equation(28 * lunar_anomaly)
    return ifloor(TIBETAN_EPOCH + mean + sun + moon)


# see lines 5757-5796 in calendrica-3.0.cl
def tibetan_from_fixed(date):
    """Return the Tibetan lunar date corresponding to fixed date, date."""
    cap_Y = 365 + 4975/18382
    years = ceiling((date - TIBETAN_EPOCH) / cap_Y)
    year0 = final(years,
                  lambda y:(date >=
                            fixed_from_tibetan(
                                tibetan_date(y, 1, False, 1, False))))
    month0 = final(1,
                   lambda m: (date >=
                              fixed_from_tibetan(
                                  tibetan_date(year0, m, False, 1, False))))
    est = date - fixed_from_tibetan(
        tibetan_date(year0, month0, False, 1, False))
    day0 = final(est -2,
                 lambda d: (date >=
                            fixed_from_tibetan(
                                tibetan_date(year0, month0, False, d, False))))
    leap_month = (day0 > 30)
    day = amod(day0, 30)
    if (day > day0):
        temp = month0 - 1
    elif leap_month:
        temp = month0 + 1
    else:
        temp = month0
    month = amod(temp, 12)
    
    if ((day > day0) and (month0 == 1)):
        year = year0 - 1
    elif (leap_month and (month0 == 12)):
        year = year0 + 1
    else:
        year = year0
    leap_day = date == fixed_from_tibetan(
        tibetan_date(year, month, leap_month, day, True))
    return tibetan_date(year, month, leap_month, day, leap_day)


# see lines 5798-5805 in calendrica-3.0.cl
def is_tibetan_leap_month(t_month, t_year):
    """Return True if t_month is leap in Tibetan year, t_year."""
    return (t_month ==
            tibetan_month(tibetan_from_fixed(
                fixed_from_tibetan(
                    tibetan_date(t_year, t_month, True, 2, False)))))


# see lines 5807-5813 in calendrica-3.0.cl
def losar(t_year):
    """Return the  fixed date of Tibetan New Year (Losar)
    in Tibetan year, t_year."""
    t_leap = is_tibetan_leap_month(1, t_year)
    return fixed_from_tibetan(tibetan_date(t_year, 1, t_leap, 1, False))


# see lines 5815-5824 in calendrica-3.0.cl
def tibetan_new_year(g_year):
    """Return the list of fixed dates of Tibetan New Year in
    Gregorian year, g_year."""
    dec31  = gregorian_year_end(g_year)
    t_year = tibetan_year(tibetan_from_fixed(dec31))
    return list_range([losar(t_year - 1), losar(t_year)],
                      gregorian_year_range(g_year))


