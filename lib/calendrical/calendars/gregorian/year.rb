module Calendar
  module Gregorian
    class Year < Calendrical::Calendar
      attr_accessor :year, :fixed

      include Calendrical::Kday
      include Calendrical::Ecclesiastical
      include Calendrical::Dates
    
      def initialize(year = ::Date.today.year)
        @year = year
      end
  
      def inspect
        range.inspect
      end
  
      def leap_year?
        @leap_year ||= (year % 4 == 0) && ![100, 200, 300].include?(year % 400)
      end
      alias :leap? :leap_year?

      def <=>(other)
        year <=> other.year
      end
  
      def range
        @range ||= new_year..year_end
      end
  
      def +(other)
        self.class[year + other]
      end
  
      def -(other)
        self.class[year - other]
      end

      def quarter(n)
        Gregorian::Quarter[self, n]
      end
  
      def month(n)
        Gregorian::Month[self, n]
      end
  
      def week(n)
        Gregorian::Week[self, n]
      end
  
      def weeks
        days.to_f / days_in_week
      end

      # Need to do a little traffic managment here since
      # we're going to be called sometimes with just a year
      # and sometimes with a date formation from the super class
      def date(g_year, g_month = nil, g_day = nil)
        the_year = g_year.is_a?(Fixnum) ? g_year : g_year.year
        if g_month && g_day
          Gregorian::Date[the_year, g_month, g_day]
        else
          Gregorian::Year[the_year]
        end
      end
    end
  end
end