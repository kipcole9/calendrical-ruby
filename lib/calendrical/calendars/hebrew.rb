##############################
# hebrew calendar algorithms #
##############################
# see lines 1512-1514 in calendrica-3.0.cl
def hebrew_date(year, month, day):
    """Return an Hebrew date data structure."""
    return [year, month, day]

# see lines 1516-1519 in calendrica-3.0.cl
NISAN = 1

# see lines 1521-1524 in calendrica-3.0.cl
IYYAR = 2

# see lines 1526-1529 in calendrica-3.0.cl
SIVAN = 3

# see lines 1531-1534 in calendrica-3.0.cl
TAMMUZ = 4

# see lines 1536-1539 in calendrica-3.0.cl
AV = 5

# see lines 1541-1544 in calendrica-3.0.cl
ELUL = 6

# see lines 1546-1549 in calendrica-3.0.cl
TISHRI = 7

# see lines 1551-1554 in calendrica-3.0.cl
MARHESHVAN = 8

# see lines 1556-1559 in calendrica-3.0.cl
KISLEV = 9

# see lines 1561-1564 in calendrica-3.0.cl
TEVET = 10

# see lines 1566-1569 in calendrica-3.0.cl
SHEVAT = 11

# see lines 1571-1574 in calendrica-3.0.cl
ADAR = 12

# see lines 1576-1579 in calendrica-3.0.cl
ADARII = 13

# see lines 1581-1585 in calendrica-3.0.cl
HEBREW_EPOCH = fixed_from_julian(julian_date(bce(3761),  OCTOBER, 7))

# see lines 1587-1590 in calendrica-3.0.cl
def is_hebrew_leap_year(h_year):
    """Return True if h_year is a leap year on Hebrew calendar."""
    return mod(7 * h_year + 1, 19) < 7

# see lines 1592-1597 in calendrica-3.0.cl
def last_month_of_hebrew_year(h_year):
    """Return last month of Hebrew year."""
    return ADARII if is_hebrew_leap_year(h_year) else ADAR

# see lines 1599-1603 in calendrica-3.0.cl
def is_hebrew_sabbatical_year(h_year):
    """Return True if h_year is a sabbatical year on the Hebrew calendar."""
    return mod(h_year, 7) == 0

# see lines 1605-1617 in calendrica-3.0.cl
def last_day_of_hebrew_month(h_month, h_year):
    """Return last day of month h_month in Hebrew year h_year."""
    if ((h_month in [IYYAR, TAMMUZ, ELUL, TEVET, ADARII])
        or ((h_month == ADAR) and (not is_hebrew_leap_year(h_year)))
        or ((h_month == MARHESHVAN) and (not is_long_marheshvan(h_year)))
        or ((h_month == KISLEV) and is_short_kislev(h_year))):
        return 29
    else:
        return 30

# see lines 1619-1634 in calendrica-3.0.cl
def molad(h_month, h_year):
    """Return moment of mean conjunction of h_month in Hebrew h_year."""
    y = (h_year + 1) if (h_month < TISHRI) else h_year
    months_elapsed = h_month - TISHRI + quotient(235 * y - 234, 19)
    return (HEBREW_EPOCH -
           876/25920 +
           months_elapsed * (29 + hr(12) + 793/25920))

# see lines 1636-1663 in calendrica-3.0.cl
def hebrew_calendar_elapsed_days(h_year):
    """Return number of days elapsed from the (Sunday) noon prior
    to the epoch of the Hebrew calendar to the mean
    conjunction (molad) of Tishri of Hebrew year h_year,
    or one day later."""
    months_elapsed = quotient(235 * h_year - 234, 19)
    parts_elapsed  = 12084 + 13753 * months_elapsed
    days = 29 * months_elapsed + quotient(parts_elapsed, 25920)
    return   (days + 1) if (mod(3 * (days + 1), 7) < 3) else days

# see lines 1665-1670 in calendrica-3.0.cl
def hebrew_new_year(h_year):
    """Return fixed date of Hebrew new year h_year."""
    return (HEBREW_EPOCH +
           hebrew_calendar_elapsed_days(h_year) +
           hebrew_year_length_correction(h_year))

