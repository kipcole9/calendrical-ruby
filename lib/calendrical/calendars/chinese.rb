###############################
# chinese calendar algorithms #
###############################
# see lines 4330-4333 in calendrica-3.0.cl
def chinese_date(cycle, year, month, leap, day):
    """Return a Chinese date data structure."""
    return [cycle, year, month, leap, day]

# see lines 4335-4337 in calendrica-3.0.cl
def chinese_cycle(date):
    """Return 'cycle' element of a Chinese date, date."""
    return date[0]

# see lines 4339-4341 in calendrica-3.0.cl
def chinese_year(date):
    """Return 'year' element of a Chinese date, date."""
    return date[1]

# see lines 4343-4345 in calendrica-3.0.cl
def chinese_month(date):
    """Return 'month' element of a Chinese date, date."""
    return date[2]

# see lines 4347-4349 in calendrica-3.0.cl
def chinese_leap(date):
    """Return 'leap' element of a Chinese date, date."""
    return date[3]

# see lines 4351-4353 in calendrica-3.0.cl
def chinese_day(date):
    """Return 'day' element of a Chinese date, date."""
    return date[4]

# see lines 4355-4363 in calendrica-3.0.cl
def chinese_location(tee):
    """Return location of Beijing; time zone varies with time, tee."""
    year = gregorian_year_from_fixed(ifloor(tee))
    if (year < 1929):
        return location(angle(39, 55, 0), angle(116, 25, 0),
                        mt(43.5), hr(1397/180))
    else:
        return location(angle(39, 55, 0), angle(116, 25, 0),
                        mt(43.5), hr(8))


# see lines 4365-4377 in calendrica-3.0.cl
def chinese_solar_longitude_on_or_after(lam, date):
    """Return moment (Beijing time) of the first date on or after
    fixed date, date, (Beijing time) when the solar longitude
    will be 'lam' degrees."""
    tee = solar_longitude_after(lam,
                                universal_from_standard(date,
                                                        chinese_location(date)))
    return standard_from_universal(tee, chinese_location(tee))

# see lines 4379-4387 in calendrica-3.0.cl
def current_major_solar_term(date):
    """Return last Chinese major solar term (zhongqi) before
    fixed date, date."""
    s = solar_longitude(universal_from_standard(date,
                                                chinese_location(date)))
    return amod(2 + quotient(int(s), deg(30)), 12)

# see lines 4389-4397 in calendrica-3.0.cl
def major_solar_term_on_or_after(date):
    """Return moment (in Beijing) of the first Chinese major
    solar term (zhongqi) on or after fixed date, date.  The
    major terms begin when the sun's longitude is a
    multiple of 30 degrees."""
    s = solar_longitude(midnight_in_china(date))
    l = mod(30 * ceiling(s / 30), 360)
    return chinese_solar_longitude_on_or_after(l, date)

# see lines 4399-4407 in calendrica-3.0.cl
def current_minor_solar_term(date):
    """Return last Chinese minor solar term (jieqi) before date, date."""
    s = solar_longitude(universal_from_standard(date,
                                                chinese_location(date)))
    return amod(3 + quotient(s - deg(15), deg(30)), 12)

# see lines 4409-4422 in calendrica-3.0.cl
def minor_solar_term_on_or_after(date):
    """Return moment (in Beijing) of the first Chinese minor solar
    term (jieqi) on or after fixed date, date.  The minor terms
    begin when the sun's longitude is an odd multiple of 15 degrees."""
    s = solar_longitude(midnight_in_china(date))
    l = mod(30 * ceiling((s - deg(15)) / 30) + deg(15), 360)
    return chinese_solar_longitude_on_or_after(l, date)

# see lines 4424-4433 in calendrica-3.0.cl
def chinese_new_moon_before(date):
    """Return fixed date (Beijing) of first new moon before fixed date, date."""
    tee = new_moon_before(midnight_in_china(date))
    return ifloor(standard_from_universal(tee, chinese_location(tee)))

# see lines 4435-4444 in calendrica-3.0.cl
def chinese_new_moon_on_or_after(date):
    """Return fixed date (Beijing) of first new moon on or after
    fixed date, date."""
    tee = new_moon_at_or_after(midnight_in_china(date))
    return ifloor(standard_from_universal(tee, chinese_location(tee)))

