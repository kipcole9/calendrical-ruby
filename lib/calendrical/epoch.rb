module Calendrical
  module Epoch
    # # see lines 323-329 in calendrica-3.0.cl
    # # Epoch definition. I took it out explicitly from rd().
    # # Epoch definition. For Rata Diem, R.D., it is 0 (but any other reference
    # # would do.)
    def epoch_origin
      0
    end

    # Return rata diem (number of days since epoch) of moment in time, tee."""
    def rd(tee)
      tee - epoch_origin
    end
    
    # see lines 442-445 in calendrica-3.0.cl
    def jd_epoch
      rd(mpf(-1721424.5))
    end
    
    # see lines 467-470 in calendrica-3.0.cl
    def mjd_epoch
      rd(678576)
    end 
  end
end