require_relative 'common'

$file = File.open("vco-table.rb", "w")

def freq_from_note_number(note_number)
  cent = (note_number * 100.0) - 6900.0
  hz = 440.0 * (2.0 ** (cent / 1200.0))
  freq = (hz * (1 << VCO_PHASE_RESOLUTION_BITS) / SAMPLING_RATE * 2.0).floor
  freq = freq + 1 if freq.odd?
  freq
end

$file.printf("$vco_freq_table = [\n  ")
((NOTE_NUMBER_MIN - 1)..NOTE_NUMBER_MAX).each do |note_number|
  if (note_number < (NOTE_NUMBER_MIN - 1)) || (note_number > NOTE_NUMBER_MAX)
    freq = 0
  else
    freq = freq_from_note_number(note_number)
  end

  $file.printf("%5d,", freq)
  if note_number == DATA_BYTE_MAX
    $file.printf("\n")
  elsif note_number % 12 == 11
    $file.printf("\n  ")
  else
    $file.printf(" ")
  end
end
$file.printf("]\n\n")

$file.printf("$vco_tune_rate_table = [\n  ")
(0..(1 << VCO_TUNE_RATE_TABLE_STEPS_BITS) - 1).each do |i|
  tune_rate = ((2.0 ** (i / (12.0 * (1 << VCO_TUNE_RATE_TABLE_STEPS_BITS)))) *
               (1 << VCO_TUNE_RATE_DENOMINATOR_BITS) / 2.0).round

  $file.printf("%5d,", tune_rate)
  if i == (1 << VCO_TUNE_RATE_TABLE_STEPS_BITS) - 1
    $file.printf("\n")
  elsif i % 8 == 7
    $file.printf("\n  ")
  else
    $file.printf(" ")
  end
end
$file.printf("]\n\n")

def generate_vco_wave_table_sawtooth(last)
  $file.printf("$vco_wave_table_%d = [\n  ", last)
  (0..(1 << VCO_WAVE_TABLE_SAMPLES_BITS)).each do |n|
    level = 0
    (1..last).each do |k|
      level += (2.0 / Math::PI) * Math.sin((2.0 * Math::PI) * ((n + 0.5) /
               (1 << VCO_WAVE_TABLE_SAMPLES_BITS)) * k) / k
    end
    level = (level * VCO_WAVE_TABLE_AMPLITUDE).round.to_i

    $file.printf("%+4d,", level)
    if n == (1 << VCO_WAVE_TABLE_SAMPLES_BITS)
      $file.printf("\n")
    elsif n % 16 == 15
      $file.printf("\n  ")
    else
      $file.printf(" ")
    end
  end
  $file.printf("]\n\n")
end

$vco_harmonics_restriction_table = []

((NOTE_NUMBER_MIN - 1)..NOTE_NUMBER_MAX).each do |note_number|
  if (note_number < (NOTE_NUMBER_MIN - 1)) || (note_number > NOTE_NUMBER_MAX)
    freq = 0
  else
    freq = freq_from_note_number(note_number + 1)
  end
  $vco_harmonics_restriction_table << freq
end

def last_harmonic(freq)
  last = (freq != 0) ? ((FREQUENCY_MAX * (1 << VCO_PHASE_RESOLUTION_BITS)) / ((freq / 2) * SAMPLING_RATE)) : 0
  last = 127 if last > 127
  last
end

$vco_harmonics_restriction_table.map { |freq| last_harmonic(freq) }.uniq.sort.reverse.each do |i|
  generate_vco_wave_table_sawtooth(i) if i != -1
end

$file.printf("$vco_wave_tables = [\n  ")
$vco_harmonics_restriction_table.each_with_index do |freq, idx|
  $file.printf("$vco_wave_table_%-3d,", last_harmonic(freq))
  if idx == DATA_BYTE_MAX
    $file.printf("\n")
  elsif idx % 4 == 3
    $file.printf("\n  ")
  else
    $file.printf(" ")
  end
end
$file.printf("]\n\n")

$file.close
