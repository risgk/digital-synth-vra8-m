require_relative 'common'

class Glide
  def initialize
    @pitch = NOTE_NUMBER_MIN << 8
    @portamento_speed = 0
  end

  def set_portamento(controller_value)
    @portamento_speed = 128 >> (controller_value >> 4)
  end

  def clock(k_pitch_in)
    if (@pitch > k_pitch_in + @portamento_speed)
      @pitch -= @portamento_speed
    elsif (@pitch < k_pitch_in - @portamento_speed)
      @pitch += @portamento_speed
    else
      @pitch = k_pitch_in
    end

    return @pitch
  end
end
