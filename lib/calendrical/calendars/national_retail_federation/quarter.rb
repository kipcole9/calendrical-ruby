module NationalRetailFederation
  class Quarter < ThirteenWeekQuarter::Quarter
    delegate :config, to: :NationalRetailFederation
  
    def month(n) 
      Month[year, n]
    end
  
    def week(n) 
      Week[year, n]
    end

  end
end
