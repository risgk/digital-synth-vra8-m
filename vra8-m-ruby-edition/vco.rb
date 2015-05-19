require './common'
require './freq-table'
require './wave-table'

class VCO
  def initialize
    @target_pitch = NOTE_NUMBER_MIN << 8
    @pitch = NOTE_NUMBER_MIN << 8
    @phase = 0
    @freq = 0

    @pulse_saw_mix = 0
    @pulse_width = (0 + 128) << 8
    @pw_lfo_amt = 0 << 1
    @saw_shift = 0 << 8
    @ss_lfo_amt = 0 << 1

    @portamento_speed = 0
  end

  def set_pulse_saw_mix(pulse_saw_mix)
    @pulse_saw_mix = pulse_saw_mix
  end

  def set_pulse_width(pulse_width)
    @pulse_width = (pulse_width + 128) << 8
  end

  def set_pw_lfo_amt(pw_lfo_amt)
    @pw_lfo_amt = pw_lfo_amt << 1
  end

  def set_saw_shift(saw_shift)
    @saw_shift = saw_shift << 8
  end

  def set_ss_lfo_amt(ss_lfo_amt)
    @ss_lfo_amt = ss_lfo_amt << 1
  end

  def set_portamento(portamento)
    @portamento_speed = 128 >> (portamento >> 4)
  end

  def note_on(note_number)
    if (note_number < NOTE_NUMBER_MIN)
      @target_pitch = NOTE_NUMBER_MIN << 8
    elsif (note_number > NOTE_NUMBER_MAX)
      @target_pitch = NOTE_NUMBER_MAX << 8
    else
      @target_pitch = note_number << 8
    end
  end

  def clock(k_lfo)
    if (@pitch > @target_pitch + @portamento_speed)
      @pitch -= @portamento_speed
    elsif (@pitch < @target_pitch - @portamento_speed)
      @pitch += @portamento_speed
    else
      @pitch = @target_pitch
    end
    @freq = mul_h16($freq_table[high_byte(@pitch)], $tune_table[(low_byte(@pitch) >> 4)])

    @phase += @freq
    @phase &= (CYCLE_RESOLUTION - 1)

    pitch_high = high_byte(@pitch)
    saw_down   = +level_from_wave_table(@phase, pitch_high)
    saw_up     = -level_from_wave_table(
                    (@phase + @pulse_width - (k_lfo * @pw_lfo_amt)) & 0xFFFF, pitch_high)
    saw_down_2 = +level_from_wave_table(
                    (@phase + @saw_shift + (k_lfo * @ss_lfo_amt)) & 0xFFFF, pitch_high)
    a = saw_down * 127 + saw_up * (127 - @pulse_saw_mix) +
                         saw_down_2 * @pulse_saw_mix

    return high_sbyte(a) >> 1
  end

  def level_from_wave_table(phase, pitch_high)
    wave_table = $wave_tables[pitch_high]
    curr_index = high_byte(phase)
    next_index = curr_index + 0x01
    next_index &= 0xFF
    curr_data = wave_table[curr_index]
    next_data = wave_table[next_index]

    next_weight = low_byte(phase)
    if (next_weight == 0)
      level = curr_data
    else
      curr_weight = 0x100 - next_weight
      level = high_sbyte((curr_data * curr_weight) + (next_data * next_weight))
    end

    return level
  end
end
