module Iso
  class Quarter < Gregorian::Quarter
    # ISO Quarters are 13 weeks long (excepting when its a long year when the last quarter is 14 weeks long)
    def range
      @range ||= case quarter
      when 1
        Iso::Date[year, 1, 1]..Iso::Date[year, 13, 7]
      when 2
        Iso::Date[year, 14, 1]..Iso::Date[year, 26, 7]
      when 3
        Iso::Date[year, 27, 1]..Iso::Date[year, 39, 7]
      when 4
        Iso::Date[year, 40, 1]..Iso::Date[year, last_week_of_year, 7]
      end
    end
  
    def last_week_of_year
      Iso::Year[year].last_week_of_year
    end
  
    def week(n)
      raise(Calendrical::InvalidWeek, "Week must be between 1 and 13 for weeks in a quarter") unless (1..13).include? n.to_i  
      Iso::Week[year, (quarter * 13) + n.to_i - 1]
    end
  end
end