# see lines 1672-1684 in calendrica-3.0.cl
def hebrew_year_length_correction(h_year):
    """Return delays to start of Hebrew year h_year to keep ordinary
    year in range 353-356 and leap year in range 383-386."""
    # I had a bug... h_year = 1 instead of h_year - 1!!!
    ny0 = hebrew_calendar_elapsed_days(h_year - 1)
    ny1 = hebrew_calendar_elapsed_days(h_year)
    ny2 = hebrew_calendar_elapsed_days(h_year + 1)
    if ((ny2 - ny1) == 356):
        return 2
    elif ((ny1 - ny0) == 382):
        return 1
    else:
        return 0

# see lines 1686-1690 in calendrica-3.0.cl
def days_in_hebrew_year(h_year):
    """Return number of days in Hebrew year h_year."""
    return hebrew_new_year(h_year + 1) - hebrew_new_year(h_year)

# see lines 1692-1695 in calendrica-3.0.cl
def is_long_marheshvan(h_year):
    """Return True if Marheshvan is long in Hebrew year h_year."""
    return days_in_hebrew_year(h_year) in [355, 385]

# see lines 1697-1700 in calendrica-3.0.cl
def is_short_kislev(h_year):
    """Return True if Kislev is short in Hebrew year h_year."""
    return days_in_hebrew_year(h_year) in [353, 383]

# see lines 1702-1721 in calendrica-3.0.cl
def fixed_from_hebrew(h_date):
    """Return fixed date of Hebrew date h_date."""
    month = standard_month(h_date)
    day   = standard_day(h_date)
    year  = standard_year(h_date)

    if (month < TISHRI):
        tmp = (summa(lambda m: last_day_of_hebrew_month(m, year),
                     TISHRI,
                     lambda m: m <= last_month_of_hebrew_year(year)) +
               summa(lambda m: last_day_of_hebrew_month(m, year),
                     NISAN,
                     lambda m: m < month))
    else:
        tmp = summa(lambda m: last_day_of_hebrew_month(m, year),
                    TISHRI,
                    lambda m: m < month)

    return hebrew_new_year(year) + day - 1 + tmp

# see lines 1723-1751 in calendrica-3.0.cl
def hebrew_from_fixed(date):
    """Return  Hebrew (year month day) corresponding to fixed date date.
    # The fraction can be approximated by 365.25."""
    approx = quotient(date - HEBREW_EPOCH, 35975351/98496) + 1
    year = final(approx - 1, lambda y: hebrew_new_year(y) <= date)
    start = (TISHRI
             if (date < fixed_from_hebrew(hebrew_date(year, NISAN, 1)))
             else  NISAN)
    month = next(start, lambda m: date <= fixed_from_hebrew(
        hebrew_date(year, m, last_day_of_hebrew_month(m, year))))
    day = date - fixed_from_hebrew(hebrew_date(year, month, 1)) + 1
    return hebrew_date(year, month, day)

# see lines 1753-1761 in calendrica-3.0.cl
def yom_kippur(g_year):
    """Return fixed date of Yom Kippur occurring in Gregorian year g_year."""
    hebrew_year = g_year - gregorian_year_from_fixed(HEBREW_EPOCH) + 1
    return fixed_from_hebrew(hebrew_date(hebrew_year, TISHRI, 10))

# see lines 1763-1770 in calendrica-3.0.cl
def passover(g_year):
    """Return fixed date of Passover occurring in Gregorian year g_year."""
    hebrew_year = g_year - gregorian_year_from_fixed(HEBREW_EPOCH)
    return fixed_from_hebrew(hebrew_date(hebrew_year, NISAN, 15))

# see lines 1772-1782 in calendrica-3.0.cl
def omer(date):
    """Return the number of elapsed weeks and days in the omer at date date.
    Returns BOGUS if that date does not fall during the omer."""
    c = date - passover(gregorian_year_from_fixed(date))
    return [quotient(c, 7), mod(c, 7)] if (1 <= c <= 49) else BOGUS

# see lines 1784-1793 in calendrica-3.0.cl
def purim(g_year):
    """Return fixed date of Purim occurring in Gregorian year g_year."""
    hebrew_year = g_year - gregorian_year_from_fixed(HEBREW_EPOCH)
    last_month  = last_month_of_hebrew_year(hebrew_year)
    return fixed_from_hebrew(hebrew_date(hebrew_year(last_month, 14)))

