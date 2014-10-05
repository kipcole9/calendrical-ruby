###############################
# persian calendar algorithms #
###############################
# see lines 3844-3847 in calendrica-3.0.cl
def persian_date(year, month, day):
    """Return a Persian date data structure."""
    return [year, month, day]

# see lines 3849-3852 in calendrica-3.0.cl
PERSIAN_EPOCH = fixed_from_julian(julian_date(ce(622), MARCH, 19))

# see lines 3854-3858 in calendrica-3.0.cl
TEHRAN = location(deg(mpf(35.68)),
                  deg(mpf(51.42)),
                  mt(1100),
                  hr(3 + 1/2))

# see lines 3860-3865 in calendrica-3.0.cl
def midday_in_tehran(date):
    """Return  Universal time of midday on fixed date, date, in Tehran."""
    return universal_from_standard(midday(date, TEHRAN), TEHRAN)

# see lines 3867-3876 in calendrica-3.0.cl
def persian_new_year_on_or_before(date):
    """Return the fixed date of Astronomical Persian New Year on or
    before fixed date, date."""
    approx = estimate_prior_solar_longitude(SPRING, midday_in_tehran(date))
    return next(ifloor(approx) - 1,
                lambda day: (solar_longitude(midday_in_tehran(day)) <=
                             (SPRING + deg(2))))

# see lines 3880-3898 in calendrica-3.0.cl
def fixed_from_persian(p_date):
    """Return fixed date of Astronomical Persian date, p_date."""
    month = standard_month(p_date)
    day = standard_day(p_date)
    year = standard_year(p_date)
    temp = (year - 1) if (0 < year) else year
    new_year = persian_new_year_on_or_before(PERSIAN_EPOCH + 180 +
                                             ifloor(MEAN_TROPICAL_YEAR * temp))
    return ((new_year - 1) +
            ((31 * (month - 1)) if (month <= 7) else (30 * (month - 1) + 6)) +
            day)

# see lines 3898-3918 in calendrica-3.0.cl
def persian_from_fixed(date):
    """Return Astronomical Persian date (year month day)
    corresponding to fixed date, date."""
    new_year = persian_new_year_on_or_before(date)
    y = iround((new_year - PERSIAN_EPOCH) / MEAN_TROPICAL_YEAR) + 1
    year = y if (0 < y) else (y - 1)
    day_of_year = date - fixed_from_persian(persian_date(year, 1, 1)) + 1
    month = (ceiling(day_of_year / 31)
             if (day_of_year <= 186)
             else ceiling((day_of_year - 6) / 30))
    day = date - (fixed_from_persian(persian_date(year, month, 1)) - 1)
    return persian_date(year, month, day)

# see lines 3920-3932 in calendrica-3.0.cl
def is_arithmetic_persian_leap_year(p_year):
    """Return True if p_year is a leap year on the Persian calendar."""
    y    = (p_year - 474) if (0 < p_year) else (p_year - 473)
    year =  mod(y, 2820) + 474
    return  mod((year + 38) * 31, 128) < 31

# see lines 3934-3958 in calendrica-3.0.cl
def fixed_from_arithmetic_persian(p_date):
    """Return fixed date equivalent to Persian date p_date."""
    day    = standard_day(p_date)
    month  = standard_month(p_date)
    p_year = standard_year(p_date)
    y      = (p_year - 474) if (0 < p_year) else (p_year - 473)
    year   = mod(y, 2820) + 474
    temp   = (31 * (month - 1)) if (month <= 7) else ((30 * (month - 1)) + 6)

    return ((PERSIAN_EPOCH - 1) 
            + (1029983 * quotient(y, 2820))
            + (365 * (year - 1))
            + quotient((31 * year) - 5, 128)
            + temp
            + day)

# see lines 3960-3986 in calendrica-3.0.cl
def arithmetic_persian_year_from_fixed(date):
    """Return Persian year corresponding to the fixed date, date."""
    d0    = date - fixed_from_arithmetic_persian(persian_date(475, 1, 1))
    n2820 = quotient(d0, 1029983)
    d1    = mod(d0, 1029983)
    y2820 = 2820 if (d1 == 1029982) else (quotient((128 * d1) + 46878, 46751))
    year  = 474 + (2820 * n2820) + y2820

    return year if (0 < year) else (year - 1)

# see lines 3988-4001 in calendrica-3.0.cl
def arithmetic_persian_from_fixed(date):
    """Return the Persian date corresponding to fixed date, date."""
    year        = arithmetic_persian_year_from_fixed(date)
    day_of_year = 1 + date - fixed_from_arithmetic_persian(
                                  persian_date(year, 1, 1))
    month       = (ceiling(day_of_year / 31)
                   if (day_of_year <= 186)
                   else ceiling((day_of_year - 6) / 30))
    day = date - fixed_from_arithmetic_persian(persian_date(year, month, 1)) +1
    return persian_date(year, month, day)

# see lines 4003-4015 in calendrica-3.0.cl
def naw_ruz(g_year):
    """Return the Fixed date of Persian New Year (Naw-Ruz) in Gregorian
       year g_year."""
    persian_year = g_year - gregorian_year_from_fixed(PERSIAN_EPOCH) + 1
    y = (persian_year - 1) if (persian_year <= 0) else persian_year
    return fixed_from_persian(persian_date(y, 1, 1))
