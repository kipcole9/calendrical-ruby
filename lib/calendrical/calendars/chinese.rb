class ChineseDate < Calendar
  extend Calendrical::Epoch
  Name = Struct.new(:stem, :branch)
  Date = Struct.new(:cycle, :year, :month, :leap, :day)
  delegate :cycle, :year, :month, :leap, :day, to: :elements
  
  # see lines 4651-4655 in calendrica-3.0.cl
  CHINESE_MONTH_NAME_EPOCH = 57
  
  # see lines 4666-4669 in calendrica-3.0.cl
  CHINESE_DAY_NAME_EPOCH = rd(45)
  
  include Calendrical::Kday
  include Calendrical::Dates
  
  def epoch
    GregorianDate[-2636, FEBRUARY, 15].fixed
  end
  
  def inspect
    "#{cycle}-#{year}-#{month}-#{day} Chinese"
  end

  def to_s
    "#{year_name} #{month_name} #{day_name}"
  end
  
  # see lines 4520-4565 in calendrica-3.0.cl
  # Return Chinese date (cycle year month leap day) of fixed date, date.
  def to_calendar(f_date)
    s1 = chinese_winter_solstice_on_or_before(f_date)
    s2 = chinese_winter_solstice_on_or_before(s1 + 370)
    next_m11 = chinese_new_moon_before(1 + s2)
    m12 = chinese_new_moon_on_or_after(1 + s1)
    leap_year = ((next_m11 - m12) / MEAN_SYNODIC_MONTH).round == 12

    m = chinese_new_moon_before(1 + f_date)
    mmonth = amod(((m - m12) / MEAN_SYNODIC_MONTH).round - (leap_year && chinese_prior_leap_month?(m12, m) ? 1 : 0), 12)
    leap_month = leap_year && chinese_no_major_solar_term?(m) && !chinese_prior_leap_month?(m12, chinese_new_moon_before(m))
    elapsed_years = (mpf(1.5) - (mmonth / 12.0) + ((f_date - epoch) / MEAN_TROPICAL_YEAR)).floor
    ccycle = 1 + quotient(elapsed_years - 1, 60)
    yyear = amod(elapsed_years, 60)
    dday = 1 + (f_date - m)
    Date.new(ccycle, yyear, mmonth, leap_month, dday)
  end

  # see lines 4567-4596 in calendrica-3.0.cl
  # Return fixed date of Chinese date, c_date.
  def to_fixed(c_date)
    cycle = c_date.cycle
    year  = c_date.year
    month = c_date.month
    leap  = c_date.leap
    day   = c_date.day
    mid_year = (epoch + ((((cycle - 1) * 60) + (year - 1) + 1/2) * MEAN_TROPICAL_YEAR)).floor
    new_year = new_year_on_or_before(mid_year)
    p = chinese_new_moon_on_or_after(new_year + ((month - 1) * 29))
    d = to_calendar(p)
    prior_new_moon = ((month == d.month) && (leap == d.leap)) ? p : chinese_new_moon_on_or_after(1 + p)
    prior_new_moon + day - 1
  end
  
  # see lines 4355-4363 in calendrica-3.0.cl
  # Return location of Beijing; time zone varies with time, tee.
  def location(tee)
    year = GregorianYear[tee.floor].year
    (year < 1929) ? BEIJING_OLD_ZONE : BEIJING
  end

  # see lines 4365-4377 in calendrica-3.0.cl
  # Return moment (Beijing time) of the first date on or after
  # fixed date, date, (Beijing time) when the solar longitude
  # will be 'lam' degrees.
  def chinese_solar_longitude_on_or_after(lam, date)
    tee = solar_longitude_after(lam, universal_from_standard(date, location(date)))
    standard_from_universal(tee, location(tee))
  end

  # see lines 4379-4387 in calendrica-3.0.cl
  # Return last Chinese major solar term (zhongqi) before
  # fixed date, date.
  def current_major_solar_term(date)
    s = solar_longitude(universal_from_standard(date, location(date)))
    amod(2 + quotient(s.to_i, 30.degrees), 12)
  end

  # see lines 4389-4397 in calendrica-3.0.cl
  # Return moment (in Beijing) of the first Chinese major
  # solar term (zhongqi) on or after fixed date, date.  The
  # major terms begin when the sun's longitude is a
  # multiple of 30 degrees.
  def major_solar_term_on_or_after(date)
    s = solar_longitude(midnight_in_china(date))
    l = (30 * ceiling(s / 30)) % 360
    chinese_solar_longitude_on_or_after(l, date)
  end

  # see lines 4399-4407 in calendrica-3.0.cl
  # Return last Chinese minor solar term (jieqi) before date, date.
  def current_minor_solar_term(date)
    s = solar_longitude(universal_from_standard(date, location(date)))
    amod(3 + quotient(s - 15.degrees, 30.degrees), 12)
  end

  # see lines 4409-4422 in calendrica-3.0.cl
  # Return moment (in Beijing) of the first Chinese minor solar
  # term (jieqi) on or after fixed date, date.  The minor terms
  # begin when the sun's longitude is an odd multiple of 15 degrees.
  def minor_solar_term_on_or_after(date)
    s = solar_longitude(midnight_in_china(date))
    l = (30 * ((s - 15.degrees).ceil / 30.0) + 15.degrees) % 360
    chinese_solar_longitude_on_or_after(l, date)
  end

  # see lines 4424-4433 in calendrica-3.0.cl
  # Return fixed date (Beijing) of first new moon before fixed date, date.
  def chinese_new_moon_before(date)
    tee = new_moon_before(midnight_in_china(date))
    (standard_from_universal(tee, location(tee))).floor
  end

  # see lines 4435-4444 in calendrica-3.0.cl
  # Return fixed date (Beijing) of first new moon on or after
  # fixed date, date.
  def chinese_new_moon_on_or_after(date)
    tee = new_moon_at_or_after(midnight_in_china(date))
    (standard_from_universal(tee, location(tee))).floor
  end

  # see lines 4451-4457 in calendrica-3.0.cl
  # Return True if Chinese lunar month starting on date, date,
  # has no major solar term.
  def chinese_no_major_solar_term?(date)
    (current_major_solar_term(date) == current_major_solar_term(chinese_new_moon_on_or_after(date + 1)))
  end

  # see lines 4459-4463 in calendrica-3.0.cl
  # Return Universal time of (clock) midnight at start of fixed
  # date, date, in China.
  def midnight_in_china(date)
    universal_from_standard(date, location(date))
  end

  # see lines 4465-4474 in calendrica-3.0.cl
  # Return fixed date, in the Chinese zone, of winter solstice
  # on or before fixed date, date.
  def chinese_winter_solstice_on_or_before(date)
    approx = estimate_prior_solar_longitude(WINTER, midnight_in_china(date + 1))
    next_of(approx.floor - 1, lambda{|day| WINTER < solar_longitude(midnight_in_china(1 + day))})
  end

  # see lines 4476-4500 in calendrica-3.0.cl
  # Return fixed date of Chinese New Year in sui (period from
  # solstice to solstice) containing date, date.
  def chinese_new_year_in_sui(date)
    s1 = chinese_winter_solstice_on_or_before(date)
    s2 = chinese_winter_solstice_on_or_before(s1 + 370)
    next_m11 = chinese_new_moon_before(1 + s2)
    m12 = chinese_new_moon_on_or_after(1 + s1)
    m13 = chinese_new_moon_on_or_after(1 + m12)
    leap_year = iround((next_m11 - m12) / MEAN_SYNODIC_MONTH) == 12

    if (leap_year && (chinese_no_major_solar_term?(m12) || chinese_no_major_solar_term?(m13)))
      chinese_new_moon_on_or_after(1 + m13)
    else
      m13
    end
  end

  # see lines 4502-4511 in calendrica-3.0.cl
  # Return fixed date of Chinese New Year on or before fixed date, date.
  def new_year_on_or_before(date)
    new_year = chinese_new_year_in_sui(date)
    (date >= new_year) ? new_year : chinese_new_year_in_sui(date - 180)
  end
        
  # see lines 4513-4518 in calendrica-3.0.cl
  # Return fixed date of Chinese New Year in Gregorian year, g_year.
  def new_year(g_year)
    new_year_on_or_before(GregorianDate[g_year, JULY, 1].fixed)
  end

  # see lines 4598-4607 in calendrica-3.0.cl
  # Return True if there is a Chinese leap month on or after lunar
  # month starting on fixed day, m_prime and at or before
  # lunar month starting at fixed date, m.
  def chinese_prior_leap_month?(m_prime, m)
    ((m >= m_prime) && (chinese_no_major_solar_term?(m) || chinese_prior_leap_month?(m_prime, chinese_new_moon_before(m))))
  end

  # see lines 4609-4615 in calendrica-3.0.cl
  # Return BOGUS if stem/branch combination is impossible.
  def chinese_name(stem, branch)
    (stem % 2 == branch % 2) ? Name.new(stem, branch) : BOGUS
  end

  # see lines 4625-4629 in calendrica-3.0.cl
  # Return the n_th name of the Chinese sexagesimal cycle.
  def chinese_sexagesimal_name(n)
    Name.new(amod(n, 10), amod(n, 12))
  end

  # see lines 4631-4644 in calendrica-3.0.cl
  # Return the number of names from Chinese name c_name1 to the
  # next occurrence of Chinese name c_name2.
  def chinese_name_difference(c_name1, c_name2)
    stem1 = c_name1.stem
    stem2 = c_name2.stem
    branch1 = c_name1.branch
    branch2 = c_name2.branch
    stem_difference   = stem2 - stem1
    branch_difference = branch2 - branch1
    1 + ((stem_difference - 1 + 25 * (branch_difference - stem_difference)) % 60)
  end

  # see lines 4646-4649 in calendrica-3.0.cl
  # see lines 214-215 in calendrica-3.0.errata.cl
  # Return sexagesimal name for Chinese year, year, of any cycle.
  def year_name(yyear = self.year)
    name = chinese_sexagesimal_name(yyear)
    stem = I18n.t('chinese.stem')[name.stem - 1]
    branch = I18n.t('chinese.branch')[name.branch - 1]
    "#{stem}#{branch}"
  end

  # see lines 4657-4664 in calendrica-3.0.cl
  # see lines 211-212 in calendrica-3.0.errata.cl
  # Return sexagesimal name for month, month, of Chinese year, year.
  def month_name(mmonth = self.month, yyear = self.year)
    elapsed_months = (12 * (yyear - 1)) + (mmonth - 1)
    name = chinese_sexagesimal_name(elapsed_months - CHINESE_MONTH_NAME_EPOCH)
    stem = I18n.t('chinese.stem')[name.stem - 1]
    branch = I18n.t('chinese.branch')[name.branch - 1]
    "#{stem}#{branch}"
  end

  # see lines 4671-4675 in calendrica-3.0.cl
  # see lines 208-209 in calendrica-3.0.errata.cl
  def day_name(date = self.fixed)
    # Return Chinese sexagesimal name for date, date.
    name = chinese_sexagesimal_name(date - CHINESE_DAY_NAME_EPOCH)
    stem = I18n.t('chinese.stem')[name.stem - 1]
    branch = I18n.t('chinese.branch')[name.branch - 1]
    "#{stem}#{branch}"
  end

  # see lines 4677-4687 in calendrica-3.0.cl
  def chinese_day_name_on_or_before(name, date)
    # Return fixed date of latest date on or before fixed date, date, that
    # has Chinese name, name.
    date - ((date + chinese_name_difference(name, chinese_sexagesimal_name(CHINESE_DAY_NAME_EPOCH))) % 60)
  end

  # see lines 4689-4699 in calendrica-3.0.cl
  # Return fixed date of the Dragon Festival occurring in Gregorian
  # year g_year.
  def dragon_festival(g_year)
    elapsed_years = 1 + g_year - gregorian_year_from_fixed(CHINESE_EPOCH)
    cycle = 1 + quotient(elapsed_years - 1, 60)
    year = amod(elapsed_years, 60)
    date(cycle, year, 5, false, 5).fixed
  end

  # see lines 4701-4708 in calendrica-3.0.cl
  # Return fixed date of Qingming occurring in Gregorian year, g_year."""
  def qing_ming(g_year)
    (minor_solar_term_on_or_after(GregorianDate[g_year, MARCH, 30].fixed)).floor
  end

  # see lines 4710-4722 in calendrica-3.0.cl
  # Return the age at fixed date, date, given Chinese birthdate, birthdate,
  # according to the Chinese custom.
  # Returns BOGUS if date is before birthdate.
  def chinese_age(birthdate, date)
    today = to_calendar(date)
    if date >= birthdate.fixed
        (60 * (today.cycle - birthdate.cycle) + (today.year -  birthdate.year) + 1)
    else
      BOGUS
    end
  end

  # see lines 4724-4758 in calendrica-3.0.cl
  # Return the marriage augury type of Chinese year, year in cycle, cycle.
  # 0 means lichun does not occur (widow or double-blind years),
  # 1 means it occurs once at the end (blind),
  # 2 means it occurs once at the start (bright), and
  # 3 means it occurs twice (double-bright or double-happiness).
  def chinese_year_marriage_augury(cycle, year)
    new_year = date(cycle, year, 1, False, 1).fixed
    c = (year == 60) ? (cycle + 1) : cycle
    y = (year == 60) ? 1 : (year + 1)
    next_new_year = date(c, y, 1, false, 1).fixed
    first_minor_term = current_minor_solar_term(new_year)
    next_first_minor_term = current_minor_solar_term(next_new_year)
    if ((first_minor_term == 1) && (next_first_minor_term == 12))
      res = 0
    elsif ((first_minor_term == 1) && (next_first_minor_term != 12))
      res = 1
    elsif ((first_minor_term != 1) && (next_first_minor_term == 12))
      res = 2
    else
      res = 3
    end
    return res
  end
end

