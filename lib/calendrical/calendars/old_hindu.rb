##################################
# old hindu calendars algorithms #
##################################
# see lines 2321-2325 in calendrica-3.0.cl
def old_hindu_lunar_date(year, month, leap, day):
    """Return an Old Hindu lunar date data structure."""
    return [year, month, leap, day]

# see lines 2327-2329 in calendrica-3.0.cl
def old_hindu_lunar_month(date):
    """Return the month field of an Old Hindu lunar
    date = [year, month, leap, day]."""
    return date[1]

# see lines 2331-2333 in calendrica-3.0.cl
def old_hindu_lunar_leap(date):
    """Return the leap field of an Old Hindu lunar
    date = [year, month, leap, day]."""
    return date[2]

# see lines 2335-2337 in calendrica-3.0.cl
def old_hindu_lunar_day(date):
    """Return the day field of an Old Hindu lunar
    date = [year, month, leap, day]."""
    return date[3]

# see lines 2339-2341 in calendrica-3.0.cl
def old_hindu_lunar_year(date):
    """Return the year field of an Old Hindu lunar
    date = [year, month, leap, day]."""
    return date[0]

# see lines 2343-2346 in calendrica-3.0.cl
def hindu_solar_date(year, month, day):
    """Return an Hindu solar date data structure."""
    return [year, month, day]

# see lines 2348-2351 in calendrica-3.0.cl
HINDU_EPOCH = fixed_from_julian(julian_date(bce(3102), FEBRUARY, 18))

# see lines 2353-2356 in calendrica-3.0.cl
def hindu_day_count(date):
    """Return elapsed days (Ahargana) to date date since Hindu epoch (KY)."""
    return date - HINDU_EPOCH


# see lines 2358-2361 in calendrica-3.0.cl
ARYA_SOLAR_YEAR = 1577917500/4320000

# see lines 2363-2366 in calendrica-3.0.cl
ARYA_SOLAR_MONTH = ARYA_SOLAR_YEAR / 12

# see lines 2368-2378 in calendrica-3.0.cl
def old_hindu_solar_from_fixed(date):
    """Return Old Hindu solar date equivalent to fixed date date."""
    sun   = hindu_day_count(date) + hr(6)
    year  = quotient(sun, ARYA_SOLAR_YEAR)
    month = mod(quotient(sun, ARYA_SOLAR_MONTH), 12) + 1
    day   = ifloor(mod(sun, ARYA_SOLAR_MONTH)) + 1
    return hindu_solar_date(year, month, day)

# see lines 2380-2390 in calendrica-3.0.cl
# The following
#      from math import ceil as ceiling
# is not ok, the corresponding CL code
# uses CL ceiling which always returns and integer, while
# ceil from math module always returns a float...so I redefine it
def ceiling(n):
    """Return the integer rounded towards +infinitum of n."""
    from math import ceil
    return int(ceil(n))

def fixed_from_old_hindu_solar(s_date):
    """Return fixed date corresponding to Old Hindu solar date s_date."""
    month = standard_month(s_date)
    day   = standard_day(s_date)
    year  = standard_year(s_date)
    return ceiling(HINDU_EPOCH                 +
                year * ARYA_SOLAR_YEAR         +
                (month - 1) * ARYA_SOLAR_MONTH +
                day + hr(-30))

# see lines 2392-2395 in calendrica-3.0.cl
ARYA_LUNAR_MONTH = 1577917500/53433336

# see lines 2397-2400 in calendrica-3.0.cl
ARYA_LUNAR_DAY =  ARYA_LUNAR_MONTH / 30

# see lines 2402-2409 in calendrica-3.0.cl
def is_old_hindu_lunar_leap_year(l_year):
    """Return True if l_year is a leap year on the
    old Hindu calendar."""
    return mod(l_year * ARYA_SOLAR_YEAR - ARYA_SOLAR_MONTH,
               ARYA_LUNAR_MONTH) >= 23902504679/1282400064

# see lines 2411-2431 in calendrica-3.0.cl
def old_hindu_lunar_from_fixed(date):
    """Return Old Hindu lunar date equivalent to fixed date date."""
    sun = hindu_day_count(date) + hr(6)
    new_moon = sun - mod(sun, ARYA_LUNAR_MONTH)
    leap = (((ARYA_SOLAR_MONTH - ARYA_LUNAR_MONTH)
             >=
             mod(new_moon, ARYA_SOLAR_MONTH))
            and
            (mod(new_moon, ARYA_SOLAR_MONTH) > 0))
    month = mod(ceiling(new_moon / ARYA_SOLAR_MONTH), 12) + 1
    day = mod(quotient(sun, ARYA_LUNAR_DAY), 30) + 1
    year = ceiling((new_moon + ARYA_SOLAR_MONTH) / ARYA_SOLAR_YEAR) - 1
    return old_hindu_lunar_date(year, month, leap, day)

# see lines 2433-2460 in calendrica-3.0.cl
def fixed_from_old_hindu_lunar(l_date):
    """Return fixed date corresponding to Old Hindu lunar date l_date."""
    year  = old_hindu_lunar_year(l_date)
    month = old_hindu_lunar_month(l_date)
    leap  = old_hindu_lunar_leap(l_date)
    day   = old_hindu_lunar_day(l_date)
    mina  = ((12 * year) - 1) * ARYA_SOLAR_MONTH
    lunar_new_year = ARYA_LUNAR_MONTH * (quotient(mina, ARYA_LUNAR_MONTH) + 1)

    if ((not leap) and 
        (ceiling((lunar_new_year - mina) / (ARYA_SOLAR_MONTH - ARYA_LUNAR_MONTH))
         <= month)):
        temp = month
    else:
        temp = month - 1
    temp = (HINDU_EPOCH    + 
            lunar_new_year +
            (ARYA_LUNAR_MONTH * temp) +
            ((day - 1) * ARYA_LUNAR_DAY) +
            hr(-6))
    return ceiling(temp)

# see lines 2462-2466 in calendrica-3.0.cl
ARYA_JOVIAN_PERIOD =  1577917500/364224

# see lines 2468-2473 in calendrica-3.0.cl
def jovian_year(date):
    """Return year of Jupiter cycle at fixed date date."""
    return amod(quotient(hindu_day_count(date), ARYA_JOVIAN_PERIOD / 12) + 27,
                60)
