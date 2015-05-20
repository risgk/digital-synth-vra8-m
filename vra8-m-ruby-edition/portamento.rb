require_relative 'common'

class Portamento
  def initialize
    @pitch = NOTE_NUMBER_MIN << 8
    @portamento_speed = 0
  end

  def set_portamento(controller_value)
    @portamento_speed = 128 >> (controller_value >> 4)
  end

  def clock(note_number)
    target_pitch = note_number << 8

    if (@pitch > target_pitch + @portamento_speed)
      @pitch -= @portamento_speed
    elsif (@pitch < target_pitch - @portamento_speed)
      @pitch += @portamento_speed
    else
      @pitch = target_pitch
    end

    return @pitch
  end
end
