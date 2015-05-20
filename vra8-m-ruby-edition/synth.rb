require_relative 'common'
require_relative 'vco'
require_relative 'vcf'
require_relative 'vca'
require_relative 'eg'
require_relative 'lfo'
require_relative 'portamento'

$vco = VCO.new
$vcf = VCF.new
$vca = VCA.new
$lfo = LFO.new
$eg = EG.new
$portamento = Portamento.new

class Synth
  def initialize
    @system_exclusive = false
    @system_data_remaining = 0
    @running_status = STATUS_BYTE_INVALID
    @first_data = DATA_BYTE_INVALID
    @note_number = NOTE_NUMBER_MIN
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
    k_eg = $eg.clock
    k_lfo = $lfo.clock
    pitch = $portamento.clock(@note_number)
    a = $vco.clock(pitch, k_lfo)
    a = $vcf.clock(a, k_eg)
    a = $vca.clock(a, k_eg)
    return a
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
    @note_number = note_number
    $eg.note_on
  end

  def note_off(note_number)
    if (note_number == @note_number)
      $eg.note_off
    end
  end

  def control_change(controller_number, control_value)
    case (controller_number)
    when VCO_PULSE_SAW_MIX
      $vco.set_pulse_saw_mix(control_value)
    when VCO_PULSE_WIDTH
      $vco.set_pulse_width(control_value)
    when VCO_PW_LFO_AMT
      $vco.set_pw_lfo_amt(control_value)
    when VCO_SAW_SHIFT
      $vco.set_saw_shift(control_value)
    when VCO_SS_LFO_AMT
      $vco.set_ss_lfo_amt(control_value)
    when VCF_CUTOFF
      $vcf.set_cutoff(control_value)
    when VCF_RESONANCE
      $vcf.set_resonance(control_value)
    when VCF_EG_AMT
      $vcf.set_eg_amt(control_value)
    when LFO_RATE
      $lfo.set_rate(control_value)
    when EG_ATTACK
      $eg.set_attack(control_value)
    when EG_DECAY
      $eg.set_decay(control_value)
    when EG_SUSTAIN
      $eg.set_sustain(control_value)
    when PORTAMENTO
      $portamento.set_portamento(control_value)
    when ALL_NOTES_OFF
      $eg.note_off
    end
  end
end
