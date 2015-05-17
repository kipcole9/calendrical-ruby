module Calendar

  def self.year(year = nil)
    year ? use_calendar::Year[year] : use_calendar::Year
  end
  
  def self.date(*args)
    args.any? ? use_calendar::Date(*args) : use_calendar::Date
  end

  def self.set(calendar_type)
    Thread.current[:calendrical] ||= Hash.new
    Thread.current[:calendrical][:use] = calendar_type
  end
  
  def self.use_calendar
    Thread.current[:calendrical] ||= Hash.new
    Thread.current[:calendrical][:use] || Calendar::Gregorian
  end
  
  class Year
    def self.[](*args)
      Calendar.year[*args]
    end
  end
  
  class Date
    def self.[](*args)
      Calendar.date[*args]
    end
  end

end
