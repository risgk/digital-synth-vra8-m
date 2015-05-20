require_relative 'common'

$file = File::open("sample-midi-stream.bin", "wb")

def control_change(control_number, value)
    $file.write([(CONTROL_CHANGE | MIDI_CH), control_number, value].pack("C*"))
end

def play(note_number, length)
  $file.write([(NOTE_ON  | MIDI_CH), note_number, 64].pack("C*"))
  (length * 7 / 8).times { $file.write([ACTIVE_SENSING].pack("C")) }
  $file.write([(NOTE_OFF | MIDI_CH), note_number, 64].pack("C*"))
  (length * 1 / 8).times { $file.write([ACTIVE_SENSING].pack("C")) }
end

def wait(length)
  length.times { $file.write([ACTIVE_SENSING].pack("C")) }
end

def play_cegbdfac(c)
  play(12 + (c * 12), 1200)
  play(16 + (c * 12), 1200)
  play(19 + (c * 12), 1200)
  play(23 + (c * 12), 1200)
  play(14 + (c * 12), 1200)
  play(17 + (c * 12), 1200)
  play(21 + (c * 12), 1200)
  play(24 + (c * 12), 4800)
  wait(4800)
end

control_change(ALL_NOTES_OFF,     0  )

control_change(VCO_PULSE_SAW_MIX, 96 )
control_change(VCO_PULSE_WIDTH,   0  )
control_change(VCO_PW_LFO_AMT,    64 )
control_change(VCO_SAW_SHIFT,     64 )
control_change(VCO_SS_LFO_AMT,    32 )
control_change(VCF_CUTOFF,        0  )
control_change(VCF_RESONANCE,     127)
control_change(VCF_EG_AMT,        127)
control_change(EG_ATTACK,         64 )
control_change(EG_DECAY,          96 )
control_change(EG_SUSTAIN,        127)
control_change(LFO_RATE,          16 )
control_change(PORTAMENTO,        96 )

play_cegbdfac(2)
play_cegbdfac(4)
play_cegbdfac(3)
# play_cegbdfac(5)
# play_cegbdfac(6)
