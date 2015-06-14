var vco = new VCO();
var vcf = new VCF();
var vca = new VCA();
var eg = new EG();

var Synth = function() {
  this.receive = function(array) {
    console.log(array);
    for (var i = 0; i < array.length; i++) {
      this.receiveMIDIByte(array[i]);
    }
  };

  this.receiveMIDIByte = function(b) {
    if (this.IsDataByte(b)) {
      if (this.systemExclusive) {
        // do nothing
      } else if (this.systemDataRemaining != 0) {
        this.systemDataRemaining--;
      } else if (this.runningStatus == (NOTE_ON | midiCh)) {
        if (!this.IsDataByte(this.firstData)) {
          this.firstData = b;
        } else if (b == 0) {
          this.noteOff(this.firstData);
          this.firstData = DATA_BYTE_INVALID;
        } else {
          this.noteOn(this.firstData);
          this.firstData = DATA_BYTE_INVALID;
        }
      } else if (this.runningStatus == (NOTE_OFF | midiCh)) {
        if (!this.IsDataByte(this.firstData)) {
          this.firstData = b;
        } else {
          this.noteOff(this.firstData);
          this.firstData = DATA_BYTE_INVALID;
        }
      } else if (this.runningStatus == (CONTROL_CHANGE | midiCh)) {
        if (!this.IsDataByte(this.firstData)) {
          this.firstData = b;
        } else {
          this.controlChange(this.firstData, b);
          this.firstData = DATA_BYTE_INVALID;
        }
      }
    } else if (this.IsSystemMessage(b)) {
      switch (b) {
      case SYSTEM_EXCLUSIVE:
        this.systemExclusive = true;
        this.runningStatus = STATUS_BYTE_INVALID;
        break;
      case EOX:
      case TUNE_REQUEST:
      case 0xF4:
      case 0xF5:
        this.systemExclusive = false;
        this.systemDataRemaining = 0;
        this.runningStatus = STATUS_BYTE_INVALID;
        break;
      case TIME_CODE:
      case SONG_SELECT:
        this.systemExclusive = false;
        this.systemDataRemaining = 1;
        this.runningStatus = STATUS_BYTE_INVALID;
        break;
      case SONG_POSITION:
        this.systemExclusive = false;
        this.systemDataRemaining = 2;
        this.runningStatus = STATUS_BYTE_INVALID;
        break;
      }
    } else if (this.IsStatusByte(b)) {
      this.systemExclusive = false;
      this.runningStatus = b;
      this.firstData = DATA_BYTE_INVALID;
    }
  };

  this.clock = function() {
    var level = vco.clock();
    egOutput = eg.clock();
    level = vcf.clock(level, egOutput);
    level = vca.clock(level, egOutput);
    return level;
  };

  this.IsRealTimeMessage = function(b) {
    return b >= REAL_TIME_MESSAGE_MIN;
  };

  this.IsSystemMessage = function(b) {
    return b >= SYSTEM_MESSAGE_MIN;
  };

  this.IsStatusByte = function(b) {
    return b >= STATUS_BYTE_MIN;
  };

  this.IsDataByte = function(b) {
    return b <= DATA_BYTE_MAX;
  };

  this.noteOn = function(noteNumber) {
    this.noteNumber = noteNumber;
    vco.noteOn(this.noteNumber);
    vcf.noteOn(this.noteNumber);
    eg.noteOn();
  };

  this.noteOff = function(noteNumber) {
    if (noteNumber == this.noteNumber) {
      eg.noteOff();
    }
  };

  this.soundOff = function() {
    eg.soundOff();
  };

  this.resetPhase = function() {
    vco.resetPhase();
  };

  this.controlChange = function(controllerNumber, value) {
    switch (controllerNumber) {
    case ALL_NOTES_OFF:
      this.allNotesOff(value);
      break;
    case VCO_1_WAVEFORM:
      this.setVCO1Waveform(value);
      break;
    case VCO_1_COARSE_TUNE:
      this.setVCO1CoarseTune(value);
      break;
    case VCF_CUTOFF_FREQUENCY:
      this.setVCFCutoffFrequency(value);
      break;
    case VCF_RESONANCE:
      this.setVCFResonance(value);
      break;
    case VCF_ENVELOPE_AMOUNT:
      this.setVCFEnvelopeAmount(value);
      break;
    case FEG_ATTACK_TIME:
      this.setFEGAttackTime(value);
      break;
    case FEG_DECAY_TIME:
      this.setFEGDecayTime(value);
      break;
    case FEG_SUSTAIN_LEVEL:
      this.setFEGSustainLevel(value);
      break;
    case VCF_KEY_FOLLOW:
      this.setVCFKeyFollow(value);
      break;
    }
  };

  this.setVCO1Waveform = function(value) {
    this.soundOff();
    vco.setWaveform(value);
    this.resetPhase();
  };

  this.setVCO1CoarseTune = function(value) {
    this.soundOff();
    vco.setCoarseTune(value);
    this.resetPhase();
  };

  this.setVCFCutoffFrequency = function(value) {
    vcf.setCutoffFrequency(value);
  };

  this.setVCFResonance = function(value) {
    vcf.setResonance(value);
  };

  this.setVCFEnvelopeAmount = function(value) {
    vcf.setEnvelopeAmount(value);
  };

  this.setFEGAttackTime = function(value) {
    eg.setAttackTime(value);
  };

  this.setFEGDecayTime = function(value) {
    eg.setDecayTime(value);
  };

  this.setFEGSustainLevel = function(value) {
    eg.setSustainLevel(value);
  };

  this.setVCFKeyFollow = function(value) {
    vcf.setKeyFollow(value);
  };

  this.setFEGReleaseTime = function(value) {
    eg.setReleaseTime(value);
  };

  this.allNotesOff = function(value) {
    eg.noteOff();
  };

  this.systemExclusive     = false;
  this.systemDataRemaining = 0;
  this.runningStatus       = STATUS_BYTE_INVALID;
  this.firstData           = DATA_BYTE_INVALID;
  this.noteNumber          = 60;
};
