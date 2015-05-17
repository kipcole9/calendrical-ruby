module Calendar
  class Gregorian::Month < Calendrical::Calendar
    attr_accessor :year, :month, :fixed
  
    def initialize(year, month)
      raise(Calendrical::InvalidMonth, "Invalid month '#{month}' which must be between 1 and 12 inclusive") unless (1..12).include?(month.to_i)
      @year = year.is_a?(Fixnum) ? Gregorian::Year(year) : year
      @month = month.to_i
    end
  
    def inspect
      range.inspect
    end

    def <=>(other)
      months <=> other.months
    end

    def range
      @range ||= start_of_month..end_of_month
    end
  
    def start_of_month
      Gregorian::Date[year.year, month, 1]
    end
  
    def end_of_month
      Gregorian::Date[year.year, month, last_day_of_month]
    end

    def +(other)
      absolute_months = months + other
      new_year = absolute_months / months_in_year
      new_month = absolute_quarters % months_in_year
      if new_month == 0
        new_month = DECEMBER
        new_year = new_year - 1
      end
      self.class[new_year, new_month]
    end
  
    def -(other)
      self + -other
    end
  
    def last_day_of_month
      case month
      when SEPTEMBER, APRIL, JUNE, NOVEMBER
        30
      when FEBRUARY
        year.leap_year? ? 29 : 28
      else
        31
      end
    end
  
    def week(n)
      start_day = range.first + ((n - 1) * days_in_week)
      raise(Calendrical::InvalidWeek, "Week #{n} doesn't lie within month #{month}'s range of #{range}") \
        unless range.include?(start_day)
      end_day = [start_day + 6, range.last].min
      Gregorian::Week[year, n, start_day, end_day]
    end
  
    def weeks
      days.to_f / days_in_week
    end
  
  protected
  
    def months
      year.year * months_in_year + month
    end

  end
end