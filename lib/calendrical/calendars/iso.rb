class IsoDate < Calendar
  Date = Struct.new(:year, :week, :day)
  delegate :year, :week, :day, to: :elements
  
  include Calendrical::Ecclesiastical
  include Calendrical::Kday
  include Calendrical::Dates
  
  def self.epoch
    rd(1)
  end

  # Format output as 2014-W40-3
  def inspect
    "#{year}-W#{week}-#{day} ISO"
  end
  
  def to_s
    day_name = I18n.t('gregorian.days')[day_of_week]
    week_name = "W%02d" % week
    "#{day_name}, #{day} #{week_name} #{year}"
  end

  # see lines 995-1005 in calendrica-3.0.cl
  # Return the fixed date equivalent to ISO date 'i_date'.
  def to_fixed(i_date = self)
    year = i_date.year
    week = i_date.week
    day  = i_date.day
    nth_kday(week, SUNDAY, GregorianDate[year - 1, DECEMBER, 28].fixed) + day
  end

  # see lines 1007-1022 in calendrica-3.0.cl
  # Return the ISO date corresponding to the fixed date 'date'."""
  def to_calendar(date = self.fixed)
    approx = GregorianDate[date - 3].year #gregorian_year_from_fixed(date - 3)
    year   = date >= date(approx + 1, 1, 1).fixed ? approx + 1 : approx
    week   = 1 + quotient(date - date(year, 1, 1).fixed, 7)
    day    = amod(date - rd(0), 7)
    Date.new(year, week, day)
  end

  # see lines 1024-1032 in calendrica-3.0.cl
  # Return True if ISO year 'i_year' is a long (53-week) year."""
  def long_year?(i_year)
    jan1  = day_of_week(GregorianYear[i_year].new_year.fixed)
    dec31 = day_of_week(GregorianYear[i_year].year_end.fixed)
    (jan1 == THURSDAY) || (dec31 == THURSDAY)
  end

end
