

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