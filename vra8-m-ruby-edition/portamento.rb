require_relative 'common'

class Portamento
  def initialize
    @target_pitch = NOTE_NUMBER_MIN << 8
    @current_pitch = NOTE_NUMBER_MIN << 8
    @portamento_speed = 0
  end

  def set_portamento(portamento)
    @portamento_speed = 128 >> (portamento >> 4)
  end

  def clock(note_number)
    target_pitch = note_number << 8

    if (@current_pitch > target_pitch + @portamento_speed)
      @current_pitch -= @portamento_speed
    elsif (@current_pitch < target_pitch - @portamento_speed)
      @current_pitch += @portamento_speed
    else
      @current_pitch = target_pitch
    end

    return @current_pitch
  end
end