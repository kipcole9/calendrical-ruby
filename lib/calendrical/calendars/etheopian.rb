module Etheopian
  def self.Date(*args)
    Etheopian::Date[*args]
  end
  
  class Date < Calendar
    using Calendrical::Numeric
    
    # see lines 1325-1328 in calendrica-3.0.cl
    def self.epoch
      Julian::Date[8.ce, AUGUST, 29].fixed
    end
   
    def inspect
      "#{year}-#{month}-#{day} Etheopian"
    end
  
    def to_s
      inspect
    end

    # see lines 1330-1339 in calendrica-3.0.cl
    # Return the fixed date corresponding to Ethiopic date 'e_date'.
    def to_fixed(e_date = self)
        mmonth = e_date.month
        dday   = e_date.day
        yyear  = e_date.year
        self.epoch + Coptic::Date[yyear, mmonth, dday].fixed - Coptic::Date.epoch
      end

    # see lines 1341-1345 in calendrica-3.0.cl
    # Return the Ethiopic date equivalent of fixed date 'date'.
    def to_calendar(f_date = self.fixed)
      Calendar::Date.new(*Coptic::Date[f_date + Coptic::Date.epoch - Etheopian::Date.epoch].to_calendar)
    end
  end
end