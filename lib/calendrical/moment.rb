module Calendrical
  class Moment
    attr_accessor :moment, :zone
    
    def initialize(moment, location = nil)
      @moment = moment
      @zone = location.zone_in_seconds if location
    end
    
    # see lines 402-405 in calendrica-3.0.cl
    # Return fixed date from moment 'tee'.
    def date
      moment.floor
    end
    alias :fixed :date

    # see lines 407-410 in calendrica-3.0.cl
    # Return time from moment 'tee'.
    def time
      moment % 1
    end

    # see lines 412-419 in calendrica-3.0.cl
    # Return clock time hour:minute:second from moment 'tee'.
    def clock
      hour = (time * 24).floor
      minute = ((time * 24 * 60) % 60).floor
      second = (time * 24 * 60 * 60) % 60
      [hour, minute, second]
    end
    
    def to_time
      d = GregorianDate[date]
      c = clock
      Time.new(d.year, d.month, d.day, c.first, c.second, c.third, zone)
    end
  end
end