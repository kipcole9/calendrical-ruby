module NationalRetailFederation
  class Week < ThirteenWeekQuarter::Week    
    delegate :config, to: :NationalRetailFederation
    
  end
end
