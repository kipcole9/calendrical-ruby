class FourFourFive::Year < Gregorian::Year

  def new_year
    FourFourFive::Date[year, 1, 1]
  end
  
  def year_end
    FourFourFive::Date[year, last_week_of_year, 7]
  end
 
  # see lines 1024-1032 in calendrica-3.0.cl
  # Return True if ISO year 'i_year' is a long (53-week) year.
  def self.long_year?(i_year)
    new(i_year).long_year?
  end
  
  def long_year?(i_year = self)
    jan1  = day_of_week(Gregorian::Year[i_year].new_year)
    dec31 = day_of_week(Gregorian::Year[i_year].year_end)
    (jan1 == THURSDAY) || (dec31 == THURSDAY)
  end
  
  def quarter(n)
    FourFourFive::Quarter[self.year, n]
  end
  
  def week(n) 
    FourFourFive::Week[self.year, n]
  end
  
  def last_week_of_year
    long_year?(year) ? 53 : 52
  end
  
end
