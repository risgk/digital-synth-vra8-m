require './common'
require './vco'
require './vcf'
require './vca'
require './eg'

$vco = VCO.new
$vcf = VCF.new
$vca = VCA.new
$eg = EG.new

class Synth
  def initialize
    @system_exclusive = false
    @system_data_remaining = 0
    @running_status = STATUS_BYTE_INVALID
    @first_data = DATA_BYTE_INVALID
    @note_number = 60
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
    level = $vco.clock
    eg_output = $eg.clock
    level = $vcf.clock(level, eg_output)
    level = $vca.clock(level, eg_output)
  end

  def real_time_message?(b)
    b >= REAL_TIME_MESSAGE_MIN
  end

  def system_message?(b)
    b >= SYSTEM_MESSAGE_MIN
  end

  def status_byte?(b)
    b >= STATUS_BYTE_MIN
  end

  def data_byte?(b)
    b <= DATA_BYTE_MAX
  end

  def note_on(note_number)
    pitch = note_number + $vco.coarse_tune
    if (pitch < (NOTE_NUMBER_MIN + 64) || pitch > (NOTE_NUMBER_MAX + 64))
      return
    end

    @note_number = note_number
    $vco.note_on(@note_number)
    $eg.note_on
  end

  def note_off(note_number)
    if (note_number == @note_number)
      $eg.note_off
    end
  end

  def sound_off
    $eg.sound_off
  end

  def reset_phase
    $vco.reset_phase
  end

  def control_change(controller_number, value)
    case (controller_number)
    when VCF_CUTOFF_FREQUENCY
      set_vcf_cutoff_frequency(value)
    when VCF_RESONANCE
      set_vcf_resonance(value)
    when VCF_ENVELOPE_AMOUNT
      set_vcf_envelope_amount(value)
    when EG_ATTACK_TIME
      set_eg_attack_time(value)
    when EG_DECAY_TIME
      set_decay_time(value)
    when EG_SUSTAIN_LEVEL
      set_eg_sustain_level(value)
    when ALL_NOTES_OFF
      all_notes_off(value)
    end
  end

  def set_vcf_cutoff_frequency(value)
    $vcf.set_cutoff_frequency(value)
  end

  def set_vcf_resonance(value)
    $vcf.set_resonance(value)
  end

  def set_vcf_envelope_amount(value)
    $vcf.set_envelope_amount(value)
  end

  def set_eg_attack_time(value)
    $eg.set_attack_time(value)
  end

  def set_decay_time(value)
    $eg.set_decay_time(value)
  end

  def set_eg_sustain_level(value)
    $eg.set_sustain_level(value)
  end

  def all_notes_off(value)
    $eg.note_off
  end
end
