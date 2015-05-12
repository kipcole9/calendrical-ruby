NationalRetailFederation = ThirteenWeekQuarter

module NationalRetailFederation
  def self.calendar_name
    :national_retail_federation
  end
  
  config do |c|
    c.calendar_type      = :'454'        # one of 445, 454, 544 defining weeks in a quarter
    c.starts_or_ends     = :starts       # define the :start of the year, or the :end of the year
    c.first_last_nearest = :first        # :first, :last, :nearest (:nearest to :start or :end of :month)
    c.day_of_week        = :sunday       # start (or end) the year on this day
    c.month_name         = :february     # start (or end) the year in this month
  end
end

  