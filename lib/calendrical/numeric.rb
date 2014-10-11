class Numeric
  def to_degrees
    self / Math::PI * 180.0
  end
  
  def to_radians
    self * Math::PI / 180.0
  end
  
  # Just tagging the value as meters
  def meters
    self
  end
  
  # Just tagging the value as degrees
  def degrees
    self
  end

  def to_gregorian
    GregorianDate[self.to_i]
  end

  # Hours expressed as fraction of day
  def hrs
    self / 24.0
  end
  alias :hr :hrs
  
  # Seconds expressed as fraction of a day
  def secs
    self / 3600.0
  end
  alias :sec :secs
  
  # Julian Date markers
  def ce
    self
  end
  
  def bce
    -self
  end
end