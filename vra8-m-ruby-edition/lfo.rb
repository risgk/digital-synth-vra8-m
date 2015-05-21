require_relative 'common'

class LFO
  def initialize
    @phase = 0x4000

    set_rate(0)
  end

  def set_rate(controller_value)
    @rate = (controller_value >> 2) + 1
  end

  def clock
    @phase += @rate
    @phase &= 0xFFFF
    if ((@phase & 0x8000) != 0)
      k = ~@phase + 0x10000
    else
      k = @phase
    end
    k -= 0x4000
    return high_sbyte(k) << 1
  end
end
