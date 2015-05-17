MIDI_CH             = 0
SERIAL_SPEED        = 38400
SAMPLING_RATE       = 15625
BIT_DEPTH           = 8
NOTE_NUMBER_MIN     = 36
NOTE_NUMBER_MAX     = 96

CYCLE_RESOLUTION    = 0x10000
SAMPLES_PER_CYCLE   = 256
WAVE_TABLE_ONE      = 104
LPF_TABLE_BITS      = 14

ON  = 127
OFF = 0

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
VCO_PW_LFO_AMT    = 16
VCO_SAW_SHIFT     = 17
VCO_SS_LFO_AMT    = 18
VCF_CUTOFF        = 19
VCF_RESONANCE     = 20
VCF_EG_AMT        = 21
LFO_RATE          = 22
EG_ATTACK         = 23
EG_DECAY          = 24
EG_SUSTAIN        = 25
PORTAMENTO        = 26
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

def mul_h16(x, y)
  # result is approximated
  result  = high_byte(low_byte(x) * high_byte(y))
  result += high_byte(high_byte(x) * low_byte(y))
  result += high_byte(x) * high_byte(y)
end

def muls_h16(x, y)
  # result is approximated
  result  = high_sbyte(low_byte(x) * high_sbyte(y))
  result += high_sbyte(high_sbyte(x) * low_byte(y))
  result += high_sbyte(x) * high_sbyte(y)
end

def mulsu_h16(x, y)
  # result is approximated
  result  = high_byte(low_byte(x) * high_byte(y))
  result += high_sbyte(high_sbyte(x) * low_byte(y))
  result += high_sbyte(x) * high_byte(y)
end
