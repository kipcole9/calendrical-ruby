require "#{File.dirname(__FILE__)}/numeric.rb"

module Calendrical
  module Seasons    
    # see lines 3297-3300 in calendrica-3.0.cl
    SPRING = 0.degrees

    # see lines 3302-3305 in calendrica-3.0.cl
    SUMMER = 90.degrees

    # see lines 3307-3310 in calendrica-3.0.cl
    AUTUMN = 180.degrees

    # see lines 3312-3315 in calendrica-3.0.cl
    WINTER = 270.degrees
  end
end