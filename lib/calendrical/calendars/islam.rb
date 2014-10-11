###############################
# islamic calendar algorithms #
###############################
# see lines 1436-1439 in calendrica-3.0.cl
def islamic_date(year, month, day):
    """Return an Islamic date data structure."""
    return [year, month, day]

# see lines 1441-1444 in calendrica-3.0.cl
ISLAMIC_EPOCH = fixed_from_julian(julian_date(ce(622), JULY, 16))

# see lines 1446-1449 in calendrica-3.0.cl
def is_islamic_leap_year(i_year):
    """Return True if i_year is an Islamic leap year."""
    return mod(14 + 11 * i_year, 30) < 11

# see lines 1451-1463 in calendrica-3.0.cl
def fixed_from_islamic(i_date):
    """Return fixed date equivalent to Islamic date i_date."""
    month = standard_month(i_date)
    day   = standard_day(i_date)
    year  = standard_year(i_date)
    return (ISLAMIC_EPOCH - 1 +
            (year - 1) * 354  +
            quotient(3 + 11 * year, 30) +
            29 * (month - 1) +
            quotient(month, 2) +
            day)

# see lines 1465-1483 in calendrica-3.0.cl
def islamic_from_fixed(date):
    """Return Islamic date (year month day) corresponding to fixed date date."""
    year       = quotient(30 * (date - ISLAMIC_EPOCH) + 10646, 10631)
    prior_days = date - fixed_from_islamic(islamic_date(year, 1, 1))
    month      = quotient(11 * prior_days + 330, 325)
    day        = date - fixed_from_islamic(islamic_date(year, month, 1)) + 1
    return islamic_date(year, month, day)

# see lines 1485-1501 in calendrica-3.0.cl
def islamic_in_gregorian(i_month, i_day, g_year):
    """Return list of the fixed dates of Islamic month i_month, day i_day that
    occur in Gregorian year g_year."""
    jan1  = gregorian_new_year(g_year)
    y     = standard_year(islamic_from_fixed(jan1))
    date1 = fixed_from_islamic(islamic_date(y, i_month, i_day))
    date2 = fixed_from_islamic(islamic_date(y + 1, i_month, i_day))
    date3 = fixed_from_islamic(islamic_date(y + 2, i_month, i_day))
    return list_range([date1, date2, date3], gregorian_year_range(g_year))

# see lines 1503-1507 in calendrica-3.0.cl
def mawlid_an_nabi(g_year):
    """Return list of fixed dates of Mawlid_an_Nabi occurring in Gregorian
    year g_year."""
    return islamic_in_gregorian(3, 12, g_year)

    ###########################################
    # astronomical lunar calendars algorithms #
    ###########################################
    # see lines 5829-5845 in calendrica-3.0.cl
    # Return S. K. Shaukat's criterion for likely
    # visibility of crescent moon on eve of date 'date',
    # at location 'location'.
    def visible_crescent(date, location):
      tee = universal_from_standard(dusk(date - 1, location, mpf(4.5).degrees),
                                    location)
      phase = lunar_phase(tee)
      altitude = lunar_altitude(tee, location)
      arc_of_light = arccos_degrees(cosine_degrees(lunar_latitude(tee)) *
                                    cosine_degrees(phase))
      return ((NEW_MOON < phase < FIRST_QUARTER) &&
              (mpf(10.6).degrees <= arc_of_light <= 90.degrees) &&
              (altitude > mpf(4.1).degrees))
    end

    # see lines 5847-5860 in calendrica-3.0.cl
    # Return the closest fixed date on or before date 'date', when crescent
    # moon first became visible at location 'location'.
    def phasis_on_or_before(date, location):
      mean = date - ifloor(lunar_phase(date + 1) / deg(360) *
                           MEAN_SYNODIC_MONTH)
      tau = ((mean - 30)
             if (((date - mean) <= 3) and (not visible_crescent(date, location)))
             else (mean - 2))
      return  next_of(tau, lambda d: visible_crescent(d, location))
    end

    # see lines 5862-5866 in calendrica-3.0.cl
    # see lines 220-221 in calendrica-3.0.errata.cl
    # Sample location for Observational Islamic calendar
    # (Cairo, Egypt).
    ISLAMIC_LOCATION = location(deg(mpf(30.1)), deg(mpf(31.3)), mt(200), hr(2))

    # see lines 5868-5882 in calendrica-3.0.cl
    # Return fixed date equivalent to Observational Islamic date, i_date."""
    def fixed_from_observational_islamic(i_date):
      month    = standard_month(i_date)
      day      = standard_day(i_date)
      year     = standard_year(i_date)
      midmonth = ISLAMIC_EPOCH + ifloor((((year - 1) * 12) + month - 0.5) *
                                        MEAN_SYNODIC_MONTH)
      return (phasis_on_or_before(midmonth, ISLAMIC_LOCATION) +
              day - 1)
    end

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

