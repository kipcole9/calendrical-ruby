class IsoWeek < GregorianWeek
    
  def initialize(year, week)
    super
    raise(Calendrical::InvalidWeek, "Year #{year} is not a long ISO year, there is no week 53") if !IsoYear.long_year?(year) && week == 53
  end

  def +(other)
    start_date = start_of_week + (other * 7)
    week_number = ((start_date.to_fixed - IsoYear[start_date.year].new_year.to_fixed) / 7) + 1
    IsoWeek[start_date.year, week_number]
  end

  def start_of_week
    IsoYear[year].new_year + ((week - 1) * 7)
  end
  
  def end_of_week
    end_of_week = start_of_week + 6
    end_of_week = IsoYear[year].year_end if end_of_week.year > year
    end_of_week
  end
  
end
