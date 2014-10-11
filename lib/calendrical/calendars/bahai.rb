#############################
# bahai calendar algorithms #
#############################
# see lines 4020-4023 in calendrica-3.0.cl
def bahai_date(major, cycle, year, month, day):
    """Return a Bahai date data structure."""
    return [major, cycle, year, month, day]

# see lines 4025-4027 in calendrica-3.0.cl
def bahai_major(date):
    """Return 'major' element of a  Bahai date, date."""
    return date[0]

# see lines 4029-4031 in calendrica-3.0.cl
def bahai_cycle(date):
    """Return 'cycle' element of a  Bahai date, date."""
    return date[1]

# see lines 4033-4035 in calendrica-3.0.cl
def bahai_year(date):
    """Return 'year' element of a  Bahai date, date."""
    return date[2]

# see lines 4037-4039 in calendrica-3.0.cl
def bahai_month(date):
    """Return 'month' element of a  Bahai date, date."""
    return date[3]

# see lines 4041-4043 in calendrica-3.0.cl
def bahai_day(date):
    """Return 'day' element of a  Bahai date, date."""
    return date[4]

# see lines 4045-4048 in calendrica-3.0.cl
BAHAI_EPOCH = fixed_from_gregorian(gregorian_date(1844, MARCH, 21))

# see lines 4050-4053 in calendrica-3.0.cl
AYYAM_I_HA = 0

# see lines 4055-4076 in calendrica-3.0.cl
def fixed_from_bahai(b_date):
    """Return fixed date equivalent to the Bahai date, b_date."""
    major = bahai_major(b_date)
    cycle = bahai_cycle(b_date)
    year  = bahai_year(b_date)
    month = bahai_month(b_date)
    day   = bahai_day(b_date)
    g_year = (361 * (major - 1) +
              19 * (cycle - 1)  +
              year - 1 +
              gregorian_year_from_fixed(BAHAI_EPOCH))
    if (month == AYYAM_I_HA):
        elapsed_months = 342
    elif (month == 19):
        if (is_gregorian_leap_year(g_year + 1)):
            elapsed_months = 347
        else:
            elapsed_months = 346
    else:
        elapsed_months = 19 * (month - 1)

    return (fixed_from_gregorian(gregorian_date(g_year, MARCH, 20)) +
            elapsed_months +
            day)

# see lines 4078-4111 in calendrica-3.0.cl
def bahai_from_fixed(date):
    """Return Bahai date [major, cycle, year, month, day] corresponding
    to fixed date, date."""
    g_year = gregorian_year_from_fixed(date)
    start  = gregorian_year_from_fixed(BAHAI_EPOCH)
    years  = (g_year - start -
              (1 if (date <= fixed_from_gregorian(
                  gregorian_date(g_year, MARCH, 20))) else 0))
    major  = 1 + quotient(years, 361)
    cycle  = 1 + quotient(mod(years, 361), 19)
    year   = 1 + mod(years, 19)
    days   = date - fixed_from_bahai(bahai_date(major, cycle, year, 1, 1))

    # month
    if (date >= fixed_from_bahai(bahai_date(major, cycle, year, 19, 1))):
        month = 19
    elif (date >= fixed_from_bahai(
        bahai_date(major, cycle, year, AYYAM_I_HA, 1))):
        month = AYYAM_I_HA
    else:
        month = 1 + quotient(days, 19)

    day = date + 1 - fixed_from_bahai(bahai_date(major, cycle, year, month, 1))

    return bahai_date(major, cycle, year, month, day)


# see lines 4113-4117 in calendrica-3.0.cl
def bahai_new_year(g_year):
    """Return fixed date of Bahai New Year in Gregorian year, g_year."""
    return fixed_from_gregorian(gregorian_date(g_year, MARCH, 21))

# see lines 4119-4122 in calendrica-3.0.cl
HAIFA = location(deg(mpf(32.82)), deg(35), mt(0), hr(2))


# see lines 4124-4130 in calendrica-3.0.cl
def sunset_in_haifa(date):
    """Return universal time of sunset of evening
    before fixed date, date in Haifa."""
    return universal_from_standard(sunset(date, HAIFA), HAIFA)

# see lines 4132-4141 in calendrica-3.0.cl
def future_bahai_new_year_on_or_before(date):
    """Return fixed date of Future Bahai New Year on or
    before fixed date, date."""
    approx = estimate_prior_solar_longitude(SPRING, sunset_in_haifa(date))
    return next_of(ifloor(approx) - 1,
                lambda day: (solar_longitude(sunset_in_haifa(day)) <=
                             (SPRING + deg(2))))

# see lines 4143-4173 in calendrica-3.0.cl
def fixed_from_future_bahai(b_date):
    """Return fixed date of Bahai date, b_date."""
    major = bahai_major(b_date)
    cycle = bahai_cycle(b_date)
    year  = bahai_year(b_date)
    month = bahai_month(b_date)
    day   = bahai_day(b_date)
    years = (361 * (major - 1)) + (19 * (cycle - 1)) + year
    if (month == 19):
        return (future_bahai_new_year_on_or_before(
            BAHAI_EPOCH +
            ifloor(MEAN_TROPICAL_YEAR * (years + 1/2))) -
                20 + day)
    elif (month == AYYAM_I_HA):
        return (future_bahai_new_year_on_or_before(
            BAHAI_EPOCH +
            ifloor(MEAN_TROPICAL_YEAR * (years - 1/2))) +
                341 + day)
    else:
        return (future_bahai_new_year_on_or_before(
            BAHAI_EPOCH +
            ifloor(MEAN_TROPICAL_YEAR * (years - 1/2))) +
                (19 * (month - 1)) + day - 1)


# see lines 4175-4201 in calendrica-3.0.cl
def future_bahai_from_fixed(date):
    """Return Future Bahai date corresponding to fixed date, date."""
    new_year = future_bahai_new_year_on_or_before(date)
    years    = iround((new_year - BAHAI_EPOCH) / MEAN_TROPICAL_YEAR)
    major    = 1 + quotient(years, 361)
    cycle    = 1 + quotient(mod(years, 361), 19)
    year     = 1 + mod(years, 19)
    days     = date - new_year

    if (date >= fixed_from_future_bahai(bahai_date(major, cycle, year, 19, 1))):
        month = 19
    elif(date >= fixed_from_future_bahai(
        bahai_date(major, cycle, year, AYYAM_I_HA, 1))):
        month = AYYAM_I_HA
    else:
        month = 1 + quotient(days, 19)

    day  = date + 1 - fixed_from_future_bahai(
        bahai_date(major, cycle, year, month, 1))

    return bahai_date(major, cycle, year, month, day)


# see lines 4203-4213 in calendrica-3.0.cl
def feast_of_ridvan(g_year):
    """Return Fixed date of Feast of Ridvan in Gregorian year year, g_year."""
    years = g_year - gregorian_year_from_fixed(BAHAI_EPOCH)
    major = 1 + quotient(years, 361)
    cycle = 1 + quotient(mod(years, 361), 19)
    year = 1 + mod(years, 19)
    return fixed_from_future_bahai(bahai_date(major, cycle, year, 2, 13))

