class HebrewDate < Calendar
  NISAN       = 1
  IYYAR       = 2
  SIVAN       = 3
  TAMMUZ      = 4
  AV          = 5
  ELUL        = 6
  TISHRI      = 7
  MARHESHVAN  = 8
  KISLEV      = 9
  TEVET       = 10
  SHEVAT      = 11
  ADAR        = 12
  ADARII      = 13

  # see lines 1581-1585 in calendrica-3.0.cl
  def self.epoch
    JulianDate[3761.bce, OCTOBER, 7].fixed
  end
  
  def inspect
    "#{year}-#{month}-#{day} Hebrew"
  end
  
  def to_s
    day_name = I18n.t('hebrew.days')[day_of_week]
    month_name = I18n.t('hebrew.months')[month - 1]
    "#{day_name}, #{day} #{month_name} #{year}"
  end
  
  # see lines 1702-1721 in calendrica-3.0.cl
  # Return fixed date of Hebrew date h_date.
  def to_fixed(h_date = self)
    mmonth = h_date.month
    dday   = h_date.day
    yyear  = h_date.year

    if (mmonth < TISHRI)
      tmp = (summa(lambda{|m| last_day_of_month(m, yyear)},
                   TISHRI,
                   lambda{|m| m <= last_month_of_year(yyear)}) +
             summa(lambda{|m| last_day_of_month(m, yyear)},
                   NISAN,
                   lambda{|m| m < mmonth}))
    else
      tmp = summa(lambda{|m| last_day_of_month(m, yyear)},
                  TISHRI,
                  lambda{|m| m < mmonth})
    end
    new_year(yyear) + dday - 1 + tmp
  end

  # see lines 1723-1751 in calendrica-3.0.cl
  # Return  Hebrew (year month day) corresponding to fixed date date.
  # The fraction can be approximated by 365.25.
  def to_calendar(f_date = self.fixed)
    approx = quotient(f_date - epoch, 35975351/98496.0) + 1
    yyear = final_of(approx - 1, lambda{|y| new_year(y) <= f_date})
    start = f_date < to_fixed(date(yyear, NISAN, 1)) ? TISHRI : NISAN
    mmonth = next_of(start, lambda{|m| f_date <= to_fixed(date(yyear, m, last_day_of_month(m, yyear)))})
    dday = f_date - to_fixed(date(yyear, mmonth, 1)) + 1
    Date.new(yyear, mmonth, dday)
  end
  
  # see lines 3021-3025 in calendrica-3.0.cl
  # Return standard time of Jewish dusk on fixed date, date,
  # at location, location, (as per Vilna Gaon).
  def dusk(f_date = self.fixed, location = JERUSALEM)
    dusk(f_date, location, angle(4, 40, 0))
  end
  alias :jewish_dusk :dusk

  # see lines 3027-3031 in calendrica-3.0.cl
  # Return standard time of end of Jewish sabbath on fixed date, date,
  # at location, location, (as per Berthold Cohn).
  def sabbath_ends(f_date = self.fixed, location = JERUSALEM)
    dusk(f_date, location, angle(7, 5, 0)) 
  end

  # see lines 3075-3079 in calendrica-3.0.cl
  # Return standard time on fixed date, date, at location, location,
  # of end of morning according to Jewish ritual.
  def morning_ends(f_date = self.fixed, location = JERUSALEM)
    standard_from_sundial(f_date + 10.hrs, location)
  end

  # see lines 1587-1590 in calendrica-3.0.cl
  # Return True if h_year is a leap year on Hebrew calendar.
  def leap_year?(h_year = self.year)
    (7 * h_year + 1) % 19 < 7
  end

  # see lines 1592-1597 in calendrica-3.0.cl
  # Return last month of Hebrew year."""
  def last_month_of_year(h_year = self.year)
    leap_year?(h_year) ? ADARII : ADAR
  end

  # see lines 1599-1603 in calendrica-3.0.cl
  # Return True if h_year is a sabbatical year on the Hebrew calendar.
  def sabbatical_year?(h_year = self.year)
    h_year % 7 == 0
  end

  # see lines 1605-1617 in calendrica-3.0.cl
  # Return last day of month h_month in Hebrew year h_year.
  def last_day_of_month(h_month = self.month, h_year = self.year)
    if [IYYAR, TAMMUZ, ELUL, TEVET, ADARII].include?(h_month) ||
        ((h_month == ADAR) && !leap_year?(h_year)) ||
        ((h_month == MARHESHVAN) && !long_marheshvan?(h_year)) ||
        ((h_month == KISLEV) && short_kislev?(h_year))
      return 29
    else
      return 30
    end
  end

  # see lines 1619-1634 in calendrica-3.0.cl
  # Return moment of mean conjunction of h_month in Hebrew h_year.
  def molad(h_month = self.month, h_year = self.year)
    y = (h_month < TISHRI) ? (h_year + 1) : h_year
    months_elapsed = h_month - TISHRI + quotient(235 * y - 234, 19)
    (epoch - 876.0/25920 + months_elapsed * (29 + hr(12) + 793.0/25920))
  end

  # see lines 1636-1663 in calendrica-3.0.cl
  # Return number of days elapsed from the (Sunday) noon prior
  # to the epoch of the Hebrew calendar to the mean
  # conjunction (molad) of Tishri of Hebrew year h_year,
  # or one day later.
  def elapsed_days(h_year = self.year)
    months_elapsed = quotient(235 * h_year - 234, 19)
    parts_elapsed  = 12084 + 13753 * months_elapsed
    days = 29 * months_elapsed + quotient(parts_elapsed, 25920)
    (3 * (days + 1)) % 7 < 3 ? days + 1 : days
  end

  # see lines 1665-1670 in calendrica-3.0.cl
  # Return fixed date of Hebrew new year h_year.
  def new_year(h_year = self.year)
    (epoch + elapsed_days(h_year) + year_length_correction(h_year))
  end

  # see lines 1672-1684 in calendrica-3.0.cl
  # Return delays to start of Hebrew year h_year to keep ordinary
  # year in range 353-356 and leap year in range 383-386.
  def year_length_correction(h_year = self.year)
    ny0 = elapsed_days(h_year - 1)
    ny1 = elapsed_days(h_year)
    ny2 = elapsed_days(h_year + 1)
    if ((ny2 - ny1) == 356)
      return 2
    elsif ((ny1 - ny0) == 382)
      return 1
    else
      return 0
    end
  end

  # see lines 1686-1690 in calendrica-3.0.cl
  # Return number of days in Hebrew year h_year.
  def days_in_year(h_year = self.year)
    new_year(h_year + 1) - new_year(h_year)
  end

  # see lines 1692-1695 in calendrica-3.0.cl
  # Return True if Marheshvan is long in Hebrew year h_year.
  def long_marheshvan?(h_year = self.year)
    [355, 385].include? days_in_year(h_year)
  end

  # see lines 1697-1700 in calendrica-3.0.cl
  # Return True if Kislev is short in Hebrew year h_year.
  def short_kislev?(h_year = self.year)
    [353, 383].include? days_in_year(h_year)
  end

  # see lines 1753-1761 in calendrica-3.0.cl
  # Return fixed date of Yom Kippur occurring in Gregorian year g_year.
  def yom_kippur(g_year = self.year)
    hebrew_year = g_year - GregoriandDate[epoch].year + 1
    date(hebrew_year, TISHRI, 10)
  end

  # see lines 1763-1770 in calendrica-3.0.cl
  # Return fixed date of Passover occurring in Gregorian year g_year.
  def passover(g_year = self.year)
    hebrew_year = g_year - GregoriandDate[epoch].year
    date(hebrew_year, NISAN, 15)
  end

  # see lines 1772-1782 in calendrica-3.0.cl
  # Return the number of elapsed weeks and days in the omer at date date.
  # Returns BOGUS if that date does not fall during the omer.
  def omer(f_date = self.fixed)
    c = f_date - passover(GregorianDate[f_date].year)
    (1..49).include?(c) ? [quotient(c, 7), c % 7] : BOGUS
  end

  # see lines 1784-1793 in calendrica-3.0.cl
  # Return fixed date of Purim occurring in Gregorian year g_year.
  def purim(g_year = self.year)
    hebrew_year = g_year - GregoriandDate[epoch].year
    last_month  = last_month_of_year(hebrew_year)
    date(hebrew_year(last_month, 14))
  end

  # see lines 1795-1805 in calendrica-3.0.cl
  # Return fixed date of Ta'anit Esther occurring in Gregorian
  # year g_year.
  def ta_anit_esther(g_year = self.year)
    purim_date = purim(g_year)
    (day_of_week_from_fixed(purim_date) == SUNDAY) ? (purim_date - 3) : (purim_date - 1)
  end

  # see lines 1807-1821 in calendrica-3.0.cl
  # Return fixed date of Tishah be_Av occurring in Gregorian year g_year.
  def tishah_be_av(g_year = self.year)
    hebrew_year = g_year - GregoriandDate[epoch].year
    av9 = date(hebrew_year, AV, 9).fixed
    (day_of_week_from_fixed(av9) == SATURDAY) ? (av9 + 1) : av9
  end

  # see lines 1823-1834 in calendrica-3.0.cl
  # Return the list of fixed date of Birkath ha_Hama occurring in
  # Gregorian year g_year, if it occurs.
  def birkath_ha_hama(g_year = self.year)
    dates = coptic_in_gregorian(7, 30, g_year)
    (dates.length > 1 && (CopticDate[dates.first].year % 28 == 17)) ? dates : []
  end

  # see lines 1836-1840 in calendrica-3.0.cl
  # Return the list of fixed dates of Sh'ela occurring in
  # Gregorian year g_year.
  def sh_ela(g_year = self.year)
    coptic_in_gregorian(3, 26, g_year)
  end

  # exercise for the reader from pag 104
  # Return list of the fixed dates of Hebrew month, h_month, day, h_day,
  # that occur in Gregorian year g_year.
  def hebrew_in_gregorian(h_month = self.month, h_day = self.day, g_year = self.year)
    jan1  = GregorianDate[g_year, 1, 1].new_year.fixed
    y     = date(jan1).year
    date1 = date(y, h_month, h_day).fixed
    date2 = date(y + 1, h_month, h_day).fixed
    # Hebrew and Gregorian calendar are aligned but certain
    # holidays, i.e. Tzom Tevet, can fall on either side of Jan 1.
    # So we can have 0, 1 or 2 occurences of that holiday.
    dates = [date1, date2]
    list_range(dates, gregorian_year_range(g_year))
  end

  # see pag 104
  # Return the list of fixed dates for Tzom Tevet (Tevet 10) that
  # occur in Gregorian year g_year. It can occur 0, 1 or 2 times per
  # Gregorian year.
  def tzom_tevet(g_year = self.year)
    jan1  = GregorianDate[g_year, 1, 1].new_year.fixed
    y     = date(jan1).year
    d1 = date(y, TEVET, 10).fixed
    d1 = (day_of_week_from_fixed(d1) == SATURDAY) ? (d1 + 1) : d1
    d2 = to_fixed(date(y + 1, TEVET, 10))
    d2 = (day_of_week_from_fixed(d2) == SATURDAY) ? (d2 + 1) : d2
    dates = [d1, d2]
    list_range(dates, gregorian_year_range(g_year))
  end

  # this is a simplified version where no check for SATURDAY
  # is performed: from hebrew year 1 till 2000000
  # there is no TEVET 10 falling on Saturday...
  # Return the list of fixed dates for Tzom Tevet (Tevet 10) that
  # occur in Gregorian year g_year. It can occur 0, 1 or 2 times per
  # Gregorian year.
  def alt_tzom_tevet(g_year = self.year)
    hebrew_in_gregorian(TEVET, 10, g_year)
  end

  # see lines 1842-1859 in calendrica-3.0.cl
  # Return fixed date of Yom ha_Zikkaron occurring in Gregorian
  # year g_year.
  def yom_ha_zikkaron(g_year = self.year)
    hebrew_year = g_year - GregoriandDate[epoch].year
    iyyar4 = date(hebrew_year, IYYAR, 4).fixed

    if [THURSDAY, FRIDAY].include? day_of_week_from_fixed(iyyar4)
      return kday_before(WEDNESDAY, iyyar4)
    elsif (SUNDAY == day_of_week_from_fixed(iyyar4))
      return iyyar4 + 1
    else
      return iyyar4
    end
  end

  # see lines 1861-1879 in calendrica-3.0.cl
  # Return fixed date of the anniversary of Hebrew birth date
  # birthdate occurring in Hebrew h_year.
  def hebrew_birthday(birthdate, h_year = self.year)
    birth_day   = birthdate.day
    birth_month = birthdate.month
    birth_year  = birthdate.year
    if birth_month == last_month_of_year(birth_year)
      date(h_year, last_month_of_year(h_year), birth_day).fixed
    else
      date(h_year, birth_month, 1).fixed + birth_day - 1
    end
  end
        

  # see lines 1881-1893 in calendrica-3.0.cl
  # Return the list of the fixed dates of Hebrew birthday
  # birthday that occur in Gregorian g_year.
  def hebrew_birthday_in_gregorian(birthdate, g_year)
    jan1 = GregorianYear[g_year].new_year.fixed
    y    = date(jan1).fixed
    date1 = hebrew_birthday(birthdate, y)
    date2 = hebrew_birthday(birthdate, y + 1)
    list_range([date1, date2], GregorianYear[g_year].year_range)
  end

  # see lines 1895-1937 in calendrica-3.0.cl
  # Return fixed date of the anniversary of Hebrew death date death_date
  # occurring in Hebrew h_year.
  def yahrzeit(death_date, h_year = self.year)
    death_day   = death_date.day
    death_month = death_date.month
    death_year  = death_date.year

    if death_month == MARHESHVAN && death_day == 30 && !long_marheshvan?(death_year + 1)
      date(h_year, KISLEV, 1).fixed - 1
    elsif death_month == KISLEV && death_day == 30 && short_kislev?(death_year + 1)
      date(h_year, TEVET, 1).fixed - 1
    elsif death_month == ADARII
      date(h_year, last_month_of_year(h_year), death_day)
    elsif death_day == 30 && death_month == ADAR && !leap_year(h_year)
      date(h_year, SHEVAT, 30).fixed
    else
      date(h_year, death_month, 1).fixed + death_day - 1
    end
  end

  # see lines 1939-1951 in calendrica-3.0.cl
  # Return the list of the fixed dates of death date death_date (yahrzeit)
  # that occur in Gregorian year g_year.
  def yahrzeit_in_gregorian(death_date, g_year = self.year)
    jan1 = GregorianDate[g_year, 1, 1].new_year.fixed
    y    = date(jan1).fixed
    date1 = yahrzeit(death_date, y)
    date2 = yahrzeit(death_date, y + 1)
    list_range([date1, date2], gregorian_year_range(g_year))
  end

  # see lines 1953-1960 in calendrica-3.0.cl
  # Shift each weekday on list l by cap_Delta days.
  def shift_days(l, cap_Delta)
    l.map{|x| day_of_week_from_fixed(x + cap_Delta)}
  end

  # see lines 1962-1984 in calendrica-3.0.cl
  # Return a list of possible days of week for Hebrew day h_day
  # and Hebrew month h_month.
  def possible_hebrew_days(h_month = self.month, h_day = self.day)
    h_date0 = date(5, NISAN, 1)
    h_year  = (h_month > ELUL) ? 6 : 5
    h_date  = date(h_year, h_month, h_day)
    n       = h_date.fixed - h_date0.fixed
    tue_thu_sat = [TUESDAY, THURSDAY, SATURDAY]

    if h_day == 30 && [MARHESHVAN, KISLEV].include?(h_month)
      sun_wed_fri = []
    elsif h_month == KISLEV
      sun_wed_fri = [SUNDAY, WEDNESDAY, FRIDAY]
    else
      sun_wed_fri = [SUNDAY]
    end

    mon = [KISLEV, TEVET, SHEVAT, ADAR].include?(h_month) ? [MONDAY] : [ ]

    ell = tue_thu_sat
    ell << sun_wed_fri
    ell << mon
    shift_days(ell, n)
  end

  # see lines 5940-5955 in calendrica-3.0.cl
  # Return fixed date of Observational (classical)
  # Nisan 1 occurring in Gregorian year, g_year.
  def observational_hebrew_new_year(g_year = self.year)
    jan1 = GregorianDate[g_year, 1, 1].new_year.fixed
    equinox = solar_longitude_after(SPRING, jan1)
    sset = universal_from_standard(sunset(equinox.floor, JAFFA), JAFFA)
    phasis_on_or_after(equinox.floor - ((equinox < sset) ? 14 : 13), JAFFA)
  end

  # see lines 5957-5973 in calendrica-3.0.cl
  # Return fixed date equivalent to Observational Hebrew date.
  def fixed_from_observational_hebrew(h_date = self)
    mmonth = h_date.month
    dday = h_date.day
    yyear = h_date.year
    year1 = (mmonth >= TISHRI) ? (yyear - 1) : year
    start = date(year1, NISAN, 1).fixed
    g_year = GregorianDate[start + 60].year
    new_year = observational_hebrew_new_year(g_year)
    midmonth = new_year + (29.5 * (month - 1)).round + 15
    phasis_on_or_before(midmonth, JAFFA) + day - 1
  end

  # see lines 5975-5991 in calendrica-3.0.cl
  # Return Observational Hebrew date (year month day)
  # corresponding to fixed date, date.
  def observational_hebrew_from_fixed(f_date = self.fixed)
    crescent = phasis_on_or_before(f_date, JAFFA)
    g_year = GregorianDate[f_date].year
    ny = observational_hebrew_new_year(g_year)
    new_year = (f_date < ny) ? observational_hebrew_new_year(g_year - 1) : ny
    mmonth = ((crescent - new_year) / 29.5).round + 1
    yyear = date(new_year).year + ((month >= TISHRI) ? 1 : 0)
    dday = f_date - crescent + 1
    date(yyear, mmonth, dday)
  end

  # see lines 5993-5997 in calendrica-3.0.cl
  # Return fixed date of Classical (observational) Passover Eve
  # (Nisan 14) occurring in Gregorian year, g_year.
  def classical_passover_eve(g_year = self.year)
    observational_hebrew_new_year(g_year) + 13
  end
end