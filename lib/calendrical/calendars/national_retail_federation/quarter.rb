module Calendar
  module NationalRetailFederation
    class Quarter < ThirteenWeekQuarter::Quarter
      delegate :config, to: :'Calendar::NationalRetailFederation'
        
      def month(n) 
        Month[year, n]
      end
  
      def week(n) 
        Week[year, n]
      end

    end
  end
end