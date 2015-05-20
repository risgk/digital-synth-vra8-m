require_relative 'common'

class SlewLimiter
  def initialize
    @level = NOTE_NUMBER_MIN << 8
    @slew_rate = 0
  end

  def set_slew_time(controller_value)
    @slew_rate = 128 >> (controller_value >> 4)
  end

  def clock(k_in)
    if (@level > k_in + @slew_rate)
      @level -= @slew_rate
    elsif (@level < k_in - @slew_rate)
      @level += @slew_rate
    else
      @level = k_in
    end

    return @level
  end
end
