MIDI_CH             = 0
SERIAL_SPEED        = 38400
SAMPLING_RATE       = 15625
BIT_DEPTH           = 8
NOTE_NUMBER_MIN     = 36
NOTE_NUMBER_MAX     = 96

SAMPLES_PER_CYCLE   = 256
WAVE_TABLE_ONE      = 48
LPF_TABLE_ONE       = 0x4000
EG_CHANGE_FACTOR    = 62758

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

VCF_CUTOFF_FREQUENCY  = 22
VCF_RESONANCE         = 23
VCF_ENVELOPE_AMOUNT   = 24
EG_ATTACK_TIME        = 25
EG_DECAY_TIME         = 26
EG_SUSTAIN_LEVEL      = 27
ALL_NOTES_OFF         = 123

def high_byte(ui_16)
  ui_16 >> 8
end

def low_byte(ui_16)
  ui_16 & 0xFF
end

def high_word(ui_32)
  ui_32 >> 16
end

def muls_16(a, b)
  # refs http://www.atmel.com/images/doc1631.pdf
  # result is approximated

  result = high_byte(low_byte(a) * high_byte(b))
  result += high_byte(high_byte(a) * low_byte(b))
  result += high_byte(a) * high_byte(b)
end
