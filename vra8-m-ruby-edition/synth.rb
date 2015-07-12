require_relative 'common'
require_relative 'voice'

class Synth
  def initialize
    @voice = Voice.new
    @note_number = NOTE_NUMBER_MIN
    @system_exclusive = false
    @system_data_remaining = 0
    @running_status = STATUS_BYTE_INVALID
    @first_data = DATA_BYTE_INVALID

    # Preset Lead
    control_change(LFO_RATE         , 64 )
    control_change(LFO_RATE_EG_AMT  , 64 )
    control_change(VCO_MIX          , 64 )
    control_change(VCO_MIX_EG_AMT   , 64 )
    control_change(VCO_PULSE_WIDTH  , 64 )
    control_change(VCO_SAW_SHIFT    , 64 )
    control_change(VCO_COLOR_EG_AMT , 64 )
    control_change(VCO_COLOR_LFO_AMT, 64 )
    control_change(VCF_CUTOFF       , 64 )
    control_change(VCF_CUTOFF_EG_AMT, 64 )
    control_change(VCF_RESONANCE    , 64 )
    control_change(VCA_GAIN         , 64 )
    control_change(EG_ATTACK        , 64 )
    control_change(EG_DECAY_RELEASE , 64 )
    control_change(EG_SUSTAIN       , 64 )
    control_change(PORTAMENTO       , 64 )
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
    return @voice.clock
  end

  private
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
    @note_number = note_number
    @voice.note_on(@note_number)
  end

  def note_off(note_number)
    if (@note_number == note_number)
      @note_number = 0xFF
      @voice.note_off
    end
  end

  def control_change(controller_number, controller_value)
    case (controller_number)
    when ALL_NOTES_OFF
      @note_number = 0xFF
      @voice.note_off
    else
      @voice.control_change(controller_number, controller_value)
    end
  end
end
