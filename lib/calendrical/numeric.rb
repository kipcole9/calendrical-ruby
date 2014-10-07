class Numeric
  def to_degrees
    self / Math::PI * 180
  end
  
  def to_radians
    self * Math::PI / 180
  end
  
  # Just tagging the value as meters
  def meters
    self
  end
  
  # Just tagging the value as degrees
  def degrees
    self
  end
end

class Fixnum
  def hrs
    self.to_f.hrs
  end
  alias :hr :hrs
  
  def secs
    self.to_f.secs
  end
  alias :sec :secs
  
  def to_gregorian
    GregorianDate[self]
  end
end

class Float
  # Hours expressed as fraction of day
  def hrs
    self / 24
  end
  alias :hr :hrs
  
  # Seconds expressed as fraction of a day
  def secs
    self / 3600
  end
  alias :sec :secs
end