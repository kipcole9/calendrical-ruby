module NationalRetailFederation
  class Year < ThirteenWeekQuarter::Year
    delegate :config, to: :class
    
    @@config = ThirteenWeekQuarter::Config.new.config do |c|
      c.calendar_type      = :'454'        # one of 445, 454, 544 defining weeks in a quarter
      c.starts_or_ends     = :ends         # define the :start of the year, or the :end of the year
      c.first_last_nearest = :nearest      # :first, :last, :nearest (:nearest to :start or :end of :month)
      c.day_of_week        = :saturday     # start (or end) the year on this day
      c.month_name         = :january      # start (or end) the year in this month
    end

    def long_year?
      year_end - Year[year - 1 - offset_for_early_year_end].year_end > 364
    end
    
    def config
      @@config
    end
  end
  
end