# see lines 4446-4449 in calendrica-3.0.cl
CHINESE_EPOCH = fixed_from_gregorian(gregorian_date(-2636, FEBRUARY, 15))

# see lines 4451-4457 in calendrica-3.0.cl
def is_chinese_no_major_solar_term(date):
    """Return True if Chinese lunar month starting on date, date,
    has no major solar term."""
    return (current_major_solar_term(date) ==
            current_major_solar_term(chinese_new_moon_on_or_after(date + 1)))

# see lines 4459-4463 in calendrica-3.0.cl
def midnight_in_china(date):
    """Return Universal time of (clock) midnight at start of fixed
    date, date, in China."""
    return universal_from_standard(date, chinese_location(date))

# see lines 4465-4474 in calendrica-3.0.cl
def chinese_winter_solstice_on_or_before(date):
    """Return fixed date, in the Chinese zone, of winter solstice
    on or before fixed date, date."""
    approx = estimate_prior_solar_longitude(WINTER,
                                            midnight_in_china(date + 1))
    return next_of(ifloor(approx) - 1,
                lambda day: WINTER < solar_longitude(
                    midnight_in_china(1 + day)))

# see lines 4476-4500 in calendrica-3.0.cl
def chinese_new_year_in_sui(date):
    """Return fixed date of Chinese New Year in sui (period from
    solstice to solstice) containing date, date."""
    s1 = chinese_winter_solstice_on_or_before(date)
    s2 = chinese_winter_solstice_on_or_before(s1 + 370)
    next_m11 = chinese_new_moon_before(1 + s2)
    m12 = chinese_new_moon_on_or_after(1 + s1)
    m13 = chinese_new_moon_on_or_after(1 + m12)
    leap_year = iround((next_m11 - m12) / MEAN_SYNODIC_MONTH) == 12

    if (leap_year and
        (is_chinese_no_major_solar_term(m12) or is_chinese_no_major_solar_term(m13))):
        return chinese_new_moon_on_or_after(1 + m13)
    else:
        return m13


# see lines 4502-4511 in calendrica-3.0.cl
def chinese_new_year_on_or_before(date):
    """Return fixed date of Chinese New Year on or before fixed date, date."""
    new_year = chinese_new_year_in_sui(date)
    if (date >= new_year):
        return new_year
    else:
        return chinese_new_year_in_sui(date - 180)

# see lines 4513-4518 in calendrica-3.0.cl
def chinese_new_year(g_year):
    """Return fixed date of Chinese New Year in Gregorian year, g_year."""
    return chinese_new_year_on_or_before(
        fixed_from_gregorian(gregorian_date(g_year, JULY, 1)))

# see lines 4520-4565 in calendrica-3.0.cl
def chinese_from_fixed(date):
    """Return Chinese date (cycle year month leap day) of fixed date, date."""
    s1 = chinese_winter_solstice_on_or_before(date)
    s2 = chinese_winter_solstice_on_or_before(s1 + 370)
    next_m11 = chinese_new_moon_before(1 + s2)
    m12 = chinese_new_moon_on_or_after(1 + s1)
    leap_year = iround((next_m11 - m12) / MEAN_SYNODIC_MONTH) == 12

    m = chinese_new_moon_before(1 + date)
    month = amod(iround((m - m12) / MEAN_SYNODIC_MONTH) -
                  (1 if (leap_year and
                         is_chinese_prior_leap_month(m12, m)) else 0),
                  12)
    leap_month = (leap_year and
                  is_chinese_no_major_solar_term(m) and
                  (not is_chinese_prior_leap_month(m12,
                                                chinese_new_moon_before(m))))
    elapsed_years = (ifloor(mpf(1.5) -
                           (month / 12) +
                           ((date - CHINESE_EPOCH) / MEAN_TROPICAL_YEAR)))
    cycle = 1 + quotient(elapsed_years - 1, 60)
    year = amod(elapsed_years, 60)
    day = 1 + (date - m)
    return chinese_date(cycle, year, month, leap_month, day)



