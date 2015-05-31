require_relative 'common'

class SlewRateLimiter
  UPDATE_INTERVAL = 5

  def initialize
    @count = 0
    @level = NOTE_NUMBER_MIN << 8
    set_slew_time(NOTE_NUMBER_MIN)
  end

  def set_slew_time(controller_value)
    @slew_rate = 0x8000 >> (controller_value >> 3)
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
