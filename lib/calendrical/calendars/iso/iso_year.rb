class IsoYear < GregorianYear
  delegate :long_year?, to: :class

  def new_year
    IsoDate[year, 1, 1]
  end
  
  def year_end
    IsoDate[year, last_week_of_year, 7]
  end
 
  # see lines 1024-1032 in calendrica-3.0.cl
  # Return True if ISO year 'i_year' is a long (53-week) year."""
  def self.long_year?(i_year)
    new(i_year).long_year?
  end
  
  def long_year?(i_year = self)
    jan1  = day_of_week(GregorianYear[i_year].new_year.fixed)
    dec31 = day_of_week(GregorianYear[i_year].year_end.fixed)
    (jan1 == THURSDAY) || (dec31 == THURSDAY)
  end
  
  def quarter(n)
    IsoQuarter[self.year, n]
  end
  
  def week(n)
    raise(Calendrical::InvalidWeek, "Invalid week '#{n}' which must be between 1 and 52 inclusive") unless (1..52).include?(n.to_i)
  end
  
  def last_week_of_year
    long_year?(year) ? 53 : 52
  end
  
end
