require_relative 'common'

$file = File.open("vco-table.rb", "w")

$vco_freq_table = []

$file.printf("$vco_freq_table = [\n  ")
(0..127).each do |note_number|
  if (note_number < NOTE_NUMBER_MIN) || (note_number > NOTE_NUMBER_MAX)
    freq = 0
  else
    cent = (note_number * 100.0) - 6900.0
    hz = 440.0 * (2.0 ** (cent / 1200.0))
    freq = (hz * 256.0 * 256.0 / SAMPLING_RATE * 2.0).floor
    freq = freq + 1 if freq.even?
  end

  $vco_freq_table << freq
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

$file.printf("$vco_tune_table = [\n  ")
(0..15).each do |i|
  tune = ((2.0 ** (i / (12.0 * 16.0))) / 2.0 * 65536.0).round

  $file.printf("%5d,", tune)
  if i == 15
    $file.printf("\n")
  elsif i % 8 == 7
    $file.printf("\n  ")
  else
    $file.printf(" ")
  end
end
$file.printf("]\n\n")

FREQ_MAX = $vco_freq_table.max

def generate_vco_wave_table(max)
  $file.printf("$vco_wave_table_%d = [\n  ", max)
  (0..VCO_WAVE_TABLE_SAMPLES - 1).each do |n|
    level = 0
    (1..max).each do |k|
      level += yield(n, k)
    end
    level = (level * VCO_WAVE_TABLE_PEAK).round.to_i
    $file.printf("%+4d,", level)

    if n == VCO_WAVE_TABLE_SAMPLES - 1
      $file.printf("\n")
    elsif n % 16 == 15
      $file.printf("\n  ")
    else
      $file.printf(" ")
    end
  end
  $file.printf("]\n\n")
end

def generate_vco_wave_table_sawtooth(max)
  generate_vco_wave_table(max) do |n, k|
    (2.0 / Math::PI) * Math.sin((2.0 * Math::PI) * ((n + 0.5) / VCO_WAVE_TABLE_SAMPLES) * k) / k
  end
end

# todo: improve
$vco_freq_table.map { |freq| (freq != 0) ? ((VCO_PHASE_RESOLUTION / 2 - 1) / (freq / 2)) : -1 }
               .uniq.each do |i|
  generate_vco_wave_table_sawtooth(i) if i != -1
end

generate_vco_wave_table_sawtooth(0)

$file.printf("$vco_wave_tables = [\n  ")
$vco_freq_table.each_with_index do |item, idx|
  next_freq = (item != 0) ? $vco_freq_table[idx + 1] : 0
  next_freq = FREQ_MAX if next_freq == 0
  if item != 0
    $file.printf("$vco_wave_table_%-3d,", (VCO_PHASE_RESOLUTION / 2 - 1) / (next_freq / 2))
  else
    $file.printf("$vco_wave_table_0  ,")
  end
  if idx == 127
    $file.printf("\n")
  elsif idx % 4 == 3
    $file.printf("\n  ")
  else
    $file.printf(" ")
  end
end
$file.printf("]\n\n")

$file.close
