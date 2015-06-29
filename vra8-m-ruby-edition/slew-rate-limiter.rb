require_relative 'common'

class SlewRateLimiter
  UPDATE_INTERVAL = 10

  def initialize
    @count = 0
    @level = NOTE_NUMBER_MIN << 8
    set_slew_time(NOTE_NUMBER_MIN)
  end

  def set_slew_time(controller_value)
    if (controller_value < 4)
      @slew_rate = 0x8000
    else
      @slew_rate = 33 - (controller_value >> 2)
    end
  end

  def clock(input)
    @count += 1
    if (@count >= UPDATE_INTERVAL)
      @count = 0
      if (@level > input + @slew_rate)
        @level -= @slew_rate
      elsif (@level + @slew_rate < input)
        @level += @slew_rate
      else
        @level = input
      end
    end
    return @level
  end
end
