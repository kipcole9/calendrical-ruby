module Calendrical
  module Mpf
    # Python mpf() does arbitrary real calc
    # but I believe we need a minimum 50 bits of
    # precision which Ruby will give on all
    # 64 bit platforms I use
    def mpf(x)
      # BigDecimal.new(x, 10)
      x.to_f
      # x
    end
  end
end