# see lines 1795-1805 in calendrica-3.0.cl
def ta_anit_esther(g_year):
    """Return fixed date of Ta'anit Esther occurring in Gregorian
    year g_year."""
    purim_date = purim(g_year)
    return ((purim_date - 3)
            if (day_of_week_from_fixed(purim_date) == SUNDAY)
            else (purim_date - 1))

# see lines 1807-1821 in calendrica-3.0.cl
def tishah_be_av(g_year):
    """Return fixed date of Tishah be_Av occurring in Gregorian year g_year."""
    hebrew_year = g_year - gregorian_year_from_fixed(HEBREW_EPOCH)
    av9 = fixed_from_hebrew(hebrew_date(hebrew_year, AV, 9))
    return (av9 + 1) if (day_of_week_from_fixed(av9) == SATURDAY) else av9

# see lines 1823-1834 in calendrica-3.0.cl
def birkath_ha_hama(g_year):
    """Return the list of fixed date of Birkath ha_Hama occurring in
    Gregorian year g_year, if it occurs."""
    dates = coptic_in_gregorian(7, 30, g_year)
    return (dates
            if ((not (dates == [])) and
                (mod(standard_year(coptic_from_fixed(dates[0])), 28) == 17))
            else [])

# see lines 1836-1840 in calendrica-3.0.cl
def sh_ela(g_year):
    """Return the list of fixed dates of Sh'ela occurring in
    Gregorian year g_year."""
    return coptic_in_gregorian(3, 26, g_year)

# exercise for the reader from pag 104
def hebrew_in_gregorian(h_month, h_day, g_year):
    """Return list of the fixed dates of Hebrew month, h_month, day, h_day,
    that occur in Gregorian year g_year."""
    jan1  = gregorian_new_year(g_year)
    y     = standard_year(hebrew_from_fixed(jan1))
    date1 = fixed_from_hebrew(hebrew_date(y, h_month, h_day))
    date2 = fixed_from_hebrew(hebrew_date(y + 1, h_month, h_day))
    # Hebrew and Gregorian calendar are aligned but certain
    # holidays, i.e. Tzom Tevet, can fall on either side of Jan 1.
    # So we can have 0, 1 or 2 occurences of that holiday.
    dates = [date1, date2]
    return list_range(dates, gregorian_year_range(g_year))

# see pag 104
def tzom_tevet(g_year):
    """Return the list of fixed dates for Tzom Tevet (Tevet 10) that
    occur in Gregorian year g_year. It can occur 0, 1 or 2 times per
    Gregorian year."""
    jan1  = gregorian_new_year(g_year)
    y     = standard_year(hebrew_from_fixed(jan1))
    d1 = fixed_from_hebrew(hebrew_date(y, TEVET, 10))
    d1 = (d1 + 1) if (day_of_week_from_fixed(d1) == SATURDAY) else d1
    d2 = fixed_from_hebrew(hebrew_date(y + 1, TEVET, 10))
    d2 = (d2 + 1) if (day_of_week_from_fixed(d2) == SATURDAY) else d2
    dates = [d1, d2]
    return list_range(dates, gregorian_year_range(g_year))

# this is a simplified version where no check for SATURDAY
# is performed: from hebrew year 1 till 2000000
# there is no TEVET 10 falling on Saturday...
def alt_tzom_tevet(g_year):
    """Return the list of fixed dates for Tzom Tevet (Tevet 10) that
    occur in Gregorian year g_year. It can occur 0, 1 or 2 times per
    Gregorian year."""
    return hebrew_in_gregorian(TEVET, 10, g_year)

# see lines 1842-1859 in calendrica-3.0.cl
def yom_ha_zikkaron(g_year):
    """Return fixed date of Yom ha_Zikkaron occurring in Gregorian
    year g_year."""
    hebrew_year = g_year - gregorian_year_from_fixed(HEBREW_EPOCH)
    iyyar4 = fixed_from_hebrew(hebrew_date(hebrew_year, IYYAR, 4))
    
    if (day_of_week_from_fixed(iyyar4) in [THURSDAY, FRIDAY]):
        return kday_before(WEDNESDAY, iyyar4)
    elif (SUNDAY == day_of_week_from_fixed(iyyar4)):
        return iyyar4 + 1
    else:
        return iyyar4

