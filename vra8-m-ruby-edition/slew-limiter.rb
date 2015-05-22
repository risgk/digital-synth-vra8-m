require_relative 'common'

class SlewLimiter
  def initialize
    @level = NOTE_NUMBER_MIN << 8
    set_slew_time(NOTE_NUMBER_MIN)
  end

  def set_slew_time(controller_value)
    @slew_rate = 128 >> (controller_value >> 4)
  end

  def clock(input)
    if (@level > input + @slew_rate)
      @level -= @slew_rate
    elsif (@level < input - @slew_rate)
      @level += @slew_rate
    else
      @level = input
    end
    return @level
  end
end
