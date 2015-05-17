module Calendar

  def self.set(calendar_type)
    Thread.current[:calendrical] ||= Hash.new
    Thread.current[:calendrical][:use] = calendar_type
  end
  
  def self.use_calendar
    Thread.current[:calendrical] ||= Hash.new
    Thread.current[:calendrical][:use] || Calendar::Gregorian
  end
  
  def self.year(year = nil)
    year ? use_calendar::Year[year] : use_calendar::Year
  end
  
  def self.quarter(*args)
    args.any? ? use_calendar::Quarter(*args) : use_calendar::Quarter
  end
  
  def self.month(*args)
    args.any? ? use_calendar::Month(*args) : use_calendar::Month
  end
    
  def self.date(*args)
    args.any? ? use_calendar::Date(*args) : use_calendar::Date
  end

  class Year
    def self.[](*args)
      Calendar.year[*args]
    end
  end
  
  class Quarter
    def self.[](*args)
      Calendar.quarter[*args]
    end
  end
  
  class Month
    def self.[](*args)
      Calendar.month[*args]
    end
  end
  
  class Date
    def self.[](*args)
      Calendar.date[*args]
    end
  end

end
