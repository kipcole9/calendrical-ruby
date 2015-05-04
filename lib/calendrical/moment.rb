module Calendrical
  class Moment
    attr_reader :moment, :zone
    alias :to_f :moment
    
    def initialize(moment, location = nil)
      @moment = moment
      @zone = location.zone_in_seconds if location
    end
    
    def to_time
      d = Gregorian::Date[date]
      c = clock
      Time.new(d.year, d.month, d.day, c.first, c.second, c.third, zone)
    end
    
    def to_hms
      h, m, s = clock
      "#{h}:#{m}:#{s}"
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

  private

    # see lines 412-419 in calendrica-3.0.cl
    # Return clock time hour:minute:second from moment 'tee'.
    def clock
      t = time
      hour = (t * 24).floor
      minute = ((t * 24 * 60) % 60).floor
      second = (t * 24 * 60 * 60) % 60
      [hour, minute, second]
    end
  end
end