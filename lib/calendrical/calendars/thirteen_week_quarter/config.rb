module ThirteenWeekQuarter
  def self.config(config_key = self.name, &block)
    Thread.current[:calendrical] ||= Hash.new
    Thread.current[:calendrical][config_key] ||= Config.new

    if block_given?
      yield Thread.current[:calendrical][config_key]
      Thread.current[:calendrical][config_key].validate_configuration!
    end

    Thread.current[:calendrical][config_key]
  end

  class Config
    attr_accessor :calendar_type, :starts_or_ends, :first_last_nearest, :day_of_week, :month_name
    
    def initialize
      @calendar_type      = :'445'        # one of 445, 454, 544 defining weeks in a quarter
      @starts_or_ends     = :starts       # define the :start of the year, or the :end of the year
      @first_last_nearest = :first        # :first, :last, :nearest (:nearest to :start or :end of :month)
      @day_of_week        = :sunday       # start (or end) the year on this day
      @month_name         = :january      # start (or end) the year in this month
      @month_offset       = []
      validate_configuration!
    end
    
    def weeks_in_month(month)
      calendar_type[month - 1].to_i
    end
    
    def offset_weeks_for_month(month)
      @month_offset[month]
    end
    
    def default!
      config {|c| }
    end
  
    def national_retail_federation!
      config do |c|
        c.calendar_type      = :'454'        # one of 445, 454, 544 defining weeks in a quarter
        c.starts_or_ends     = :ends         # define the :start of the year, or the :end of the year
        c.first_last_nearest = :last         # :first, :last, :nearest (:nearest to :start or :end of :month)
        c.day_of_week        = :saturday     # start (or end) the year on this day
        c.month_name         = :january      # start (or end) the year in this month
      end
    end

    def cisco!
      config do |c|
        c.calendar_type      = :'445'        # one of 445, 454, 544 defining weeks in a quarter
        c.starts_or_ends     = :ends         # define the :start of the year, or the :end of the year
        c.first_last_nearest = :last         # :first, :last, :nearest (:nearest to :start or :end of :month)
        c.day_of_week        = :saturday     # start (or end) the year on this day
        c.month_name         = :july         # start (or end) the year in this month
      end
    end
    
  private
    def config(*args)
      yield self
      self
    end
     
    def validate_configuration!
      raise(Calendrical::DayError,    "Invalid day of week '#{day_of_week}'. Valid days are '#{valid_days}'.") unless valid_days.include?(day_of_week.to_s.upcase.to_sym)
      raise(Calendrical::MonthError,  "Invalid month name '#{month_name}'. Valid months are '#{valid_months}'.") unless valid_months.include?(month_name.to_s.upcase.to_sym)
      raise(Calendrical::StartEnd,    "Calendar must :start or :end. ':#{starts_or_ends}' is invalid.") unless valid_start_or_end
      raise(Calendrical::Proximity,   "Calendar must be achored at the :first, :last or :nearest day. ':#{first_last_nearest}' is invalid") unless valid_proximity
      raise(Calendrical::Type,        "Invalid calendar type '#{calendar_type}'. Valid types are '445', '454' or '445'.") unless valid_calendar_type
      @month_offset[1] = 0
      @month_offset[2] = calendar_type[0].to_i
      @month_offset[3] = calendar_type[0].to_i + calendar_type[1].to_i
    end
  
    def valid_days
      Calendrical::Days.constants - [:TimeOfDay]
    end
  
    def valid_months
      Calendrical::Months.constants
    end
    
    def valid_start_or_end
      [:starts, :ends].include?(starts_or_ends.to_sym)
    end
    
    def valid_proximity
      [:first, :last, :nearest].include?(first_last_nearest.to_sym)
    end
    
    def valid_calendar_type
      [:'445', :'454', :'445'].include? calendar_type.to_sym
    end
  end
end