require './common'
require './freq-table'
require './wave-table'

class VCO
  def initialize
    @wave_tables = $wave_tables_sawtooth
    @note_number = 60
    @phase = 0
    @freq = 0

    @mix = 64
    @pw = 128
    @pw_lfo_amt = 0
    @ss = 0
    @ss_lfo_amt = 0
  end

  def set_mix(mix)
    @mix = mix
  end

  def set_pw(pw)
    @pw = 128 - pw
  end

  def set_pw_lfo_amt(pw_lfo_amt)
    @pw_lfo_amt = 0
  end

  def set_ss(ss)
    @ss = 0
  end

  def set_ss_lfo_amt(ss_lfo_amt)
    @ss_lfo_amt = 0
  end

  def reset_phase
    @phase = 0
  end

  def note_on(note_number)
    @note_number = note_number
    update_freq
  end

  def clock(k)
    @phase += @freq
    @phase &= 0xFFFF

    # saw down
    level = level_from_wave_table(@phase)

    # saw up
    # todo

    # saw down 2
    # todo

    level = (level / 2) * 2  # todo

    return level
  end

  def update_freq
    if (@note_number < NOTE_NUMBER_MIN || @note_number > NOTE_NUMBER_MAX)
      @freq = 0
    else
      @freq = $freq_table[@note_number]
    end
  end

  def level_from_wave_table(phase)
    wave_table = @wave_tables[high_byte(@freq)]
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
      level = high_byte(curr_data * curr_weight + next_data * next_weight)
    end

    return level
  end
end
