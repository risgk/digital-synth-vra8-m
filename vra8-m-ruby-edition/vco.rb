require_relative 'common'
require_relative 'vco-table'

class VCO
  def initialize
    @phase = 0
    @wave_table = nil
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

  def clock(pitch_control, phase_control)
    coarse_pitch = high_byte(pitch_control)
    fine_pitch = low_byte(pitch_control)

    freq = mul_q16_q16($vco_freq_table[coarse_pitch],
                       $vco_tune_rate_table[fine_pitch >>
                                            (8 - VCO_TUNE_RATE_TABLE_STEPS_BITS)])
    @wave_table = $vco_wave_tables[coarse_pitch]
    @phase += freq
    @phase &= (VCO_PHASE_RESOLUTION - 1)

    saw_down      = +get_level_from_wave_table(@phase)
    saw_up        = -get_level_from_wave_table(
                       (@phase + @pulse_width - (phase_control * @color_lfo_amt)) & 0xFFFF)
    saw_down_copy = +get_level_from_wave_table(
                       (@phase + @saw_shift + (phase_control * @color_lfo_amt)) & 0xFFFF)
    output = saw_down      * 127 +
             saw_up        * (127 - @pulse_saw_mix) +
             saw_down_copy * high_byte(@pulse_saw_mix * 192)

    return high_sbyte(output) >> 1
  end

  private

  def get_level_from_wave_table(phase)
    curr_index = high_byte(phase)
    next_index = curr_index + 0x01
    next_index &= 0xFF

    curr_data = @wave_table[curr_index]
    next_data = @wave_table[next_index]

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
