require "#{File.dirname(__FILE__)}/numeric.rb"

module Calendrical
  module Locations
    Location = Struct.new(:latitude, :longitude, :elevation, :zone)
    
    def self.angle(degrees, minutes, seconds)
      degrees.to_f + ((minutes.to_f + (seconds.to_f / 60)) / 60)
    end
    
    MECCA       = Location.new(angle(21, 25, 24), angle(39, 49, 24), 298.meters, 3.hrs)
    JERUSALEM   = Location.new(31.8, 35.2, 800.meters, 2.hrs)
    BRUXELLES   = Location.new(angle(4, 21, 17), angle(50, 50, 47), 800.meters, 1.hr)
    URBANA      = Location.new(40.1, -88.2, 225.meters, -6.hrs)
    GREENWHICH  = Location.new(51.4777815, 0, 46.9.meters, 0.hrs)
  end
end