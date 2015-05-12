module ThirteenWeekQuarter
  def self.set_default!
    ThirteenWeekQuarter.config {|c| }
  end
  
  def self.set_national_retail_federation!
    ThirteenWeekQuarter.config do |c|
      c.calendar_type      = :'454'        # one of 445, 454, 544 defining weeks in a quarter
      c.starts_or_ends     = :starts       # define the :start of the year, or the :end of the year
      c.first_last_nearest = :first        # :first, :last, :nearest (:nearest to :start or :end of :month)
      c.day_of_week        = :sunday       # start (or end) the year on this day
      c.month_name         = :february     # start (or end) the year in this month
    end
  end

  def self.set_cisco!
    ThirteenWeekQuarter.config do |c|
      c.calendar_type      = :'445'        # one of 445, 454, 544 defining weeks in a quarter
      c.starts_or_ends     = :ends         # define the :start of the year, or the :end of the year
      c.first_last_nearest = :last         # :first, :last, :nearest (:nearest to :start or :end of :month)
      c.day_of_week        = :saturday     # start (or end) the year on this day
      c.month_name         = :july         # start (or end) the year in this month
    end
  end

end