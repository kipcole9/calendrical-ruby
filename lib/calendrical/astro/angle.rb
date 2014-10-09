module Calendrical
  module Astro
    module Angle
      def angle(degrees, minutes, seconds)
        degrees.to_f + ((minutes.to_f + (seconds.to_f / 60)) / 60)
      end
    end
  end
end