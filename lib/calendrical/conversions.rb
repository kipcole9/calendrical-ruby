module Calendrical
  module Conversions
    def to_julian
      Julian::Date(self.fixed)
    end
    
    def to_iso
      Iso::Date(self.fixed)
    end
    
    def to_chinese
      Chinese::Date(self.fixed)
    end
    
    def to_french_revolutionary
      FrenchRevolutionary::Date(self.fixed)
    end
    
    def to_coptic
      Coptic::Date(self.fixed)
    end
    
    def to_egyptian
      Egyptian::Date(self.fixed)
    end
    
    def to_etheopian
      Etheopian::Date(self.fixed)
    end
  end
end
  