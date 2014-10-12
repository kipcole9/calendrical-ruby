module Calendrical
  module Days
    SUNDAY        = 0
    MONDAY        = 1
    TUESDAY       = 2
    WEDNESDAY     = 3
    THURSDAY      = 4
    FRIDAY        = 5
    SATURDAY      = 6

    DAYS_OF_WEEK_NAMES = {
      sunday:   "Sunday",
      monday:   "Monday",
      tuesday:  "Tuesday",
      wednesday:"Wednesday",
      thursday: "Thursday",
      friday:   "Friday",
      saturday: "Saturday"
    }
    
    # see lines 366-369 in calendrica-3.0.cl
    # Return day of the week from a fixed date 'date'.
    def day_of_week_from_fixed(g_date = self.fixed)
      f_date = g_date.is_a?(Fixnum) ? g_date : g_date.to_fixed
      (f_date - rd(0) - SUNDAY) % 7
    end
    alias :day_of_week :day_of_week_from_fixed

    # see lines 386-388 in calendrica-3.0.cl
    # Return the time of day data structure.
    def time_of_day(hour, minute, second)
      [hour, minute, second]
    end

    # see lines 390-392 in calendrica-3.0.cl
    # Return the hour of clock time 'clock'."""
    def hour(clock)
      clock[0]
    end

    # see lines 394-396 in calendrica-3.0.cl
    # Return the minutes of clock time 'clock'."""
    def minute(clock)
      clock[1]
    end

    # see lines 398-400 in calendrica-3.0.cl
    # Return the seconds of clock time 'clock'."""
    def seconds(clock)
      clock[2]
    end

    # see lines 421-427 in calendrica-3.0.cl
    # Return time of day from clock time 'hms'."""
    def time_from_clock(hms)
      h = hour(hms)
      m = minute(hms)
      s = seconds(hms)
      (1/24.0 * (h + ((m + (s / 60.0)) / 60.0)))
    end

    # see lines 429-431 in calendrica-3.0.cl
    # Return the angular data structure."""
    def degrees_minutes_seconds(d, m, s)
      [d, m, s]
    end

    # see lines 433-440 in calendrica-3.0.cl
    # Return an angle in degrees:minutes:seconds from angle,
    # 'alpha' in degrees.
    def angle_from_degrees(alpha)
      d = floor(alpha)
      m = floor(60 * (alpha % 1))
      s = (alpha * 60 * 60) % 60
      degrees_minutes_seconds(d, m, s)
    end

    # see lines 447-450 in calendrica-3.0.cl
    # Return the moment corresponding to the Julian day number 'jd'."""
    def moment_from_jd(jd)
      jd + jd_epoch
    end

    # see lines 452-455 in calendrica-3.0.cl
    # Return the Julian day number corresponding to moment 'tee'.
    def jd_from_moment(tee)
      tee - jd_epoch
    end

    # see lines 457-460 in calendrica-3.0.cl
    # Return the fixed date corresponding to Julian day number 'jd'.
    def fixed_from_jd(jd)
      moment_from_jd(jd).floor
    end

    # see lines 462-465 in calendrica-3.0.cl
    # Return the Julian day number corresponding to fixed date 'rd'."""
    def jd_from_fixed(date)
      jd_from_moment(date)
    end

    # see lines 472-475 in calendrica-3.0.cl
    # Return the fixed date corresponding to modified Julian day 'mjd'.
    def fixed_from_mjd(mjd)
      mjd + MJD_EPOCH
    end

    # see lines 477-480 in calendrica-3.0.cl
    # "Return the modified Julian day corresponding to fixed date 'rd'."""
    def mjd_from_fixed(date)
      date - MJD_EPOCH
    end
  end
end
        