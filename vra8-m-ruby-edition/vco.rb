require './common'
require './freq-table'
require './wave-table'

class VCO
  def initialize
    @wave_tables = $wave_tables_sawtooth
    @note_number = 60
    @phase = 0
    @freq = 0
  end

  def reset_phase
    @phase = 0
  end

  def note_on(note_number)
    @note_number = note_number
    update_freq
  end

  def clock
    @phase += @freq
    @phase &= 0xFFFF

    wave_table = @wave_tables[high_byte(@freq)]
    curr_index = high_byte(@phase)
    next_index = curr_index + 0x01
    next_index &= 0xFF
    curr_data = wave_table[curr_index]
    next_data = wave_table[next_index]

    next_weight = low_byte(@phase)
    if (next_weight == 0)
      level = curr_data << 8
    else
      curr_weight = 0x100 - next_weight
      level = (curr_data * curr_weight) + (next_data * next_weight)
    end

    level = (level / 2) * 2

    return level
  end

  def update_freq
    if (@note_number < NOTE_NUMBER_MIN || @note_number > NOTE_NUMBER_MAX)
      @freq = 0
    else
      @freq = $freq_table[@note_number]
    end
  end
end
