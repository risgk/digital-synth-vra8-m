var Voice = function() {
  this.initialize = function() {
    this.vco = new VCO();
    this.vcf = new VCF();
    this.vca = new VCA();
    this.eg  = new EG();
    this.lfo = new LFO();
    this.srl = new SlewRateLimiter();
    this.note_number = NOTE_NUMBER_MIN;
  };

  this.note_on = function(note_number) {
    this.note_number = note_number;
    this.eg.note_on();
  };

  this.note_off = function() {
    this.eg.note_off();
  };

  this.control_change = function(controller_number, controller_value) {
/*
    switch (controller_number) {
    case VCO_PULSE_SAW_MIX:
      this.vco.set_pulse_saw_mix(controller_value);
      break;
    case VCO_PULSE_WIDTH:
      this.vco.set_pulse_width(controller_value);
      break;
    case VCO_SAW_SHIFT:
      this.vco.set_saw_shift(controller_value);
      break;
    case VCF_CUTOFF:
      this.vcf.set_cutoff(controller_value);
      break;
    case VCF_RESONANCE:
      this.vcf.set_resonance(controller_value);
      break;
    case VCF_EG_AMT:
      this.vcf.set_cv_amt(controller_value);
      break;
    case VCA_GAIN:
      this.vca.set_gain(controller_value);
      break;
    case EG_ATTACK:
      this.eg.set_attack(controller_value);
      break;
    case EG_DECAY_RELEASE:
      this.eg.set_decay_release(controller_value);
      break;
    case EG_SUSTAIN:
      this.eg.set_sustain(controller_value);
      break;
    case LFO_RATE:
      this.lfo.set_rate(controller_value);
      break;
    case LFO_VCO_COLOR_AMT:
      this.vco.set_color_lfo_amt(controller_value);
      break;
    case PORTAMENTO:
      this.srl.set_slew_time(controller_value);
      break;
    case ALL_NOTES_OFF:
      this.eg.note_off();
      break;
    }
*/
  };

  this.clock = function() {
/*
    var eg_output = this.eg.clock;
    var lfo_output = this.lfo.clock;
    var srl_output = this.srl.clock(this.note_number << 8);
    var vco_output = this.vco.clock(srl_output, lfo_output);
    var vcf_output = this.vcf.clock(vco_output, eg_output);
    var vca_output = this.vca.clock(vcf_output, eg_output);
    return high_sbyte(vca_output);
*/
    return this.vco.clock(this.note_number << 8, 0);
  };

  this.initialize();
};
