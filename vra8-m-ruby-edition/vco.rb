require_relative 'common'
require_relative 'vco-table'

class VCO
  def initialize
    @phase = 0

    set_pulse_saw_mix(0)
    set_pulse_width(0)
    set_pw_lfo_amt(0)
    set_saw_shift(0)
    set_ss_lfo_amt(0)
  end

  def set_pulse_saw_mix(controller_value)
    @pulse_saw_mix = controller_value
  end

  def set_pulse_width(controller_value)
    @pulse_width = (controller_value + 128) << 8
  end

  def set_pw_lfo_amt(controller_value)
    @pw_lfo_amt = controller_value << 1
  end

  def set_saw_shift(controller_value)
    @saw_shift = controller_value << 8
  end

  def set_ss_lfo_amt(controller_value)
    @ss_lfo_amt = controller_value << 1
  end

  def clock(pitch_control, phase_control)
    coarse_pitch = high_byte(pitch_control)
    fine_pitch = low_byte(pitch_control)

    freq = mul_16_high($vco_freq_table[coarse_pitch], $vco_tune_table[fine_pitch >> 4])
    @phase += freq
    @phase &= (VCO_PHASE_RESOLUTION - 1)

    saw_down      = +get_level_from_wave_table(coarse_pitch, @phase)
    saw_up        = -get_level_from_wave_table(coarse_pitch,
                       (@phase + @pulse_width - (phase_control * @pw_lfo_amt)) & 0xFFFF)
    saw_down_copy = +get_level_from_wave_table(coarse_pitch,
                       (@phase + @saw_shift + (phase_control * @ss_lfo_amt)) & 0xFFFF)
    a = saw_down      * 127 +
        saw_up        * (127 - @pulse_saw_mix) +
        saw_down_copy * @pulse_saw_mix

    return high_sbyte(a) >> 1
  end

  def get_level_from_wave_table(coarse_pitch, phase)
    curr_index = high_byte(phase)
    next_index = curr_index + 0x01
    next_index &= 0xFF

    wave_table = $vco_wave_tables[coarse_pitch]
    curr_data = wave_table[curr_index]
    next_data = wave_table[next_index]

    curr_weight = 0x100 - low_byte(phase)
    next_weight = 0x100 - curr_weight

    if (next_weight == 0)
      level = curr_data
    else
      level = high_sbyte((curr_data * curr_weight) + (next_data * next_weight))
    end
    return level
  end
end
