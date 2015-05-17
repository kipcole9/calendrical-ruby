module Calendar
  class Julian::Week < Gregorian::Week
    def +(other)
      start_date = start_of_week + (other * 7)
      week_number = ((start_date.to_fixed - Julian::Year[start_date.year].new_year.to_fixed) / 7) + 1
      Julian::Week[start_date.year, week_number]
    end
  
    def start_of_week
      start_day || Julian::Year[year].new_year + ((week - 1) * 7)
    end
  
    def end_of_week
      end_day || [start_of_week + 6, Julian::Year[year].year_end].min
    end

  end
end