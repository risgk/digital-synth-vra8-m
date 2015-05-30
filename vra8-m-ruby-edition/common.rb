MIDI_CH         = 0
SERIAL_SPEED    = 38400
SAMPLING_RATE   = 15625
BIT_DEPTH       = 8
NOTE_NUMBER_MIN = 36
NOTE_NUMBER_MAX = 96

VCO_PHASE_RESOLUTION    = 0x10000
VCO_WAVE_TABLE_SAMPLES  = 256
VCO_WAVE_TABLE_PEAK     = 64
VCF_TABLE_FRACTION_BITS = 14
EG_LEVEL_MAX            = (127 << 1) << 8

DATA_BYTE_MAX         = 0x7F
STATUS_BYTE_INVALID   = 0x7F
DATA_BYTE_INVALID     = 0x80
STATUS_BYTE_MIN       = 0x80
NOTE_OFF              = 0x80
NOTE_ON               = 0x90
CONTROL_CHANGE        = 0xB0
SYSTEM_MESSAGE_MIN    = 0xF0
SYSTEM_EXCLUSIVE      = 0xF0
TIME_CODE             = 0xF1
SONG_POSITION         = 0xF2
SONG_SELECT           = 0xF3
TUNE_REQUEST          = 0xF6
EOX                   = 0xF7
REAL_TIME_MESSAGE_MIN = 0xF8
ACTIVE_SENSING        = 0xFE

VCO_PULSE_SAW_MIX = 14
VCO_PULSE_WIDTH   = 15
VCO_SAW_SHIFT     = 16
VCF_CUTOFF        = 17
VCF_RESONANCE     = 18
VCF_EG_AMT        = 19
EG_ATTACK         = 20
EG_DECAY_RELEASE  = 21
EG_SUSTAIN        = 22
LFO_RATE          = 23
LFO_VCO_COLOR_AMT = 24
PORTAMENTO        = 25
ALL_NOTES_OFF     = 123

def low_byte(x)
  x & 0xFF
end

def high_byte(x)
  x >> 8
end

def high_sbyte(x)
  x >> 8
end

# refs http://www.atmel.com/images/doc1631.pdf

def mul_q16_q16(x, y)
  result  = high_byte(low_byte(x) * high_byte(y))
  result += high_byte(high_byte(x) * low_byte(y))
  result += high_byte(x) * high_byte(y)
end

def mul_q15_q15(x, y)
  result  = high_sbyte(low_byte(x) * high_sbyte(y))
  result += high_sbyte(high_sbyte(x) * low_byte(y))
  result += high_sbyte(x) * high_sbyte(y)
end

def mul_q15_q16(x, y)
  result  = high_byte(low_byte(x) * high_byte(y))
  result += high_sbyte(high_sbyte(x) * low_byte(y))
  result += high_sbyte(x) * high_byte(y)
end
