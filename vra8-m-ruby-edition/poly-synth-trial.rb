require_relative 'common'
require_relative 'voice'

class Synth
  def initialize
    @voices = [Voice.new, Voice.new, Voice.new, Voice.new]
    @note_numbers = [0xFF, 0xFF, 0xFF, 0xFF]
    @system_exclusive = false
    @system_data_remaining = 0
    @running_status = STATUS_BYTE_INVALID
    @first_data = DATA_BYTE_INVALID
  end

  def receive_midi_byte(b)
    if data_byte?(b)
      if (@system_exclusive)
        # do nothing
      elsif (@system_data_remaining != 0)
        @system_data_remaining -= 1
      elsif (@running_status == (NOTE_ON | MIDI_CH))
        if (!data_byte?(@first_data))
          @first_data = b
        elsif (b == 0x00)
          note_off(@first_data)
          @first_data = DATA_BYTE_INVALID
        else
          note_on(@first_data)
          @first_data = DATA_BYTE_INVALID
        end
      elsif (@running_status == (NOTE_OFF | MIDI_CH))
        if (!data_byte?(@first_data))
          @first_data = b
        else
          note_off(@first_data)
          @first_data = DATA_BYTE_INVALID
        end
      elsif (@running_status == (CONTROL_CHANGE | MIDI_CH))
        if (!data_byte?(@first_data))
          @first_data = b
        else
          control_change(@first_data, b)
          @first_data = DATA_BYTE_INVALID
        end
      end
    elsif (system_message?(b))
      case (b)
      when SYSTEM_EXCLUSIVE
        @system_exclusive = true
        @running_status = STATUS_BYTE_INVALID
      when EOX, TUNE_REQUEST, 0xF4, 0xF5
        @system_exclusive = false
        @system_data_remaining = 0
        @running_status = STATUS_BYTE_INVALID
      when TIME_CODE, SONG_SELECT
        @system_exclusive = false
        @system_data_remaining = 1
        @running_status = STATUS_BYTE_INVALID
      when SONG_POSITION
        @system_exclusive = false
        @system_data_remaining = 2
        @running_status = STATUS_BYTE_INVALID
      end
    elsif (status_byte?(b))
      @system_exclusive = false
      @running_status = b
      @first_data = DATA_BYTE_INVALID
    end
  end

  def clock
    return (@voices[0].clock + @voices[1].clock + @voices[2].clock + @voices[3].clock) >> 2
  end

  def real_message?(b)
    return b >= REAL_MESSAGE_MIN
  end

  def system_message?(b)
    return b >= SYSTEM_MESSAGE_MIN
  end

  def status_byte?(b)
    return b >= STATUS_BYTE_MIN
  end

  def data_byte?(b)
    return b <= DATA_BYTE_MAX
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
      @note_numbers[1] = 0xFF
      @note_numbers[2] = 0xFF
      @note_numbers[3] = 0xFF
      @voices[0].note_off
      @voices[1].note_off
      @voices[2].note_off
      @voices[3].note_off
    else
      @voices[0].control_change(controller_number, controller_value)
      @voices[1].control_change(controller_number, controller_value)
      @voices[2].control_change(controller_number, controller_value)
      @voices[3].control_change(controller_number, controller_value)
    end
  end
end
