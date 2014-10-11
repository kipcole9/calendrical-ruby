class IsoDate < Calendar
  Date = Struct.new(:year, :week, :day)
  delegate :year, :week, :day, to: :elements
  
  include Calendrical::Ecclesiastical
  include Calendrical::Kday
  include Calendrical::Dates
  
  # Format output as 2014-W40-3
  def inspect
    "#{year}-W#{week}-#{day} ISO"
  end

  def self.epoch
    rd(1)
  end

  # see lines 995-1005 in calendrica-3.0.cl
  # Return the fixed date equivalent to ISO date 'i_date'.
  def to_fixed(i_date = self)
    year = i_date.year
    week = i_date.week
    day  = i_date.day
    nth_kday(week, SUNDAY, GregorianDate[year - 1, DECEMBER, 28].fixed) + day
  end

  # see lines 1007-1022 in calendrica-3.0.cl
  # Return the ISO date corresponding to the fixed date 'date'."""
  def to_calendar(date = self.fixed)
    approx = GregorianDate[date - 3].year #gregorian_year_from_fixed(date - 3)
    year   = date >= date(approx + 1, 1, 1).fixed ? approx + 1 : approx
    week   = 1 + quotient(date - date(year, 1, 1).fixed, 7)
    day    = amod(date - rd(0), 7)
    Date.new(year, week, day)
  end

  # see lines 1024-1032 in calendrica-3.0.cl
  # Return True if ISO year 'i_year' is a long (53-week) year."""
  def long_year?(i_year)
    jan1  = day_of_week_from_fixed(gregorian_new_year(i_year))
    dec31 = day_of_week_from_fixed(gregorian_year_end(i_year))
    (jan1 == THURSDAY) || (dec31 == THURSDAY)
  end
  
protected

  def set_elements(*args)
    if args.first.is_a?(Date) 
      @elements = args.first
    else
      @elements = Date.new unless @elements
      members = Date.members
      members.length.times do |i|
        @elements.send "#{members[i]}=", args[i]
      end
    end
  end
end
