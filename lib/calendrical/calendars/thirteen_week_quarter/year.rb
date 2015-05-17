module Calendar
  module ThirteenWeekQuarter
    class Year < Gregorian::Year
      delegate :config, to: :'Calendar::ThirteenWeekQuarter'
    
      def initialize(year)
        @year = year + offset_for_early_year_end
      end
      
      def new_year
        @new_year ||= if config.starts_or_ends == :starts
          calculated_anchor_day
        else
          year_end - length_of_year + 1
        end
      end
  
      def year_end
        @year_end ||= if config.starts_or_ends == :ends
          calculated_anchor_day
        else
          new_year + length_of_year - 1
        end
      end
  
      def long_year?
        @long_year ||= if config.starts_or_ends == :starts
          Year[year + 1].new_year - new_year > 364
        else
          year_end - Year[year_end.year - 1 - offset_for_early_year_end].year_end > 364
        end
      end
  
      def quarter(n)
        Quarter[self, n]
      end
  
      def month(n) 
        Month[self, n]
      end
  
      def week(n) 
        Week[self, n]
      end
    
      def weeks
        days / 7
      end

      def length_of_year
        days = weeks_in_quarter * quarters_in_year * days_in_week
        days += 7 if long_year?
        days
      end
  
      def weeks_in_quarter
        13
      end
  
    protected
      def offset_for_early_year_end
        (config.starts_or_ends == :ends && month_number < Calendrical::Months::JUNE) ? 1 : 0
      end

      def calculated_anchor_day
        send("#{config.first_last_nearest}_kday", start_or_end_day_number, Gregorian::Date[year, month_number, anchor_day])
      end
  
      # Return True if ISO year 'i_year' is a long (53-week) year.
      def self.long_year?(i_year)
        new(i_year).long_year?
      end
  
      def start_or_end_day_number
        Object.const_get("Calendrical::Days::#{config.day_of_week.upcase}")
      end
  
      def month_number
        Object.const_get("Calendrical::Months::#{config.month_name.upcase}")
      end
  
      def anchor_day
        case config.starts_or_ends
        when :starts
          1
        when :ends
          Gregorian::Month[self.year, month_number].last_day_of_month
        else
          raise "Invalid starts_or_ends"
        end
      end
    end
  end
end