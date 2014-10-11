require "#{File.dirname(__FILE__)}/numeric.rb"
require "#{File.dirname(__FILE__)}/astro/angle.rb"

module Calendrical
  module Locations
    extend Calendrical::Astro::Angle
    class Location 
      attr_accessor :latitude, :longitude, :elevation, :zone
      
      def initialize(latitude, longitude, elevation, zone)
        @latitude = latitude
        @longitude = longitude
        @elevation = elevation
        @zone = zone
      end
      
      def zone_in_seconds
        zone_in_minutes * 60
      end
      
      def zone_in_minutes
        zone_in_hours * 60
      end
      
      def zone_in_hours
        (zone * 24).floor
      end
      
    end
    
    MECCA       = Location.new(angle(21, 25, 24), angle(39, 49, 24), 298.meters, 3.hrs)
    JERUSALEM   = Location.new(31.8, 35.2, 800.meters, 2.hrs)
    BRUXELLES   = Location.new(angle(4, 21, 17), angle(50, 50, 47), 800.meters, 1.hr)
    URBANA      = Location.new(40.1, -88.2, 225.meters, -6.hrs)
    GREENWHICH  = Location.new(51.4777815, 0, 46.9.meters, 0.hrs)
    JAFFA       = Location.new(angle(32, 1, 60), angle(34, 45, 0), 0.meters, 2.hrs)
  end
end