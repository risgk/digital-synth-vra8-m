require_relative 'common'
require_relative 'mul-q'
require_relative 'vco-table'

class VCO
  def initialize
    @wave_table = nil
    @phase = 0
    set_mix(0)
    set_mix_eg_amt(0)
    set_pulse_width(0)
    set_saw_shift(0)
    set_color_lfo_amt(0)
  end

  def set_mix(controller_value)
    @mix = controller_value
  end

  def set_mix_eg_amt(controller_value)
    @mix_eg_amt = controller_value
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

  def clock(pitch_control, mod_eg_control, mod_lfo_control)
    coarse_pitch = high_byte(pitch_control)
    fine_pitch = low_byte(pitch_control)

    @wave_table = $vco_wave_tables[coarse_pitch - (NOTE_NUMBER_MIN - 1)]
    freq = mul_q16_q16($vco_freq_table[coarse_pitch - (NOTE_NUMBER_MIN - 1)],
                       $vco_tune_rate_table[fine_pitch >>
                                            (8 - VCO_TUNE_RATE_TABLE_STEPS_BITS)])
    @phase += freq
    @phase %= (1 << VCO_PHASE_RESOLUTION_BITS)

    shift_lfo = (mod_lfo_control * @color_lfo_amt)
    saw_down      = +get_saw_wave_level(@phase)
    saw_up        = -get_saw_wave_level((@phase + @pulse_width - shift_lfo) %
                       (1 << VCO_PHASE_RESOLUTION_BITS))
    saw_down_copy = +get_saw_wave_level((@phase + @saw_shift + shift_lfo) %
                       (1 << VCO_PHASE_RESOLUTION_BITS))

    mix = @mix + high_byte(@mix_eg_amt * mod_eg_control)
    if (mix > 127)
      mix = 127
    end
    mixed = saw_down      * 127 +
            saw_up        * (127 - mix) +
            saw_down_copy * mix

    return mixed >> 1
  end

  private
  def get_saw_wave_level(phase)
    curr_index = high_byte(phase)
    curr_data = @wave_table[curr_index]
    next_data = @wave_table[curr_index + 1]
    next_weight = low_byte(phase)

    # lerp
    level = curr_data + high_sbyte((next_data - curr_data) * next_weight)

    return level
  end
end
