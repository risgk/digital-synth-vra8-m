var VCO = function() {
  const AMPLITUDE = 96;

  var freq_from_note_number = function(note_number) {
    var cent = (note_number * 100.0) - 6900.0;
    var hz = 440.0 * Math.pow(2.0, (cent / 1200.0));
    var freq = Math.floor(hz * VCO_PHASE_RESOLUTION / SAMPLING_RATE * 2.0);
    if ((freq % 2) == 1) {
      freq = freq + 1;
    }
    return freq;
  };

  this.vco_freq_table = [];
  for (var note_number = 0; note_number <= DATA_BYTE_MAX; note_number++) {
    var freq;
    if ((note_number < NOTE_NUMBER_MIN) || (note_number > NOTE_NUMBER_MAX)) {
      freq = 0;
    } else {
      freq = freq_from_note_number(note_number);
    };
    this.vco_freq_table[note_number] = freq;
  };

  this.vco_tune_rate_table = [];
  for (var i = 0; i <= Math.pow(2, VCO_TUNE_RATE_TABLE_STEPS_BITS) - 1; i++) {
    this.vco_tune_rate_table[i] =
      Math.round(Math.pow(2.0, (i / (12.0 * Math.pow(2, VCO_TUNE_RATE_TABLE_STEPS_BITS)))) *
                 VCO_TUNE_RATE_DENOMINATOR / 2.0)
  };

  var generate_vco_wave_table = function(wave_tables, note_number, last, callback) {
    var wave_table = new Int8Array(VCO_WAVE_TABLE_SAMPLES);
    for (var n = 0; n <= VCO_WAVE_TABLE_SAMPLES; n++) {
      var level = 0;
      for (var k = 1; k <= last; k++) {
        level += callback(n, k);
      };
      level = Math.round(level * AMPLITUDE);
      wave_table[n] = level;
    }
    wave_tables[note_number] = wave_table;
  };

  var generate_vco_wave_table_sawtooth = function(wave_tables, note_number, last) {
    generate_vco_wave_table(wave_tables, note_number, last, function(n, k) {
      return (2.0 / Math.PI) * Math.sin((2.0 * Math.PI) *
                                        ((n + 0.5) / VCO_WAVE_TABLE_SAMPLES) * k) / k;
    });
  };

  var vco_harmonics_restriction_table = [];
  for (var note_number = 0; note_number <= DATA_BYTE_MAX; note_number++) {
    var freq;
    if ((note_number < NOTE_NUMBER_MIN) || (note_number > NOTE_NUMBER_MAX)) {
      freq = 0;
    } else {
      freq = freq_from_note_number(note_number + 1);
    };
    vco_harmonics_restriction_table[note_number] = freq;
  };

  var last_harmonic = function(freq) {
    var last = (freq != 0) ? Math.round((FREQUENCY_MAX * VCO_PHASE_RESOLUTION) /
                                        (Math.round(freq / 2) * SAMPLING_RATE)) : 0;
    if (last > 127) {
      last = 127;
    }
    return last;
  };

  this.vco_wave_tables = [];
  for (var note_number = 0; note_number <= DATA_BYTE_MAX; note_number++) {
    var freq = vco_harmonics_restriction_table[note_number];
    var last = last_harmonic(freq);
    generate_vco_wave_table_sawtooth(this.vco_wave_tables, note_number, last);
  };

  this.initialize = function() {
    this.wave_table = null;
    this.phase = 0;
    this.set_pulse_saw_mix(0);
    this.set_pulse_width(0);
    this.set_saw_shift(0);
    this.set_color_lfo_amt(0);
  };

  this.set_pulse_saw_mix = function(controller_value) {
    this.pulse_saw_mix = controller_value;
  };

  this.set_pulse_width = function(controller_value) {
    this.pulse_width = (controller_value + 128) << 8;
  };

  this.set_saw_shift = function(controller_value) {
    this.saw_shift = controller_value << 8;
  };

  this.set_color_lfo_amt = function(controller_value) {
    this.color_lfo_amt = controller_value << 1;
  };

  this.clock = function(pitch_control, phase_control) {
    coarse_pitch = high_byte(pitch_control);
    fine_pitch = low_byte(pitch_control);

    this.wave_table = this.vco_wave_tables[coarse_pitch];
    freq = mul_q16_q16(this.vco_freq_table[coarse_pitch],
                       this.vco_tune_rate_table[fine_pitch >>
                                                (8 - VCO_TUNE_RATE_TABLE_STEPS_BITS)]);
    this.phase += freq;
    this.phase &= (VCO_PHASE_RESOLUTION - 1);

    saw_down      = +this.get_saw_wave_level(this.phase);
    saw_up        = -this.get_saw_wave_level(
                       (this.phase + this.pulse_width - (phase_control * this.color_lfo_amt)) & 0xFFFF);
    saw_down_copy = +this.get_saw_wave_level(
                       (this.phase + this.saw_shift + (phase_control * this.color_lfo_amt)) & 0xFFFF);
    mixed = saw_down      * 127 +
            saw_up        * (127 - this.pulse_saw_mix) +
            saw_down_copy * high_byte(this.pulse_saw_mix * 192);

    return mixed >> 1;
  };

  // private
  this.get_saw_wave_level = function(phase) {
    curr_index = high_byte(phase);
    curr_data = this.wave_table[curr_index];
    next_data = this.wave_table[curr_index + 1];

    curr_weight = 0x100 - low_byte(phase);
    next_weight = 0x100 - curr_weight;

    // lerp
    if (next_weight == 0) {
      level = curr_data;
    } else {
      level = high_sbyte((curr_data * curr_weight) + (next_data * next_weight));
    }

    return level;
  };

  this.initialize();
};
