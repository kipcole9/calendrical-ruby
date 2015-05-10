# TODO Store the config in Redis if available.  We aim to support multiple configs and if
# the number is small then its all ok.  But if we have multiple threads and thousands of configs
# as we might in a multi-tenant environment then Thread.current isn't the place to keep it.
# Also one side affect is that we will cache config in each thread which is not ideal
# However this approach as implemented does ensure every account/tenant/config_key gets a consistent
# set of defaults
module FourFourFive
  def self.config(config_key = :default, &block)
    Thread.current[:calendrical] ||= Hash.new
    Thread.current[:calendrical][config_key] = Config.new
    if block_given?
      yield Thread.current[:calendrical][config_key]
      validate_configuration!
    end
    Thread.current[:calendrical][config_key]
  end
  
  class Config
    def calendar_type=(calendar_type)
      @calendar_type = calendar_type
    end 
   
    def calendar_type
      @calendar_type || :'445'
    end
     
    def starts_or_ends=(start_or_end)
      @starts_or_ends = start_or_end
    end 
   
    def starts_or_ends
      @starts_or_ends || :starts
    end
    
    def first_or_last=(anchor)
      @first_or_last = anchor
    end 
   
    def first_or_last
      @first_or_last || :first
    end
    
    def day_of_week=(day)
      @day_of_week = day
    end 
   
    def day_of_week
      @day_of_week || :sunday
    end
    
    def month=(anchor)
      @month = anchor
    end 
   
    def month
      @month || :january
    end
    
    def validate_configuration!
      
    end
  end
end