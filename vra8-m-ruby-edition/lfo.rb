require './common'

class LFO
  def initialize
    @phase = 0x4000
    @rate = 16
  end

  def set_rate(rate)
    @rate = (rate >> 2) + 1
  end

  def clock
    @phase += @rate
    @phase &= 0xFFFF

    if ((@phase & 0x8000) != 0)
      k = ~@phase + 0x10000
    else
      k = @phase
    end

    return high_sbyte(k << 1)
  end
end
