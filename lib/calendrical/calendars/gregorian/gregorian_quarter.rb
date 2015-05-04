class GregorianQuarter < Calendar
  attr_accessor :year, :quarter, :fixed

  include Calendrical::Kday
  include Calendrical::Ecclesiastical
  include Calendrical::Dates
    
  def initialize(year, quarter)
    raise(Calendrical::InvalidQuarter, "Invalid quarter '#{quarter}' which must be between 1 and 4 inclusive") unless (1..4).include?(quarter.to_i)
    @year = year
    @quarter = quarter
  end
  
  def inspect
    "#{year}-Q#{quarter}"
  end

  def <=>(other)
    quarters <=> other.quarters
  end

  def range
    @range ||= case quarter
    when 1
      GregorianDate[year, 1, 1]..GregorianDate[year, 3, 31]
    when 2
      GregorianDate[year, 4, 1]..GregorianDate[year, 6, 30]
    when 3
      GregorianDate[year, 7, 1]..GregorianDate[year, 9, 30]
    when 4
      GregorianDate[year, 10, 1]..GregorianDate[year, 12, 31]
    end
  end

  def to_fixed
    range.first.fixed
  end 
  
  def each_day(&block)
    range.each(&block)
  end
  
  def +(other)
    absolute_quarters = quarters + other
    new_year = absolute_quarters / 4
    new_quarter = absolute_quarters % 4
    if new_quarter == 0
      new_quarter = 4 
      new_year = new_year - 1
    end
    self.class[new_year, new_quarter]
  end
  
  def -(other)
    self + -other
  end
  
  def quarters
    year * 4 + quarter
  end
end
