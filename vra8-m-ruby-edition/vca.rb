require_relative 'common'

class VCA
  def initialize
    set_gain(96)
  end

  def set_gain(controller_value)
    @gain = controller_value << 1
  end

  def clock(audio_input, gain_control)
    g = high_byte(@gain * gain_control)
    return high_sbyte(audio_input * g)
  end
end
