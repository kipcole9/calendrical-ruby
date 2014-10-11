class BalineseDate < Calendar
  extend Calendrical::Mpf
  extend Calendrical::Days
  
  Date = Struct.new(:luang, :dwiwara, :triwara, :caturwara, :pancawara, :sadwara, :saptawara, :asatawara, :sangawara, :dasawara)
  delegate :luang, :dwiwara, :triwara, :caturwara, :pancawara, :sadwara, :saptawara, :asatawara, :sangawara, :dasawara, to: :elements
  
  # see lines 2523-2526 in calendrica-3.0.cl
  def self.epoch
    fixed_from_jd(146)
  end
  
  # Can only create Balinese date from fixed
  def initialize(fixed)
    @fixed = fixed
    @elements = to_calendar(self)
  end
    
  # see lines 2528-2531 in calendrica-3.0.cl
  # Return the position of date date in 210_day Pawukon cycle.
  def day_from_fixed(f_date = self.fixed)
    (f_date - epoch) % 210
  end

  # see lines 2533-2536 in calendrica-3.0.cl
  # Check membership of date date in "1_day" Balinese cycle.
  def luang_from_fixed(f_date = self.fixed)
    dasawara_from_fixed(f_date).even?
  end

  # see lines 2538-2541 in calendrica-3.0.cl
  # Return the position of date date in 2_day Balinese cycle.
  def dwiwara_from_fixed(f_date)
    amod(dasawara_from_fixed(f_date), 2)
  end

  # see lines 2543-2546 in calendrica-3.0.cl
  # Return the position of date date in 3_day Balinese cycle."""
  def triwara_from_fixed(f_date = self.fixed)
    (day_from_fixed(f_date) % 3) + 1
  end

  # see lines 2548-2551 in calendrica-3.0.cl
  # Return the position of date date in 4_day Balinese cycle.
  def caturwara_from_fixed(f_date)
    amod(asatawara_from_fixed(f_date), 4)
  end

  # see lines 2553-2556 in calendrica-3.0.cl
  # Return the position of date date in 5_day Balinese cycle.
  def pancawara_from_fixed(f_date)
    amod(day_from_fixed(f_date) + 2, 5)
  end

  # see lines 2558-2561 in calendrica-3.0.cl
  # Return the position of date date in 6_day Balinese cycle."""
  def sadwara_from_fixed(f_date)
    (day_from_fixed(f_date) % 6) + 1
  end

  # see lines 2563-2566 in calendrica-3.0.cl
  # Return the position of date date in Balinese week."""
  def saptawara_from_fixed(f_date)
    (day_from_fixed(f_date) % 7) + 1
  end

  # see lines 2568-2576 in calendrica-3.0.cl
  # Return the position of date date in 8_day Balinese cycle."""
  def asatawara_from_fixed(f_date)
    day = day_from_fixed(f_date)
    ([6, 4 + ((day - 70) % 210)].max % 8) + 1
  end

  # see lines 2578-2583 in calendrica-3.0.cl
  # Return the position of date date in 9_day Balinese cycle."""
  def sangawara_from_fixed(f_date)
    ([0, day_from_fixed(f_date) - 3].max % 9) + 1
  end

  # see lines 2585-2594 in calendrica-3.0.cl
  # Return the position of date date in 10_day Balinese cycle.
  def dasawara_from_fixed(f_date)
    i = pancawara_from_fixed(f_date) - 1
    j = saptawara_from_fixed(f_date) - 1
    (1 + [5, 9, 7, 4, 8][i] + [5, 4, 3, 7, 8, 6, 9][j]) % 10
  end

  # see lines 2596-2609 in calendrica-3.0.cl
  # Return the positions of date date in ten cycles of Balinese Pawukon
  # calendar.
  def pawukon_from_fixed(f_date = self)
    Date.new(luang_from_fixed(f_date),
             dwiwara_from_fixed(f_date),
             triwara_from_fixed(f_date),
             caturwara_from_fixed(f_date),
             pancawara_from_fixed(f_date),
             sadwara_from_fixed(f_date),
             saptawara_from_fixed(f_date),
             asatawara_from_fixed(f_date),
             sangawara_from_fixed(f_date),
             dasawara_from_fixed(f_date))
  end
  alias :to_calendar :pawukon_from_fixed

  # see lines 2611-2614 in calendrica-3.0.cl
  # Return the  week number of date date in Balinese cycle.
  def week_from_fixed(f_date)
    quotient(day_from_fixed(f_date), 7) + 1
  end

  # see lines 2616-2630 in calendrica-3.0.cl
  # Return last fixed date on or before date with Pawukon date b_date.
  def on_or_before(b_date, f_date)
    a5 = b_date.pancawara - 1
    a6 = b_date.sadwara   - 1
    b7 = b_date.saptawara - 1
    b35 = (a5 + 14 + (15 * (b7 - a5))) % 35
    days = a6 + (36 * (b35 - a6))
    cap_Delta = day_from_fixed(0)
    f_date - (f_date + cap_Delta - days) % 210
  end

  # see lines 2632-2646 in calendrica-3.0.cl
  # Return the list of occurrences of n-th day of c-day cycle in range.
  # cap_Delta is the position in cycle of RD 0.
  # TODO: Need to review the last line to understand how to translate the python
  def positions_in_range(n, c, cap_Delta, range)
    a = range.first # python start
    b = range.last  # python end
    pos = a + ((n - a - cap_Delta - 1) % c)
    # pos > b ? nil : [pos].extend(positions_in_range(n, c, cap_Delta, interval(pos + 1, b))))
  end

  # see lines 2648-2654 in calendrica-3.0.cl
  # Return the occurrences of Kajeng Keliwon (9th day of each
  # 15_day subcycle of Pawukon) in Gregorian year g_year.
  def kajeng_keliwon(g_year)
    yyear = gregorian_year_range(g_year)
    cap_Delta = bali_day_from_fixed(0)
    positions_in_range(9, 15, cap_Delta, year)
  end

  # see lines 2656-2662 in calendrica-3.0.cl
  # Return the occurrences of Tumpek (14th day of Pawukon and every
  # 35th subsequent day) within Gregorian year g_year.
  def tumpek(g_year)
    year = gregorian_year_range(g_year)
    cap_Delta = bali_day_from_fixed(0)
    positions_in_range(14, 35, cap_Delta, year)
  end
end
     