# see lines 4567-4596 in calendrica-3.0.cl
def fixed_from_chinese(c_date):
    """Return fixed date of Chinese date, c_date."""
    cycle = chinese_cycle(c_date)
    year  = chinese_year(c_date)
    month = chinese_month(c_date)
    leap  = chinese_leap(c_date)
    day   = chinese_day(c_date)
    mid_year = ifloor(CHINESE_EPOCH +
                      ((((cycle - 1) * 60) + (year - 1) + 1/2) *
                       MEAN_TROPICAL_YEAR))
    new_year = chinese_new_year_on_or_before(mid_year)
    p = chinese_new_moon_on_or_after(new_year + ((month - 1) * 29))
    d = chinese_from_fixed(p)
    prior_new_moon = (p if ((month == chinese_month(d)) and
                            (leap == chinese_leap(d)))
                        else chinese_new_moon_on_or_after(1 + p))
    return prior_new_moon + day - 1


# see lines 4598-4607 in calendrica-3.0.cl
def is_chinese_prior_leap_month(m_prime, m):
    """Return True if there is a Chinese leap month on or after lunar
    month starting on fixed day, m_prime and at or before
    lunar month starting at fixed date, m."""
    return ((m >= m_prime) and
            (is_chinese_no_major_solar_term(m) or
             is_chinese_prior_leap_month(m_prime, chinese_new_moon_before(m))))


# see lines 4609-4615 in calendrica-3.0.cl
def chinese_name(stem, branch):
    """Return BOGUS if stem/branch combination is impossible."""
    if (mod(stem, 2) == mod(branch, 2)):
        return [stem, branch]
    else:
        return BOGUS


# see lines 4617-4619 in calendrica-3.0.cl
def chinese_stem(name):
    return name[0]


# see lines 4621-4623 in calendrica-3.0.cl
def chinese_branch(name):
    return name[1]

# see lines 4625-4629 in calendrica-3.0.cl
def chinese_sexagesimal_name(n):
    """Return the n_th name of the Chinese sexagesimal cycle."""
    return chinese_name(amod(n, 10), amod(n, 12))


# see lines 4631-4644 in calendrica-3.0.cl
def chinese_name_difference(c_name1, c_name2):
    """Return the number of names from Chinese name c_name1 to the
    next occurrence of Chinese name c_name2."""
    stem1 = chinese_stem(c_name1)
    stem2 = chinese_stem(c_name2)
    branch1 = chinese_branch(c_name1)
    branch2 = chinese_branch(c_name2)
    stem_difference   = stem2 - stem1
    branch_difference = branch2 - branch1
    return 1 + mod(stem_difference - 1 +
                   25 * (branch_difference - stem_difference), 60)


# see lines 4646-4649 in calendrica-3.0.cl
# see lines 214-215 in calendrica-3.0.errata.cl
def chinese_year_name(year):
    """Return sexagesimal name for Chinese year, year, of any cycle."""
    return chinese_sexagesimal_name(year)


# see lines 4651-4655 in calendrica-3.0.cl
CHINESE_MONTH_NAME_EPOCH = 57

# see lines 4657-4664 in calendrica-3.0.cl
# see lines 211-212 in calendrica-3.0.errata.cl
def chinese_month_name(month, year):
    """Return sexagesimal name for month, month, of Chinese year, year."""
    elapsed_months = (12 * (year - 1)) + (month - 1)
    return chinese_sexagesimal_name(elapsed_months - CHINESE_MONTH_NAME_EPOCH)

# see lines 4666-4669 in calendrica-3.0.cl
CHINESE_DAY_NAME_EPOCH = rd(45)

# see lines 4671-4675 in calendrica-3.0.cl
# see lines 208-209 in calendrica-3.0.errata.cl
def chinese_day_name(date):
    """Return Chinese sexagesimal name for date, date."""
    return chinese_sexagesimal_name(date - CHINESE_DAY_NAME_EPOCH)


# see lines 4677-4687 in calendrica-3.0.cl
def chinese_day_name_on_or_before(name, date):
    """Return fixed date of latest date on or before fixed date, date, that
    has Chinese name, name."""
    return (date -
            mod(date +
                chinese_name_difference(name,
                            chinese_sexagesimal_name(CHINESE_DAY_NAME_EPOCH)),
                60))


