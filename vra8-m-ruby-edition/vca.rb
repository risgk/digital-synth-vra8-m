require_relative 'common'

class VCA
  def clock(audio_input, gain_control)
    return high_sbyte(audio_input * gain_control)
  end
end
