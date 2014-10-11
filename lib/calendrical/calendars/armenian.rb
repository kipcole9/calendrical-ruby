class ArmenianDate < Calendar
  
  def inspect
    "#{year}-#{month}-#{day} Armenian"
  end
  
  # see lines 560-564 in calendrica-3.0.cl
  def self.epoch
    rd(201443)
  end

  # see lines 566-575 in calendrica-3.0.cl
  # Return the fixed date corresponding to Armenian date 'a_date'.
  def to_fixed(a_date = self)
    mmonth = a_date.month
    dday   = a_date.day
    yyear  = a_date.year
    ArmenianDate.epoch + EgyptianDate[yyear, mmonth, dday].fixed - EgyptianDate.epoch
  end

  # see lines 577-581 in calendrica-3.0.cl
  # Return the Armenian date corresponding to fixed date 'f_date'.
  def to_calendar(f_date = self.fixed)
    Date.new(*EgyptianDate[f_date + EgyptianDate.epoch - ArmenianDate.epoch].to_calendar)
  end
  
end