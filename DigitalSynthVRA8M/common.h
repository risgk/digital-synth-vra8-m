#pragma once

const uint8_t  MIDI_CH         = 0;
const uint16_t SERIAL_SPEED    = 38400;
const uint16_t SAMPLING_RATE   = 15625;
const uint16_t FREQUENCY_MAX   = 7200;
const uint8_t  BIT_DEPTH       = 8;
const uint8_t  NOTE_NUMBER_MIN = 24;
const uint8_t  NOTE_NUMBER_MAX = 84;

const uint8_t  VCO_TUNE_RATE_TABLE_STEPS_BITS         = 6;
const uint8_t  VCO_TUNE_RATE_DENOMINATOR_BITS         = 16;
const uint8_t  VCO_PHASE_RESOLUTION_BITS              = 16;
const uint8_t  VCO_WAVE_TABLE_AMPLITUDE               = 96;
const uint8_t  VCO_WAVE_TABLE_SAMPLES_BITS            = 8;
const uint8_t  VCF_TABLE_FRACTION_BITS                = 14;
const uint16_t EG_LEVEL_MAX                           = (127 << 1) << 8;
const uint8_t  EG_CONTROLLER_STEPS_BITS               = 5;
const uint8_t  EG_DECAY_RELEASE_RATE_DENOMINATOR_BITS = 8;

const uint8_t DATA_BYTE_MAX         = 0x7F;
const uint8_t STATUS_BYTE_INVALID   = 0x7F;
const uint8_t DATA_BYTE_INVALID     = 0x80;
const uint8_t STATUS_BYTE_MIN       = 0x80;
const uint8_t NOTE_OFF              = 0x80;
const uint8_t NOTE_ON               = 0x90;
const uint8_t CONTROL_CHANGE        = 0xB0;
const uint8_t SYSTEM_MESSAGE_MIN    = 0xF0;
const uint8_t SYSTEM_EXCLUSIVE      = 0xF0;
const uint8_t TIME_CODE             = 0xF1;
const uint8_t SONG_POSITION         = 0xF2;
const uint8_t SONG_SELECT           = 0xF3;
const uint8_t TUNE_REQUEST          = 0xF6;
const uint8_t EOX                   = 0xF7;
const uint8_t REAL_TIME_MESSAGE_MIN = 0xF8;
const uint8_t ACTIVE_SENSING        = 0xFE;

const uint8_t LFO_RATE_EG_AMT   = 16;
const uint8_t VCO_COLOR_LFO_AMT = 17;
const uint8_t VCO_MIX_EG_AMT    = 18;
const uint8_t VCF_CUTOFF_EG_AMT = 19;
const uint8_t VCF_RESONANCE     = 20;
const uint8_t EG_ATTACK         = 21;
const uint8_t EG_DECAY_RELEASE  = 22;
const uint8_t EG_SUSTAIN        = 23;
const uint8_t LFO_RATE          = 24;
const uint8_t LFO_LEVEL_EG_COEF = 25;
const uint8_t VCO_MIX           = 26;
const uint8_t VCF_CUTOFF        = 27;
const uint8_t VCO_PULSE_WIDTH   = 28;
const uint8_t VCO_SAW_SHIFT     = 29;
const uint8_t VCO_PORTAMENTO    = 30;
const uint8_t VCA_GAIN          = 31;
const uint8_t ALL_NOTES_OFF     = 123;

#define INLINE inline __attribute__((always_inline))

INLINE uint8_t low_byte(uint16_t x) {
  return x & 0xFF;
}

INLINE uint8_t high_byte(uint16_t x) {
  return x >> 8;
}

INLINE int8_t high_sbyte(int16_t x) {
  return x >> 8;
}
