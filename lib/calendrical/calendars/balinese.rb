################################
# balinese calendar algorithms #
################################
# see lines 2478-2481 in calendrica-3.0.cl
def balinese_date(b1, b2, b3, b4, b5, b6, b7, b8, b9, b0):
    """Return a Balinese date data structure."""
    return [b1, b2, b3, b4, b5, b6, b7, b8, b9, b0]

# see lines 2483-2485 in calendrica-3.0.cl
def bali_luang(b_date):
    return b_date[0]

# see lines 2487-2489 in calendrica-3.0.cl
def bali_dwiwara(b_date):
    return b_date[1]

# see lines 2491-2493 in calendrica-3.0.cl
def bali_triwara(b_date):
    return b_date[2]

# see lines 2495-2497 in calendrica-3.0.cl
def bali_caturwara(b_date):
    return b_date[3]

# see lines 2499-2501 in calendrica-3.0.cl
def bali_pancawara(b_date):
    return b_date[4]

# see lines 2503-2505 in calendrica-3.0.cl
def bali_sadwara(b_date):
    return b_date[5]

# see lines 2507-2509 in calendrica-3.0.cl
def bali_saptawara(b_date):
    return b_date[6]

# see lines 2511-2513 in calendrica-3.0.cl
def bali_asatawara(b_date):
    return b_date[7]

# see lines 2513-2517 in calendrica-3.0.cl
def bali_sangawara(b_date):
    return b_date[8]

# see lines 2519-2521 in calendrica-3.0.cl
def bali_dasawara(b_date):
    return b_date[9]

# see lines 2523-2526 in calendrica-3.0.cl
BALI_EPOCH = fixed_from_jd(146)

# see lines 2528-2531 in calendrica-3.0.cl
def bali_day_from_fixed(date):
    """Return the position of date date in 210_day Pawukon cycle."""
    return mod(date - BALI_EPOCH, 210)

def even(i):
    return mod(i, 2) == 0

def odd(i):
    return not even(i)

# see lines 2533-2536 in calendrica-3.0.cl
def bali_luang_from_fixed(date):
    """Check membership of date date in "1_day" Balinese cycle."""
    return even(bali_dasawara_from_fixed(date))

# see lines 2538-2541 in calendrica-3.0.cl
def bali_dwiwara_from_fixed(date):
    """Return the position of date date in 2_day Balinese cycle."""
    return amod(bali_dasawara_from_fixed(date), 2)

# see lines 2543-2546 in calendrica-3.0.cl
def bali_triwara_from_fixed(date):
    """Return the position of date date in 3_day Balinese cycle."""
    return mod(bali_day_from_fixed(date), 3) + 1

# see lines 2548-2551 in calendrica-3.0.cl
def bali_caturwara_from_fixed(date):
    """Return the position of date date in 4_day Balinese cycle."""
    return amod(bali_asatawara_from_fixed(date), 4)

# see lines 2553-2556 in calendrica-3.0.cl
def bali_pancawara_from_fixed(date):
    """Return the position of date date in 5_day Balinese cycle."""
    return amod(bali_day_from_fixed(date) + 2, 5)

# see lines 2558-2561 in calendrica-3.0.cl
def bali_sadwara_from_fixed(date):
    """Return the position of date date in 6_day Balinese cycle."""
    return mod(bali_day_from_fixed(date), 6) + 1

# see lines 2563-2566 in calendrica-3.0.cl
def bali_saptawara_from_fixed(date):
    """Return the position of date date in Balinese week."""
    return mod(bali_day_from_fixed(date), 7) + 1

# see lines 2568-2576 in calendrica-3.0.cl
def bali_asatawara_from_fixed(date):
    """Return the position of date date in 8_day Balinese cycle."""
    day = bali_day_from_fixed(date)
    return mod(max(6, 4 + mod(day - 70, 210)), 8) + 1

# see lines 2578-2583 in calendrica-3.0.cl
def bali_sangawara_from_fixed(date):
    """Return the position of date date in 9_day Balinese cycle."""
    return mod(max(0, bali_day_from_fixed(date) - 3), 9) + 1

# see lines 2585-2594 in calendrica-3.0.cl
def bali_dasawara_from_fixed(date):
    """Return the position of date date in 10_day Balinese cycle."""
    i = bali_pancawara_from_fixed(date) - 1
    j = bali_saptawara_from_fixed(date) - 1
    return mod(1 + [5, 9, 7, 4, 8][i] + [5, 4, 3, 7, 8, 6, 9][j], 10)

# see lines 2596-2609 in calendrica-3.0.cl
def bali_pawukon_from_fixed(date):
    """Return the positions of date date in ten cycles of Balinese Pawukon
    calendar."""
    return balinese_date(bali_luang_from_fixed(date),
                         bali_dwiwara_from_fixed(date),
                         bali_triwara_from_fixed(date),
                         bali_caturwara_from_fixed(date),
                         bali_pancawara_from_fixed(date),
                         bali_sadwara_from_fixed(date),
                         bali_saptawara_from_fixed(date),
                         bali_asatawara_from_fixed(date),
                         bali_sangawara_from_fixed(date),
                         bali_dasawara_from_fixed(date))

# see lines 2611-2614 in calendrica-3.0.cl
def bali_week_from_fixed(date):
    """Return the  week number of date date in Balinese cycle."""
    return quotient(bali_day_from_fixed(date), 7) + 1

# see lines 2616-2630 in calendrica-3.0.cl
def bali_on_or_before(b_date, date):
    """Return last fixed date on or before date with Pawukon date b_date."""
    a5 = bali_pancawara(b_date) - 1
    a6 = bali_sadwara(b_date)   - 1
    b7 = bali_saptawara(b_date) - 1
    b35 = mod(a5 + 14 + (15 * (b7 - a5)), 35)
    days = a6 + (36 * (b35 - a6))
    cap_Delta = bali_day_from_fixed(0)
    return date - mod(date + cap_Delta - days, 210)

# see lines 2632-2646 in calendrica-3.0.cl
def positions_in_range(n, c, cap_Delta, range):
    """Return the list of occurrences of n-th day of c-day cycle
    in range.
    cap_Delta is the position in cycle of RD 0."""
    a = start(range)
    b = end(range)
    pos = a + mod(n - a - cap_Delta - 1, c)
    return (nil if (pos > b) else
            [pos].extend(
                positions_in_range(n, c, cap_Delta, interval(pos + 1, b))))

# see lines 2648-2654 in calendrica-3.0.cl
def kajeng_keliwon(g_year):
    """Return the occurrences of Kajeng Keliwon (9th day of each
    15_day subcycle of Pawukon) in Gregorian year g_year."""
    year = gregorian_year_range(g_year)
    cap_Delta = bali_day_from_fixed(0)
    return positions_in_range(9, 15, cap_Delta, year)

# see lines 2656-2662 in calendrica-3.0.cl
def tumpek(g_year):
    """Return the occurrences of Tumpek (14th day of Pawukon and every
    35th subsequent day) within Gregorian year g_year."""
    year = gregorian_year_range(g_year)
    cap_Delta = bali_day_from_fixed(0)
    return positions_in_range(14, 35, cap_Delta, year)