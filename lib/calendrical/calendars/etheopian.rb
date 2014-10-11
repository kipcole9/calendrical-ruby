class EtheopianDate < Calendar
  
  def inspect
    "#{year}-#{month}-#{day} Etheopian"
  end
  
  # see lines 1325-1328 in calendrica-3.0.cl
  def self.epoch
    JulianDate[8.ce, AUGUST, 29].fixed
  end

  # see lines 1330-1339 in calendrica-3.0.cl
  # Return the fixed date corresponding to Ethiopic date 'e_date'.
  def to_fixed(e_date)
      mmonth = e_date.month
      dday   = e_date.day
      yyear  = e_date.year
      Etheopian.epoch + CopticDate[yyear, mmonth, dday].fixed - CopticDate.epoch
    end

  # see lines 1341-1345 in calendrica-3.0.cl
  # Return the Ethiopic date equivalent of fixed date 'date'.
  def to_calendar(f_date)
    Date.new(*CopticDate[f_date + CopticDate.epoch - EtheopianDate.epoch].to_calendar)
  end
end