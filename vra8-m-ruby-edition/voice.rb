require_relative 'common'
require_relative 'vco'
require_relative 'vcf'
require_relative 'vca'
require_relative 'eg'
require_relative 'lfo'
require_relative 'slew-rate-limiter'

class Voice
  def initialize
    @vco = VCO.new
    @vcf = VCF.new
    @vca = VCA.new
    @eg = EG.new
    @lfo = LFO.new
    @srl = SlewRateLimiter.new
    @note_number = NOTE_NUMBER_MIN

    # Preset #1
    control_change(VCO_PULSE_SAW_MIX, 64 )
    control_change(VCO_PULSE_WIDTH,   0  )
    control_change(VCO_SAW_SHIFT,     64 )
    control_change(VCF_CUTOFF,        0  )
    control_change(VCF_RESONANCE,     127)
    control_change(VCF_EG_AMT,        127)
    control_change(VCA_GAIN,          64 )
    control_change(EG_ATTACK,         32 )
    control_change(EG_DECAY_RELEASE,  96 )
    control_change(EG_SUSTAIN,        127)
    control_change(LFO_RATE,          32 )
    control_change(LFO_VCO_COLOR_AMT, 32 )
    control_change(PORTAMENTO,        96 )
  end

  def note_on(note_number)
    @note_number = note_number
    @eg.note_on
  end

  def note_off
    @eg.note_off
  end

  def control_change(controller_number, controller_value)
    case (controller_number)
    when VCO_PULSE_SAW_MIX
      @vco.set_pulse_saw_mix(controller_value)
    when VCO_PULSE_WIDTH
      @vco.set_pulse_width(controller_value)
    when VCO_SAW_SHIFT
      @vco.set_saw_shift(controller_value)
    when VCF_CUTOFF
      @vcf.set_cutoff(controller_value)
    when VCF_RESONANCE
      @vcf.set_resonance(controller_value)
    when VCF_EG_AMT
      @vcf.set_cv_amt(controller_value)
    when VCA_GAIN
      @vca.set_gain(controller_value)
    when EG_ATTACK
      @eg.set_attack(controller_value)
    when EG_DECAY_RELEASE
      @eg.set_decay_release(controller_value)
    when EG_SUSTAIN
      @eg.set_sustain(controller_value)
    when LFO_RATE
      @lfo.set_rate(controller_value)
    when LFO_VCO_COLOR_AMT
      @vco.set_color_lfo_amt(controller_value)
    when PORTAMENTO
      @srl.set_slew_time(controller_value)
    when ALL_NOTES_OFF
      @eg.note_off
    end
  end

  def clock
    eg_output = @eg.clock
    lfo_output = @lfo.clock
    srl_output = @srl.clock(@note_number << 8)
    vco_output = @vco.clock(srl_output, lfo_output)
    vcf_output = @vcf.clock(vco_output, eg_output)
    vca_output = @vca.clock(vcf_output, eg_output)
    return vca_output
  end
end
