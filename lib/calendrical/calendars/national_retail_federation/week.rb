module Calendar
  module NationalRetailFederation
    class Week < ThirteenWeekQuarter::Week    
      delegate :config, to: :'Calendar::NationalRetailFederation'
          
    end
  end
end