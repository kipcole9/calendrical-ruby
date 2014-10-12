class EgyptianDate < Calendar
  extend Calendrical::Mpf
  extend Calendrical::Days
  
  # see lines 520-525 in calendrica-3.0.cl
  def self.epoch
    fixed_from_jd(1448638)
  end
    
  def inspect
    "#{year}-#{month}-#{day} Egyptian"
  end
  
  def to_s
    month_name = I18n.t('egyptian.months')[month - 1]
    "#{day} #{month_name}, #{year}"
  end

  # see lines 527-536 in calendrica-3.0.cl
  # Return the fixed date corresponding to Egyptian date 'e_date'.
  def to_fixed(e_date = self)
    mmonth = e_date.month
    dday   = e_date.day
    yyear  = e_date.year
    epoch + (365*(yyear - 1)) + (30*(mmonth - 1)) + (dday - 1)
  end

  # see lines 538-553 in calendrica-3.0.cl
  def to_calendar(f_date = self.fixed)
    days = f_date - epoch
    yyear = 1 + quotient(days, 365)
    mmonth = 1 + quotient((days % 365), 30)
    dday = days - (365*(yyear - 1)) - (30*(mmonth - 1)) + 1
    Date.new(yyear, mmonth, dday)
  end
end
