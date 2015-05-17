module Calendar
  module NationalRetailFederation
    class Month < ThirteenWeekQuarter::Month
      delegate :config, to: :'Calendar::NationalRetailFederation'
      
      def week(n) 
        Week[year, n]
      end
    
    end
  end
end