# see lines 4689-4699 in calendrica-3.0.cl
def dragon_festival(g_year):
    """Return fixed date of the Dragon Festival occurring in Gregorian
    year g_year."""
    elapsed_years = 1 + g_year - gregorian_year_from_fixed(CHINESE_EPOCH)
    cycle = 1 + quotient(elapsed_years - 1, 60)
    year = amod(elapsed_years, 60)
    return fixed_from_chinese(chinese_date, cycle, year, 5, false, 5)


# see lines 4701-4708 in calendrica-3.0.cl
def qing_ming(g_year):
    """Return fixed date of Qingming occurring in Gregorian year, g_year."""
    return ifloor(minor_solar_term_on_or_after(
        fixed_from_gregorian(gregorian_date(g_year, MARCH, 30))))


# see lines 4710-4722 in calendrica-3.0.cl
def chinese_age(birthdate, date):
    """Return the age at fixed date, date, given Chinese birthdate, birthdate,
    according to the Chinese custom.
    Returns BOGUS if date is before birthdate."""
    today = chinese_from_fixed(date)
    if (date >= fixed_from_chinese(birthdate)):
        return (60 * (chinese_cycle(today) - chinese_cycle(birthdate)) +
                (chinese_year(today) -  chinese_year(birthdate)) + 1)
    else:
        return BOGUS


# see lines 4724-4758 in calendrica-3.0.cl
def chinese_year_marriage_augury(cycle, year):
    """Return the marriage augury type of Chinese year, year in cycle, cycle.
    0 means lichun does not occur (widow or double-blind years),
    1 means it occurs once at the end (blind),
    2 means it occurs once at the start (bright), and
    3 means it occurs twice (double-bright or double-happiness)."""
    new_year = fixed_from_chinese(chinese_date(cycle, year, 1, False, 1))
    c = (cycle + 1) if (year == 60) else cycle
    y = 1 if (year == 60) else (year + 1)
    next_new_year = fixed_from_chinese(chinese_date(c, y, 1, False, 1))
    first_minor_term = current_minor_solar_term(new_year)
    next_first_minor_term = current_minor_solar_term(next_new_year)
    if ((first_minor_term == 1) and (next_first_minor_term == 12)):
        res = 0
    elif ((first_minor_term == 1) and (next_first_minor_term != 12)):
        res = 1
    elif ((first_minor_term != 1) and (next_first_minor_term == 12)):
        res = 2
    else:
        res = 3
    return res


# see lines 4760-4769 in calendrica-3.0.cl
def japanese_location(tee):
    """Return the location for Japanese calendar; varies with moment, tee."""
    year = gregorian_year_from_fixed(ifloor(tee))
    if (year < 1888):
        # Tokyo (139 deg 46 min east) local time
        loc = location(deg(mpf(35.7)), angle(139, 46, 0),
                           mt(24), hr(9 + 143/450))
    else:
        # Longitude 135 time zone
        loc = location(deg(35), deg(135), mt(0), hr(9))
    return loc


# see lines 4771-4795 in calendrica-3.0.cl
def korean_location(tee):
    """Return the location for Korean calendar; varies with moment, tee."""
    # Seoul city hall at a varying time zone.
    if (tee < fixed_from_gregorian(gregorian_date(1908, APRIL, 1))):
        #local mean time for longitude 126 deg 58 min
        z = 3809/450
    elif (tee < fixed_from_gregorian(gregorian_date(1912, JANUARY, 1))):
        z = 8.5
    elif (tee < fixed_from_gregorian(gregorian_date(1954, MARCH, 21))):
        z = 9
    elif (tee < fixed_from_gregorian(gregorian_date(1961, AUGUST, 10))):
        z = 8.5
    else:
        z = 9
    return location(angle(37, 34, 0), angle(126, 58, 0),
                    mt(0), hr(z))


# see lines 4797-4800 in calendrica-3.0.cl
def korean_year(cycle, year):
    """Return equivalent Korean year to Chinese cycle, cycle, and year, year."""
    return (60 * cycle) + year - 364


# see lines 4802-4811 in calendrica-3.0.cl
def vietnamese_location(tee):
    """Return the location for Vietnamese calendar is Hanoi;
    varies with moment, tee. Time zone has changed over the years."""
    if (tee < gregorian_new_year(1968)):
        z = 8
    else:
        z =7
        return location(angle(21, 2, 0), angle(105, 51, 0),
                        mt(12), hr(z))

