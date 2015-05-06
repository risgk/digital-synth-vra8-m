require './common'
require './vco'
require './vcf'
require './vca'
require './lfo'
require './eg'

$vco = VCO.new
$vcf = VCF.new
$vca = VCA.new
$lfo = LFO.new
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
    lfo_output = $lfo.clock
    eg_output = $eg.clock
    level = $vco.clock(lfo_output)
    level = $vcf.clock(level, eg_output)
    level = $vca.clock(level, eg_output)
  end

  def real_message?(b)
    b >= REAL_MESSAGE_MIN
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
    when VCO_PULSE_SAW_MIX
      $vco.set_pulse_saw_mix(value)
    when VCO_PULSE_WIDTH
      $vco.set_pulse_width(value)
    when VCO_PW_LFO_AMT
      $vco.set_pw_lfo_amt(value)
    when VCO_SAW_SHIFT
      $vco.set_saw_shift(value)
    when VCO_SS_LFO_AMT
      $vco.set_ss_lfo_amt(value)
    when VCF_CUTOFF
      $vcf.set_cutoff(value)
    when VCF_RESONANCE
      $vcf.set_resonance(value)
    when VCF_EG_AMT
      $vcf.set_eg_amt(value)
    when LFO_RATE
      $lfo.set_rate(value)
    when EG_ATTACK
      $eg.set_attack(value)
    when EG_DECAY
      $eg.set_decay(value)
    when EG_SUSTAIN
      $eg.set_sustain(value)
    when PORTAMENTO
      # todo
    when ALL_NOTES_OFF
      $eg.note_off
    end
  end
end
