#pragma once

const uint8_t  MIDI_CH         = 0;
const uint16_t SERIAL_SPEED    = 38400;
const uint16_t SAMPLING_RATE   = 15625;
const uint16_t FREQUENCY_MAX   = 7812;
const uint8_t  BIT_DEPTH       = 8;
const uint8_t  NOTE_NUMBER_MIN = 36;
const uint8_t  NOTE_NUMBER_MAX = 96;

const uint16_t VCO_TUNE_RATE_TABLE_STEPS         = 256;
const uint32_t VCO_TUNE_RATE_DENOMINATOR         = 65536;
const uint32_t VCO_PHASE_RESOLUTION              = 65536;
const uint16_t VCO_WAVE_TABLE_SAMPLES            = 256;
const uint8_t  VCF_TABLE_FRACTION_BITS           = 14;
const uint16_t EG_LEVEL_MAX                      = (127 << 1) << 8;
const uint32_t EG_DECAY_RELEASE_RATE_DENOMINATOR = 65536;

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

const uint8_t VCO_PULSE_SAW_MIX = 14;
const uint8_t VCO_PULSE_WIDTH   = 15;
const uint8_t VCO_SAW_SHIFT     = 16;
const uint8_t VCF_CUTOFF        = 17;
const uint8_t VCF_RESONANCE     = 18;
const uint8_t VCF_EG_AMT        = 19;
const uint8_t VCA_GAIN          = 20;
const uint8_t EG_ATTACK         = 21;
const uint8_t EG_DECAY_RELEASE  = 22;
const uint8_t EG_SUSTAIN        = 23;
const uint8_t LFO_RATE          = 24;
const uint8_t LFO_VCO_COLOR_AMT = 25;
const uint8_t PORTAMENTO        = 26;
const uint8_t ALL_NOTES_OFF     = 123;

inline uint8_t low_byte(uint16_t x) {
  return x & 0xFF;
}

inline uint8_t high_byte(uint16_t x) {
  return x >> 8;
}

inline int8_t high_sbyte(int16_t x) {
  return x >> 8;
}

// refs http://www.atmel.com/images/doc1631.pdf

inline uint16_t mul_q16_q16(uint16_t x, uint16_t y) {
  uint16_t result  = high_byte(low_byte(x) * high_byte(y));
  result          += high_byte(high_byte(x) * low_byte(y));
  result          += high_byte(x) * high_byte(y);
  return result;
}

inline int16_t mul_q15_q15(int16_t x, int16_t y) {
  int16_t result  = high_sbyte(low_byte(x) * high_sbyte(y));
  result         += high_sbyte(high_sbyte(x) * low_byte(y));
  result         += high_sbyte(x) * high_sbyte(y);
  return result;
}

inline int16_t mul_q15_q16(int16_t x, uint16_t y) {
  uint16_t result  = high_byte(low_byte(x) * high_byte(y));
  result          += high_sbyte(high_sbyte(x) * low_byte(y));
  result          += high_sbyte(x) * high_byte(y);
  return result;
}
