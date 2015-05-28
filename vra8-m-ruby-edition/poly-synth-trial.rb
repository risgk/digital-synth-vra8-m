require_relative 'common'
require_relative 'vco'
require_relative 'vca'
require_relative 'eg'
require_relative 'slew-rate-limiter'
require_relative 'voice'
require_relative 'synth'

class SimpleVCO < VCO
  def clock(pitch_control, phase_control)
    coarse_pitch = high_byte(pitch_control)
    fine_pitch = low_byte(pitch_control)

    freq = mul_q16_q16($vco_freq_table[coarse_pitch], $vco_tune_table[fine_pitch >> 4])
    @phase += freq
    @phase &= (VCO_PHASE_RESOLUTION - 1)

    saw_down      = +get_level_from_wave_table(coarse_pitch, @phase)
    a = saw_down      * (127 + high_byte(127 * 192))

    return high_sbyte(a)
  end
end

class SimpleVoice < Voice
  def initialize
    @vco = SimpleVCO.new
    @vcf = VCF.new
    @vca = VCA.new
    @eg = EG.new
    @lfo = LFO.new
    @srl = SlewRateLimiter.new
    @note_number = NOTE_NUMBER_MIN
  end

  def clock
    eg_output = @eg.clock
    srl_output = @srl.clock(@note_number << 8)

    vco_output = @vco.clock(srl_output, 0)
    vca_output = @vca.clock(vco_output, eg_output)

    return vca_output
  end
end

class PolySynthTrial < Synth
  def initialize
    @voices = [SimpleVoice.new, SimpleVoice.new, SimpleVoice.new, SimpleVoice.new]
    @note_numbers = [0xFF, 0xFF, 0xFF, 0xFF]
    @system_exclusive = false
    @system_data_remaining = 0
    @running_status = STATUS_BYTE_INVALID
    @first_data = DATA_BYTE_INVALID
  end

  def clock
    return (@voices[0].clock + @voices[1].clock + @voices[2].clock + @voices[3].clock) >> 1
  end

  def note_on(note_number)
    if (@note_numbers[0] == 0xFF)
      @note_numbers[0] = note_number
      @voices[0].note_on(@note_numbers[0])
      return
    end
    if (@note_numbers[1] == 0xFF)
      @note_numbers[1] = note_number
      @voices[1].note_on(@note_numbers[1])
      return
    end
    if (@note_numbers[2] == 0xFF)
      @note_numbers[2] = note_number
      @voices[2].note_on(@note_numbers[2])
      return
    end
    if (@note_numbers[3] == 0xFF)
      @note_numbers[3] = note_number
      @voices[3].note_on(@note_numbers[3])
      return
    end
  end

  def note_off(note_number)
    if (@note_numbers[0] == note_number)
      @note_numbers[0] = 0xFF
      @voices[0].note_off
    end
    if (@note_numbers[1] == note_number)
      @note_numbers[1] = 0xFF
      @voices[1].note_off
    end
    if (@note_numbers[2] == note_number)
      @note_numbers[2] = 0xFF
      @voices[2].note_off
    end
    if (@note_numbers[3] == note_number)
      @note_numbers[3] = 0xFF
      @voices[3].note_off
    end
  end

  def control_change(controller_number, controller_value)
    case (controller_number)
    when ALL_NOTES_OFF
      @note_numbers[0] = 0xFF
      @voices[0].note_off
      @note_numbers[1] = 0xFF
      @voices[1].note_off
      @note_numbers[2] = 0xFF
      @voices[2].note_off
      @note_numbers[3] = 0xFF
      @voices[3].note_off
    else
      @voices[0].control_change(controller_number, controller_value)
      @voices[1].control_change(controller_number, controller_value)
      @voices[2].control_change(controller_number, controller_value)
      @voices[3].control_change(controller_number, controller_value)
    end
  end
end
