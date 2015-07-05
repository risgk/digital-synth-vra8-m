MIDI_CH         = 0
SERIAL_SPEED    = 38400
SAMPLING_RATE   = 15625
FREQUENCY_MAX   = 7200
BIT_DEPTH       = 8
NOTE_NUMBER_MIN = 36
NOTE_NUMBER_MAX = 96

VCO_TUNE_RATE_TABLE_STEPS_BITS         = 6
VCO_TUNE_RATE_DENOMINATOR_BITS         = 16
VCO_PHASE_RESOLUTION_BITS              = 16
VCO_WAVE_TABLE_AMPLITUDE               = 96
VCO_WAVE_TABLE_SAMPLES_BITS            = 8
VCF_TABLE_FRACTION_BITS                = 14
EG_LEVEL_MAX                           = (127 << 1) << 8
EG_DECAY_RELEASE_RATE_DENOMINATOR_BITS = 8

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
VCA_GAIN          = 20
EG_ATTACK         = 21
EG_DECAY_RELEASE  = 22
EG_SUSTAIN        = 23
LFO_RATE          = 24
LFO_VCO_COLOR_AMT = 25
PORTAMENTO        = 26
ALL_NOTES_OFF     = 123

def low_byte(x)
  return x & 0xFF
end

def high_byte(x)
  return x >> 8
end

def high_sbyte(x)
  return x >> 8
end
