module Iso
  class Week < Gregorian::Week    
    def initialize(year, week)
      super
      raise(Calendrical::InvalidWeek, "Year #{year.year} is not a long ISO year, there is no week 53") if !year.long_year? && week == 53
    end

    def +(other)
      start_date = start_of_week + (other * 7)
      week_number = ((start_date.to_fixed - Iso::Year[start_date.year].new_year.to_fixed) / 7) + 1
      Iso::Week[start_date.year, week_number]
    end

    def start_of_week
      year.new_year + ((week - 1) * 7)
    end
  
    def end_of_week
      end_of_week = start_of_week + 6
      end_of_week = year.year_end if end_of_week.year > year
      end_of_week
    end
  end
end
