module Calendar
  module Iso
    class Quarter < Gregorian::Quarter
      # ISO Quarters are 13 weeks long (excepting when its a long year when the last quarter is 14 weeks long)
      def range
        @range ||= case quarter
        when 1
          Iso::Date[year.year, 1, 1]..Iso::Date[year.year, 13, 7]
        when 2
          Iso::Date[year.year, 14, 1]..Iso::Date[year.year, 26, 7]
        when 3
          Iso::Date[year.year, 27, 1]..Iso::Date[year.year, 39, 7]
        when 4
          Iso::Date[year.year, 40, 1]..Iso::Date[year.year, last_week_of_year, 7]
        end
      end
  
      def last_week_of_year
        year.last_week_of_year
      end
     
      def week(n)
        raise(Calendrical::InvalidWeek, "Week #{n} isn't between 1 and 13 (or 14 for a long year in q4) for weeks in a quarter") \
          unless (1..13).include?(n.to_i) || (year.long_year? && quarter == 4 && week == 14)
        Iso::Week[year.year, ((quarter - 1) * 13) + n.to_i]
      end
    end
  end
end