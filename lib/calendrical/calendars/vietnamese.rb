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

