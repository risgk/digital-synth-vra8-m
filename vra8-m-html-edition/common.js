"use strict";

const MIDI_CH                = 0;
const SERIAL_SPEED           = 38400;
const ORIGINAL_SAMPLING_RATE = 15625;
const FREQUENCY_MAX          = 7812;
const BIT_DEPTH              = 8;
const NOTE_NUMBER_MIN        = 36;
const NOTE_NUMBER_MAX        = 96;

const VCO_TUNE_RATE_TABLE_STEPS_BITS    = 6;
const VCO_TUNE_RATE_DENOMINATOR         = 65536;
const VCO_PHASE_RESOLUTION              = 65536;
const VCO_WAVE_TABLE_SAMPLES            = 256;
const VCF_TABLE_ONE                     = 16384;
const VCF_TABLE_FRACTION_BITS           = 14;
const EG_LEVEL_MAX                      = (127 << 1) << 8;
const EG_DECAY_RELEASE_RATE_DENOMINATOR = 256;

const DATA_BYTE_MAX         = 0x7F;
const STATUS_BYTE_INVALID   = 0x7F;
const DATA_BYTE_INVALID     = 0x80;
const STATUS_BYTE_MIN       = 0x80;
const NOTE_OFF              = 0x80;
const NOTE_ON               = 0x90;
const CONTROL_CHANGE        = 0xB0;
const SYSTEM_MESSAGE_MIN    = 0xF0;
const SYSTEM_EXCLUSIVE      = 0xF0;
const TIME_CODE             = 0xF1;
const SONG_POSITION         = 0xF2;
const SONG_SELECT           = 0xF3;
const TUNE_REQUEST          = 0xF6;
const EOX                   = 0xF7;
const REAL_TIME_MESSAGE_MIN = 0xF8;
const ACTIVE_SENSING        = 0xFE;

const VCO_PULSE_SAW_MIX = 14;
const VCO_PULSE_WIDTH   = 15;
const VCO_SAW_SHIFT     = 16;
const VCF_CUTOFF        = 17;
const VCF_RESONANCE     = 18;
const VCF_EG_AMT        = 19;
const VCA_GAIN          = 20;
const EG_ATTACK         = 21;
const EG_DECAY_RELEASE  = 22;
const EG_SUSTAIN        = 23;
const LFO_RATE          = 24;
const LFO_VCO_COLOR_AMT = 25;
const PORTAMENTO        = 26;
const ALL_NOTES_OFF     = 123;

var low_byte = function(x) {
  return x & 0xFF;
};

var high_byte = function(x) {
  return x >> 8;
};

var high_sbyte = function(x) {
  return x >> 8;
};
