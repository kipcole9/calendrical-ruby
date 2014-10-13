module Calendrical
  module Astro
    module Angle
      DegreeMinuteSecond = Struct.new(:degree, :minute, :second)
      
      def angle(degrees, minutes, seconds)
        degrees.to_f + ((minutes.to_f + (seconds.to_f / 60)) / 60)
      end
      
      # see lines 429-431 in calendrica-3.0.cl
      # Return the angular data structure."""
      def degrees_minutes_seconds(d, m, s)
        DegreeMinuteSecond.new(d, m, s)
      end

      # see lines 433-440 in calendrica-3.0.cl
      # Return an angle in degrees:minutes:seconds from angle,
      # 'alpha' in degrees.
      def angle_from_degrees(alpha)
        d = floor(alpha)
        m = floor(60 * (alpha % 1))
        s = (alpha * 60 * 60) % 60
        degrees_minutes_seconds(d, m, s)
      end
      
    end
  end
end