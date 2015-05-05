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
  end
end
  