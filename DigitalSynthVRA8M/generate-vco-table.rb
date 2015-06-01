require_relative 'common'

$file = File.open("vco-table.h", "w")

$file.printf("#pragma once\n\n")

$vco_freq_table = []

$file.printf("const uint16_t g_vco_freq_table[] = {\n  ")
(0..DATA_BYTE_MAX).each do |note_number|
  if (note_number < NOTE_NUMBER_MIN) || (note_number > NOTE_NUMBER_MAX)
    freq = 0
  else
    cent = (note_number * 100.0) - 6900.0
    hz = 440.0 * (2.0 ** (cent / 1200.0))
    freq = (hz * VCO_PHASE_RESOLUTION / SAMPLING_RATE * 2.0).floor
    freq = freq + 1 if freq.even?
  end
  $vco_freq_table << freq

  $file.printf("%5d,", freq)
  if note_number == DATA_BYTE_MAX
    $file.printf("\n")
  elsif note_number % 12 == 11
    $file.printf("\n  ")
  else
    $file.printf(" ")
  end
end
$file.printf("};\n\n")

$file.printf("const uint16_t g_vco_tune_rate_table[] = {\n  ")
(0..VCO_TUNE_RATE_TABLE_STEPS - 1).each do |i|
  tune_rate = ((2.0 ** (i / (12.0 * VCO_TUNE_RATE_TABLE_STEPS))) *
               VCO_TUNE_RATE_DENOMINATOR / 2.0).round

  $file.printf("%5d,", tune_rate)
  if i == VCO_TUNE_RATE_TABLE_STEPS - 1
    $file.printf("\n")
  elsif i % 8 == 7
    $file.printf("\n  ")
  else
    $file.printf(" ")
  end
end
$file.printf("};\n\n")

LEVEL_ONE_RESOLUTION = 108

def generate_vco_wave_table(max)
  $file.printf("const uint8_t g_vco_wave_table_%d[] PROGMEM = {\n  ", max)
  (0..VCO_WAVE_TABLE_SAMPLES - 1).each do |n|
    level = 0
    (1..max).each do |k|
      level += yield(n, k)
    end
    level = (level * LEVEL_ONE_RESOLUTION).round.to_i

    $file.printf("%+4d,", level)
    if n == VCO_WAVE_TABLE_SAMPLES - 1
      $file.printf("\n")
    elsif n % 16 == 15
      $file.printf("\n  ")
    else
      $file.printf(" ")
    end
  end
  $file.printf("};\n\n")
end

def generate_vco_wave_table_sawtooth(max)
  generate_vco_wave_table(max) do |n, k|
    (2.0 / Math::PI) * Math.sin((2.0 * Math::PI) * ((n + 0.5) / VCO_WAVE_TABLE_SAMPLES) * k) / k
  end
end

$vco_freq_restriction_table = $vco_freq_table.dup
$vco_freq_restriction_table.shift
$vco_freq_restriction_table.push(0)
$vco_freq_restriction_table[NOTE_NUMBER_MIN - 1] = 0
$vco_freq_restriction_table[NOTE_NUMBER_MAX] = $vco_freq_restriction_table[NOTE_NUMBER_MAX - 1]

def max_overtone(freq)
  (freq != 0) ? ((FREQUENCY_MAX * VCO_PHASE_RESOLUTION) / ((freq / 2) * SAMPLING_RATE)) : 0
end

$vco_freq_restriction_table.map { |freq| max_overtone(freq) }.uniq.sort.reverse.each do |i|
  generate_vco_wave_table_sawtooth(i) if i != -1
end

$file.printf("const uint8_t* g_vco_wave_tables[] = {\n  ")
$vco_freq_restriction_table.each_with_index do |freq, idx|
  $file.printf("g_vco_wave_table_%-3d,", max_overtone(freq))
  if idx == DATA_BYTE_MAX
    $file.printf("\n")
  elsif idx % 4 == 3
    $file.printf("\n  ")
  else
    $file.printf(" ")
  end
end
$file.printf("};\n\n")

$file.close
