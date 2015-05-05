require './common'

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

def play_cdefgabc(c)
  play(12 + (c * 12), 1200)
  play(14 + (c * 12), 1200)
  play(16 + (c * 12), 1200)
  play(17 + (c * 12), 1200)
  play(19 + (c * 12), 1200)
  play(21 + (c * 12), 1200)
  play(23 + (c * 12), 1200)
  play(24 + (c * 12), 4800)
  wait(4800)
end

control_change(ALL_NOTES_OFF,        0)
control_change(VCF_CUTOFF_FREQUENCY, 0)
control_change(VCF_RESONANCE,        127)
control_change(VCF_ENVELOPE_AMOUNT,  127)
control_change(EG_ATTACK_TIME,       32)
control_change(EG_DECAY_TIME,        96)
control_change(EG_SUSTAIN_LEVEL,     0)
play_cdefgabc(2)
play_cdefgabc(3)
play_cdefgabc(4)
play_cdefgabc(5)
play_cdefgabc(6)
