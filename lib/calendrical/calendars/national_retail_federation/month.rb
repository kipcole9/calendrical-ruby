module NationalRetailFederation
  class Month < ThirteenWeekQuarter::Month
    delegate :config, to: :NationalRetailFederation

    def week(n) 
      Week[year, n]
    end
    
  end
end
