require './common'

$file = File::open("freq-table.rb", "w")

def generate_freq_table
  $file.printf("$freq_table = [\n  ")
  (0..127).each do |note_number|
    if note_number < NOTE_NUMBER_MIN || note_number > NOTE_NUMBER_MAX
      freq = 0
    else
      cent = (note_number * 100.0) - 6900.0
      hz = 440.0 * (2.0 ** (cent / 1200.0))
      freq = (hz * 256.0 * 256.0 / SAMPLING_RATE).round
#     delta_abs = ((base * (2.0 ** (detune.abs / 1200.0))).round - base).to_i
    end

    $file.printf("%5d,", freq)
    if note_number == 127
      $file.printf("\n")
    elsif note_number % 12 == 11
      $file.printf("\n  ")
    else
      $file.printf(" ")
    end
  end
  $file.printf("]\n\n")
end

generate_freq_table

$file.close
