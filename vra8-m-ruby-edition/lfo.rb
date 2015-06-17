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
    level = @phase
    if ((level & 0x8000) != 0)
      level = ~level + 0x10000
    end
    level -= 0x4000
    return high_sbyte(level << 1)
  end
end