# see lines 1861-1879 in calendrica-3.0.cl
def hebrew_birthday(birthdate, h_year):
    """Return fixed date of the anniversary of Hebrew birth date
    birthdate occurring in Hebrew h_year."""
    birth_day   = standard_day(birthdate)
    birth_month = standard_month(birthdate)
    birth_year  = standard_year(birthdate)
    if (birth_month == last_month_of_hebrew_year(birth_year)):
        return fixed_from_hebrew(hebrew_date(h_year,
                                             last_month_of_hebrew_year(h_year),
                                             birth_day))
    else:
        return (fixed_from_hebrew(hebrew_date(h_year, birth_month, 1)) +
                birth_day - 1)

# see lines 1881-1893 in calendrica-3.0.cl
def hebrew_birthday_in_gregorian(birthdate, g_year):
    """Return the list of the fixed dates of Hebrew birthday
    birthday that occur in Gregorian g_year."""
    jan1 = gregorian_new_year(g_year)
    y    = standard_year(hebrew_from_fixed(jan1))
    date1 = hebrew_birthday(birthdate, y)
    date2 = hebrew_birthday(birthdate, y + 1)
    return list_range([date1, date2], gregorian_year_range(g_year))

# see lines 1895-1937 in calendrica-3.0.cl
def yahrzeit(death_date, h_year):
    """Return fixed date of the anniversary of Hebrew death date death_date
    occurring in Hebrew h_year."""
    death_day   = standard_day(death_date)
    death_month = standard_month(death_date)
    death_year  = standard_year(death_date)

    if ((death_month == MARHESHVAN) and
        (death_day == 30) and
        (not is_long_marheshvan(death_year + 1))):
        return fixed_from_hebrew(hebrew_date(h_year, KISLEV, 1)) - 1
    elif ((death_month == KISLEV) and
          (death_day == 30) and
          is_short_kislev(death_year + 1)):
        return fixed_from_hebrew(hebrew_date(h_year, TEVET, 1)) - 1
    elif (death_month == ADARII):
        return fixed_from_hebrew(hebrew_date(h_year,
                                             last_month_of_hebrew_year(h_year),
                                             death_day))
    elif ((death_day == 30) and
          (death_month == ADAR) and
          (not is_hebrew_leap_year(h_year))):
        return fixed_from_hebrew(hebrew_date(h_year, SHEVAT, 30))
    else:
        return (fixed_from_hebrew(hebrew_date(h_year, death_month, 1)) +
                death_day - 1)

# see lines 1939-1951 in calendrica-3.0.cl
def yahrzeit_in_gregorian(death_date, g_year):
    """Return the list of the fixed dates of death date death_date (yahrzeit)
    that occur in Gregorian year g_year."""
    jan1 = gregorian_new_year(g_year)
    y    = standard_year(hebrew_from_fixed(jan1))
    date1 = yahrzeit(death_date, y)
    date2 = yahrzeit(death_date, y + 1)
    return list_range([date1, date2], gregorian_year_range(g_year))

# see lines 1953-1960 in calendrica-3.0.cl
def shift_days(l, cap_Delta):
    """Shift each weekday on list l by cap_Delta days."""
    return map(lambda x: day_of_week_from_fixed(x + cap_Delta), l)

# see lines 1962-1984 in calendrica-3.0.cl
def possible_hebrew_days(h_month, h_day):
    """Return a list of possible days of week for Hebrew day h_day
    and Hebrew month h_month."""
    h_date0 = hebrew_date(5, NISAN, 1)
    h_year  = 6 if (h_month > ELUL) else 5
    h_date  = hebrew_date(h_year, h_month, h_day)
    n       = fixed_from_hebrew(h_date) - fixed_from_hebrew(h_date0)
    tue_thu_sat = [TUESDAY, THURSDAY, SATURDAY]

    if (h_day == 30) and (h_month in [MARHESHVAN, KISLEV]):
        sun_wed_fri = []
    elif (h_month == KISLEV):
        sun_wed_fri = [SUNDAY, WEDNESDAY, FRIDAY]
    else:
        sun_wed_fri = [SUNDAY]

    mon = [MONDAY] if h_month in [KISLEV, TEVET, SHEVAT, ADAR] else [ ]

    ell = tue_thu_sat
    ell.extend(sun_wed_fri)
    ell.extend(mon)
    return shift_days(ell, n)

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