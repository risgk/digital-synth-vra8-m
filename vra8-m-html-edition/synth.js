var Synth = function() {
  this.initialize = function() {
    this.voice = new Voice();
    this.note_number = NOTE_NUMBER_MIN;
    this.system_exclusive = false;
    this.system_data_remaining = 0;
    this.running_status = STATUS_BYTE_INVALID;
    this.first_data = DATA_BYTE_INVALID;

    // Preset Lead
    this.control_change(VCO_PULSE_SAW_MIX, 64 );
    this.control_change(VCO_PULSE_WIDTH,   0  );
    this.control_change(VCO_SAW_SHIFT,     64 );
    this.control_change(VCF_CUTOFF,        0  );
    this.control_change(VCF_RESONANCE,     127);
    this.control_change(VCF_EG_AMT,        127);
    this.control_change(VCA_GAIN,          96 );
    this.control_change(EG_ATTACK,         32 );
    this.control_change(EG_DECAY_RELEASE,  96 );
    this.control_change(EG_SUSTAIN,        127);
    this.control_change(LFO_RATE,          32 );
    this.control_change(LFO_VCO_COLOR_AMT, 32 );
    this.control_change(PORTAMENTO,        96 );
  };

  this.receive = function(array) {
    console.log(array);
    for (var i = 0; i < array.length; i++) {
      this.receive_midi_byte(array[i]);
    }
  };

  this.receive_midi_byte = function(b) {
    if (this.is_data_byte(b)) {
      if (this.system_exclusive) {
        // do nothing
      } else if (this.system_data_remaining != 0) {
        this.system_data_remaining--;
      } else if (this.running_status == (NOTE_ON | MIDI_CH)) {
        if (!this.is_data_byte(this.first_data)) {
          this.first_data = b;
        } else if (b == 0) {
          this.note_off(this.first_data);
          this.first_data = DATA_BYTE_INVALID;
        } else {
          this.note_on(this.first_data);
          this.first_data = DATA_BYTE_INVALID;
        }
      } else if (this.running_status == (NOTE_OFF | MIDI_CH)) {
        if (!this.is_data_byte(this.first_data)) {
          this.first_data = b;
        } else {
          this.note_off(this.first_data);
          this.first_data = DATA_BYTE_INVALID;
        }
      } else if (this.running_status == (CONTROL_CHANGE | MIDI_CH)) {
        if (!this.is_data_byte(this.first_data)) {
          this.first_data = b;
        } else {
          this.control_change(this.first_data, b);
          this.first_data = DATA_BYTE_INVALID;
        }
      }
    } else if (this.is_system_message(b)) {
      switch (b) {
      case SYSTEthis.EXCLUSIVE:
        this.systethis.exclusive = true;
        this.running_status = STATUS_BYTE_INVALID;
        break;
      case EOX:
      case TUNE_REQUEST:
      case 0xF4:
      case 0xF5:
        this.systethis.exclusive = false;
        this.system_data_remaining = 0;
        this.running_status = STATUS_BYTE_INVALID;
        break;
      case TIME_CODE:
      case SONG_SELECT:
        this.systethis.exclusive = false;
        this.system_data_remaining = 1;
        this.running_status = STATUS_BYTE_INVALID;
        break;
      case SONG_POSITION:
        this.systethis.exclusive = false;
        this.system_data_remaining = 2;
        this.running_status = STATUS_BYTE_INVALID;
        break;
      }
    } else if (this.is_status_byte(b)) {
      this.system_exclusive = false;
      this.running_status = b;
      this.first_data = DATA_BYTE_INVALID;
    }
  };

  this.clock = function() {
    return this.voice.clock();
  };

  // private
  this.is_real_message = function(b) {
    return b >= REAL_MESSAGE_MIN;
  };

  this.is_system_message = function(b) {
    return b >= SYSTEM_MESSAGE_MIN;
  };

  this.is_status_byte = function(b) {
    return b >= STATUS_BYTE_MIN;
  };

  this.is_data_byte = function(b) {
    return b <= DATA_BYTE_MAX;
  };

  this.note_on = function(note_number) {
    this.note_number = note_number;
    this.voice.note_on(this.note_number);
  };

  this.note_off = function(note_number) {
    if (this.note_number == note_number) {
      this.note_number = 0xFF;
      this.voice.note_off();
    }
  };

  this.control_change = function(controller_number, controller_value) {
    switch (controller_number) {
    case ALL_NOTES_OFF:
      this.note_number = 0xFF;
      this.voice.note_off();
      break;
    default:
      this.voice.control_change(controller_number, controller_value);
      break;
    }
  };

  this.initialize();
};
