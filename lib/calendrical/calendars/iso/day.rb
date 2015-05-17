module Calendar
  module Iso
    class Date < Calendrical::Calendar
      Date = Struct.new(:year, :week, :day)
      delegate :year, :week, :day, to: :elements
  
      include Calendrical::Ecclesiastical
      include Calendrical::Kday
      include Calendrical::Dates
  
      def initialize(*args)
        super
        raise(Calendrical::InvalidWeek, "Year #{year} is not a long ISO year, there is no week 53") if !long_year?(year) && week == 53
        raise(Calendrical::InvalidWeek, "Week must be between 1 and 52, or 53 for a long ISO year") unless (1..53).include? week    
        raise(Calendrical::InvalidDay, "Day must be between 1 and 7") unless (1..7).include? day
      end
  
      def self.epoch
        rd(1)
      end

      # Format output as 2014-W40-3
      def inspect
        "#{year}-W#{week}-#{day}"
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
        nth_kday(week, SUNDAY, Gregorian::Date[year - 1, DECEMBER, 28].fixed) + day
      end

      # see lines 1007-1022 in calendrica-3.0.cl
      # Return the ISO date corresponding to the fixed date 'date'."""
      def to_calendar(date = self.fixed)
        approx = Gregorian::Date[date - 3].year #gregorian_year_from_fixed(date - 3)
        year   = date >= date(approx + 1, 1, 1).fixed ? approx + 1 : approx
        week   = 1 + quotient(date - date(year, 1, 1).fixed, 7)
        day    = amod(date - rd(0), 7)
        Date.new(year, week, day)
      end
  
      def long_year?(i_year = self)
        Iso::Year.long_year?(i_year)
      end
    end
  end
end