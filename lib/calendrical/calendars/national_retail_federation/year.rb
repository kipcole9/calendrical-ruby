module Calendar
  module NationalRetailFederation
    class Year < ThirteenWeekQuarter::Year
      delegate :config, to: :'Calendar::NationalRetailFederation'
    
      def long_year?
        year_end - Year[year - 1 - offset_for_early_year_end].year_end > 364
      end
    
      def quarter(n)
        Quarter[self, n]
      end
  
      def month(n) 
        Month[self, n]
      end
  
      def week(n) 
        Week[self, n]
      end

    end
  
  end
end