class Mayan::Calendar < Calendrical::Calendar
  # see lines 2039-2044 in calendrica-3.0.cl
  MAYAN_EPOCH = fixed_from_jd(584283)
  
  # see lines 2083-2087 in calendrica-3.0.cl
  MAYAN_HAAB_EPOCH = MAYAN_EPOCH - mayan_haab_ordinal(mayan_haab_date(18, 8))
  
  # see lines 2116-2120 in calendrica-3.0.cl
  MAYAN_TZOLKIN_EPOCH = (MAYAN_EPOCH - mayan_tzolkin_ordinal(mayan_tzolkin_date(4, 20)))
  
  # see lines 2212-2215 in calendrica-3.0.cl
  AZTEC_CORRELATION = fixed_from_julian(julian_date(1521, AUGUST, 13))
  
  # see lines 2225-2229 in calendrica-3.0.cl
  AZTEC_XIHUITL_CORRELATION = (AZTEC_CORRELATION - aztec_xihuitl_ordinal(aztec_xihuitl_date(11, 2)))
  
  # see lines 2257-2262 in calendrica-3.0.cl
  AZTEC_TONALPOHUALLI_CORRELATION = (AZTEC_CORRELATION - aztec_tonalpohualli_ordinal(aztec_tonalpohualli_date(1, 5)))
  
  # see lines 1989-1992 in calendrica-3.0.cl
  # Return a long count Mayan date data structure.
  def mayan_long_count_date(baktun, katun, tun, uinal, kin)
    [baktun, katun, tun, uinal, kin]
  end

  # see lines 1994-1996 in calendrica-3.0.cl
  # Return a Haab Mayan date data structure."""
  def mayan_haab_date(month, day)
    [month, day]
  end

  # see lines 1998-2001 in calendrica-3.0.cl
  # Return a Tzolkin Mayan date data structure.
  def mayan_tzolkin_date(number, name)
    [number, name]
  end

  # see lines 2003-2005 in calendrica-3.0.cl
  # Return the baktun field of a long count Mayan
  # date = [baktun, katun, tun, uinal, kin].
  def mayan_baktun(date)
    date[0]
  end

  # see lines 2007-2009 in calendrica-3.0.cl
  # Return the katun field of a long count Mayan
  # date = [baktun, katun, tun, uinal, kin].
  def mayan_katun(date):
    date[1]
  end

  # see lines 2011-2013 in calendrica-3.0.cl
  # Return the tun field of a long count Mayan
  # date = [baktun, katun, tun, uinal, kin].
  def mayan_tun(date)
    date[2]
  end

  # see lines 2015-2017 in calendrica-3.0.cl
  # Return the uinal field of a long count Mayan
  # date = [baktun, katun, tun, uinal, kin].
  def mayan_uinal(date)
    date[3]
  end

  # see lines 2019-2021 in calendrica-3.0.cl
  # Return the kin field of a long count Mayan
  # date = [baktun, katun, tun, uinal, kin].
  def mayan_kin(date)
    date[4]
  end

  # see lines 2023-2025 in calendrica-3.0.cl
  # Return the month field of Haab Mayan date = [month, day]."""
  def mayan_haab_month(date)
    date[0]
  end

  # see lines 2027-2029 in calendrica-3.0.cl
  # Return the day field of Haab Mayan date = [month, day]."""
  def mayan_haab_day(date)
    date[1]
  end

  # see lines 2031-2033 in calendrica-3.0.cl
  # Return the number field of Tzolkin Mayan date = [number, name].
  def mayan_tzolkin_number(date)
    date[0]
  end

  # see lines 2035-2037 in calendrica-3.0.cl
  # Return the name field of Tzolkin Mayan date = [number, name]."""
  def mayan_tzolkin_name(date)
    date[1]
  end

  # see lines 2046-2060 in calendrica-3.0.cl
  # Return fixed date corresponding to the Mayan long count count,
  # which is a list [baktun, katun, tun, uinal, kin]."""
  def fixed_from_mayan_long_count(count):
      baktun = mayan_baktun(count)
      katun  = mayan_katun(count)
      tun    = mayan_tun(count)
      uinal  = mayan_uinal(count)
      kin    = mayan_kin(count)
      (MAYAN_EPOCH       +
        (baktun * 144000) +
        (katun * 7200)    +
        (tun * 360)       +
        (uinal * 20)      +
        kin)

  # see lines 2062-2074 in calendrica-3.0.cl
  # Return Mayan long count date of fixed date date."""
  def mayan_long_count_from_fixed(date):
    long_count = date - MAYAN_EPOCH
    baktun, day_of_baktun  = divmod(long_count, 144000)
    katun, day_of_katun    = divmod(day_of_baktun, 7200)
    tun, day_of_tun        = divmod(day_of_katun, 360)
    uinal, kin             = divmod(day_of_tun, 20)
    mayan_long_count_date(baktun, katun, tun, uinal, kin)
  end

  # see lines 2076-2081 in calendrica-3.0.cl
  # Return the number of days into cycle of Mayan haab date h_date."""
  def mayan_haab_ordinal(h_date):
    day   = mayan_haab_day(h_date)
    month = mayan_haab_month(h_date)
    ((month - 1) * 20) + day
  end

  # see lines 2089-2096 in calendrica-3.0.cl
  # Return Mayan haab date of fixed date date."""
  def mayan_haab_from_fixed(date):
    count = mod(date - MAYAN_HAAB_EPOCH, 365)
    day   = mod(count, 20)
    month = quotient(count, 20) + 1
    mayan_haab_date(month, day)
  end

  # see lines 2098-2105 in calendrica-3.0.cl
  # Return fixed date of latest date on or before fixed date date
  # that is Mayan haab date haab."""
  def mayan_haab_on_or_before(haab, date):
    date - mod(date - MAYAN_HAAB_EPOCH - mayan_haab_ordinal(haab), 365)
  end

  # see lines 2107-2114 in calendrica-3.0.cl
  # Return number of days into Mayan tzolkin cycle of t_date."""
  def mayan_tzolkin_ordinal(t_date):
    number = mayan_tzolkin_number(t_date)
    name   = mayan_tzolkin_name(t_date)
    (number - 1 + (39 * (number - name)) % 260
  end

  # see lines 2122-2128 in calendrica-3.0.cl
  # Return Mayan tzolkin date of fixed date date."""
  def mayan_tzolkin_from_fixed(date):
    count  = date - MAYAN_TZOLKIN_EPOCH + 1
    number = amod(count, 13)
    name   = amod(count, 20)
    mayan_tzolkin_date(number, name)
  end

  # see lines 2130-2138 in calendrica-3.0.cl
  # Return fixed date of latest date on or before fixed date date
  # that is Mayan tzolkin date tzolkin."""
  def mayan_tzolkin_on_or_before(tzolkin, date)
    (date - mod(date - MAYAN_TZOLKIN_EPOCH - mayan_tzolkin_ordinal(tzolkin), 260))
  end

  # see lines 2140-2150 in calendrica-3.0.cl
  # Return year bearer of year containing fixed date date.
  # Returns BOGUS for uayeb."""
  def mayan_year_bearer_from_fixed(date)
    x = mayan_haab_on_or_before(mayan_haab_date(1, 0), date + 364)
    (mayan_haab_month(mayan_haab_from_fixed(date)) == 19) ? BOGUS : mayan_tzolkin_name(mayan_tzolkin_from_fixed(x)))
  end

  # see lines 2152-2168 in calendrica-3.0.cl
  # Return fixed date of latest date on or before date, that is
  # Mayan haab date haab and tzolkin date tzolkin.
  # Returns BOGUS for impossible combinations.
  def mayan_calendar_round_on_or_before(haab, tzolkin, date):
    haab_count = mayan_haab_ordinal(haab) + MAYAN_HAAB_EPOCH
    tzolkin_count = mayan_tzolkin_ordinal(tzolkin) + MAYAN_TZOLKIN_EPOCH
    diff = tzolkin_count - haab_count
    diff % 5 == 0 ? date - mod(date - haab_count(365 * diff), 18980) : BOGUS
  end
      
  # see lines 2170-2173 in calendrica-3.0.cl
  # Return an Aztec xihuitl date data structure."""
  def aztec_xihuitl_date(month, day)
    [month, day]
  end

  # see lines 2175-2177 in calendrica-3.0.cl
  # Return the month field of an Aztec xihuitl date = [month, day]."""
  def aztec_xihuitl_month(date)
    date[0]
  end

  # see lines 2179-2181 in calendrica-3.0.cl
  # Return the day field of an Aztec xihuitl date = [month, day].
  def aztec_xihuitl_day(date)
    date[1]
  end

  # see lines 2183-2186 in calendrica-3.0.cl
  # Return an Aztec tonalpohualli date data structure.
  def aztec_tonalpohualli_date(number, name)
    [number, name]
  end

  # see lines 2188-2191 in calendrica-3.0.cl
  # Return the number field of an Aztec tonalpohualli
  # date = [number, name].
  def aztec_tonalpohualli_number(date)
    date[0]
  end

  # see lines 2193-2195 in calendrica-3.0.cl
  # Return the name field of an Aztec tonalpohualli
  # date = [number, name]."""
  def aztec_tonalpohualli_name(date)
    date[1]
  end

  # see lines 2197-2200 in calendrica-3.0.cl
  # Return an Aztec xiuhmolpilli date data structure."""
  def aztec_xiuhmolpilli_designation(number, name)
    [number, name]
  end

  # see lines 2202-2205 in calendrica-3.0.cl
  # Return the number field of an Aztec xiuhmolpilli
  # date = [number, name]."""
  def aztec_xiuhmolpilli_number(date)
    date[0]
  end

  # see lines 2207-2210 in calendrica-3.0.cl
  # Return the name field of an Aztec xiuhmolpilli
  # date = [number, name]."""
  def aztec_xiuhmolpilli_name(date)
    date[1]
  end

  # see lines 2217-2223 in calendrica-3.0.cl
  # Return the number of elapsed days into cycle of Aztec xihuitl
  # date x_date.
  def aztec_xihuitl_ordinal(x_date):
    day   = aztec_xihuitl_day(x_date)
    month = aztec_xihuitl_month(x_date)
    ((month - 1) * 20) + day - 1
  end

  # see lines 2231-2237 in calendrica-3.0.cl
  # Return Aztec xihuitl date of fixed date date."""
  def aztec_xihuitl_from_fixed(date):
    count = mod(date - AZTEC_XIHUITL_CORRELATION, 365)
    day   = mod(count, 20) + 1
    month = quotient(count, 20) + 1
    aztec_xihuitl_date(month, day)
  end

  # see lines 2239-2246 in calendrica-3.0.cl
  # Return fixed date of latest date on or before fixed date date
  # that is Aztec xihuitl date xihuitl.
  def aztec_xihuitl_on_or_before(xihuitl, date)
    date - ((date - AZTEC_XIHUITL_CORRELATION - aztec_xihuitl_ordinal(xihuitl)) % 365)
  end

  # see lines 2248-2255 in calendrica-3.0.cl
  # Return the number of days into Aztec tonalpohualli cycle of t_date."""
  def aztec_tonalpohualli_ordinal(t_date)
    number = aztec_tonalpohualli_number(t_date)
    name   = aztec_tonalpohualli_name(t_date)
    (number - 1 + 39 * (number - name) % 260)
  end

  # see lines 2264-2270 in calendrica-3.0.cl
  # Return Aztec tonalpohualli date of fixed date date."""
  def aztec_tonalpohualli_from_fixed(date)
    count  = date - AZTEC_TONALPOHUALLI_CORRELATION + 1
    number = amod(count, 13)
    name   = amod(count, 20)
    aztec_tonalpohualli_date(number, name)
  end

  # see lines 2272-2280 in calendrica-3.0.cl
  # Return fixed date of latest date on or before fixed date date
  # that is Aztec tonalpohualli date tonalpohualli."""
  def aztec_tonalpohualli_on_or_before(tonalpohualli, date)
    (date - (date - AZTEC_TONALPOHUALLI_CORRELATION - aztec_tonalpohualli_ordinal(tonalpohualli) % 260))
  end

  # # see lines 2282-2303 in calendrica-3.0.cl
  # Return fixed date of latest xihuitl_tonalpohualli combination
  # on or before date date.  That is the date on or before
  # date date that is Aztec xihuitl date xihuitl and
  # tonalpohualli date tonalpohualli.
  # Returns BOGUS for impossible combinations.
  def aztec_xihuitl_tonalpohualli_on_or_before(xihuitl, tonalpohualli, date)
    xihuitl_count = aztec_xihuitl_ordinal(xihuitl) + AZTEC_XIHUITL_CORRELATION
    tonalpohualli_count = (aztec_tonalpohualli_ordinal(tonalpohualli) +
                           AZTEC_TONALPOHUALLI_CORRELATION)
    diff = tonalpohualli_count - xihuitl_count
    (diff % 5) == 0 ? date - mod(date - xihuitl_count - (365 * diff), 18980) : BOGUS
  end

  # see lines 2305-2316 in calendrica-3.0.cl
  # Return designation of year containing fixed date date.
  # Returns BOGUS for nemontemi.
  def aztec_xiuhmolpilli_from_fixed(date)
    x = aztec_xihuitl_on_or_before(aztec_xihuitl_date(18, 20), date + 364)
    month = aztec_xihuitl_month(aztec_xihuitl_from_fixed(date))
    (month == 19) ? BOGUS : aztec_tonalpohualli_from_fixed(x)
  end
end
