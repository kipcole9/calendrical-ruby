# TODO Store the config in Redis if available.  We aim to support multiple configs and if
# the number is small then its all ok.  But if we have multiple threads and thousands of configs
# as we might in a multi-tenant environment then Thread.current isn't the place to keep it.
# Also one side affect is that we will cache config in each thread which is not ideal
# However this approach as implemented does ensure every account/tenant/config_key gets a consistent
# set of defaults
module FourFourFive
  def self.config(config_key = :default, &block)
    Thread.current[:calendrical] ||= Hash.new
    Thread.current[:calendrical][config_key] ||= Config.new
    
    if block_given?
      yield Thread.current[:calendrical][config_key]
      Thread.current[:calendrical][config_key].validate_configuration!
    end
    
    Thread.current[:calendrical][config_key]
  end
  
  class Config
    attr_accessor :calendar_type, :starts_or_ends, :first_or_last, :day_of_week, :month
    
    def initialize
      @calendar_type  = :'445'
      @starts_or_ends = :starts
      @first_or_last  = :first
      @day_of_week    = :sunday
      @month          = :january
    end
     
    def validate_configuration!
      
    end
  end
end