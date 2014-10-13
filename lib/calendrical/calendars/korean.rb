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
