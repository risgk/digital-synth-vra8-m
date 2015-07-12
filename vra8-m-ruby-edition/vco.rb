require_relative 'common'
require_relative 'mul-q'
require_relative 'vco-table'

class VCO
  def initialize
    @wave_table = nil
    @phase = 0
    set_pulse_saw_mix(0)
    set_pulse_width(0)
    set_saw_shift(0)
    set_color_lfo_amt(0)
  end

  def set_pulse_saw_mix(controller_value)
    @pulse_saw_mix = controller_value
  end

  def set_pulse_width(controller_value)
    @pulse_width = (controller_value + 128) << 8
  end

  def set_saw_shift(controller_value)
    @saw_shift = controller_value << 8
  end

  def set_color_lfo_amt(controller_value)
    @color_lfo_amt = controller_value << 1
  end

  def clock(pitch_control, modulation_control)
    coarse_pitch = high_byte(pitch_control)
    fine_pitch = low_byte(pitch_control)

    @wave_table = $vco_wave_tables[coarse_pitch - (NOTE_NUMBER_MIN - 1)]
    freq = mul_q16_q16($vco_freq_table[coarse_pitch - (NOTE_NUMBER_MIN - 1)],
                       $vco_tune_rate_table[fine_pitch >>
                                            (8 - VCO_TUNE_RATE_TABLE_STEPS_BITS)])
    @phase += freq
    @phase %= (1 << VCO_PHASE_RESOLUTION_BITS)

    saw_down      = +get_saw_wave_level(@phase)
    saw_up        = -get_saw_wave_level(
                       (@phase + @pulse_width - (modulation_control * @color_lfo_amt)) %
                       (1 << VCO_PHASE_RESOLUTION_BITS))
    saw_down_copy = +get_saw_wave_level(
                       (@phase + @saw_shift + (modulation_control * @color_lfo_amt)) %
                       (1 << VCO_PHASE_RESOLUTION_BITS))
    mixed = saw_down      * 127 +
            saw_up        * (127 - @pulse_saw_mix) +
            saw_down_copy * @pulse_saw_mix

    return mixed >> 1
  end

  private
  def get_saw_wave_level(phase)
    curr_index = high_byte(phase)
    curr_data = @wave_table[curr_index]
    next_data = @wave_table[curr_index + 1]

    curr_weight = 0x100 - low_byte(phase)
    next_weight = 0x100 - curr_weight

    # lerp
    if (next_weight == 0)
      level = curr_data
    else
      level = high_sbyte((curr_data * curr_weight) + (next_data * next_weight))
    end

    return level
  end
end
