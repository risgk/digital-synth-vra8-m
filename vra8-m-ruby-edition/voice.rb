require_relative 'common'
require_relative 'vco'
require_relative 'vcf'
require_relative 'vca'
require_relative 'eg'
require_relative 'lfo'
require_relative 'slew-limiter'

class Voice
  def initialize
    @vco = VCO.new
    @vcf = VCF.new
    @vca = VCA.new
    @eg = EG.new
    @lfo = LFO.new
    @slew_limiter = SlewLimiter.new

    @note_number = NOTE_NUMBER_MIN
  end

  def clock
    eg_output = @eg.clock
    lfo_output = @lfo.clock
    slew_limiter_output = @slew_limiter.clock(@note_number << 8)

    vco_output = @vco.clock(slew_limiter_output, lfo_output)
    vcf_output = @vcf.clock(vco_output, eg_output)
    vca_output = @vca.clock(vcf_output, eg_output)

    return vca_output
  end

  def note_on(note_number)
    @note_number = note_number
    @eg.note_on
  end

  def note_off(note_number)
    if (note_number == @note_number)
      @eg.note_off
    end
  end

  def control_change(controller_number, controller_value)
    case (controller_number)
    when VCO_PULSE_SAW_MIX
      @vco.set_pulse_saw_mix(controller_value)
    when VCO_PULSE_WIDTH
      @vco.set_pulse_width(controller_value)
    when VCO_PW_LFO_AMT
      @vco.set_pw_lfo_amt(controller_value)
    when VCO_SAW_SHIFT
      @vco.set_saw_shift(controller_value)
    when VCO_SS_LFO_AMT
      @vco.set_ss_lfo_amt(controller_value)
    when VCF_CUTOFF
      @vcf.set_cutoff(controller_value)
    when VCF_RESONANCE
      @vcf.set_resonance(controller_value)
    when VCF_EG_AMT
      @vcf.set_cv_amt(controller_value)
    when LFO_RATE
      @lfo.set_rate(controller_value)
    when EG_ATTACK
      @eg.set_attack(controller_value)
    when EG_DECAY
      @eg.set_decay(controller_value)
    when EG_SUSTAIN
      @eg.set_sustain(controller_value)
    when PORTAMENTO
      @slew_limiter.set_slew_time(controller_value)
    when ALL_NOTES_OFF
      @eg.note_off
    end
  end
end
