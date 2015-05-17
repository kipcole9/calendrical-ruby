module Calendar
  module ThirteenWeekQuarter
    class Week < Gregorian::Week
      delegate :config, to: :'Calendar::ThirteenWeekQuarter'
    
      def initialize(year, week, start_day = nil, end_day = nil, quarter = nil)
        super
        raise(Calendrical::InvalidWeek, "Year #{year} is not a long year, there is no week 53") if !year.long_year? && week == 53
      end

      def +(other)
        start_date = start_of_week + (other * 7)
        week_number = ((start_date - Year[start_date.year].new_year) / 7) + 1
        ThirteenWeekQuarter::Week[start_date.year, week_number]
      end

      def start_of_week
        start_day || year.new_year + ((week - 1) * 7)
      end
  
      def end_of_week
        eow = start_of_week + 6
        eow = year.year_end if eow.year > year.year
        eow
      end
    end
  end
end