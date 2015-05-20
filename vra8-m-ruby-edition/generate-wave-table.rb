require_relative 'common'
require_relative 'freq-table'

FREQ_MAX = $freq_table.max

$file = File.open("wave-table.rb", "w")

def generate_wave_table(max)
  $file.printf("$wt_%d = [\n  ", max)
  (0..WAVE_TABLE_SAMPLES - 1).each do |n|
    level = 0
    (1..max).each do |k|
      level += yield(n, k)
    end
    level = (level * WAVE_TABLE_PEAK).round.to_i
    $file.printf("%+4d,", level)

    if n == WAVE_TABLE_SAMPLES - 1
      $file.printf("\n")
    elsif n % 16 == 15
      $file.printf("\n  ")
    else
      $file.printf(" ")
    end
  end
  $file.printf("]\n\n")
end

def generate_wave_table_sawtooth(max)
  generate_wave_table(max) do |n, k|
    (2.0 / Math::PI) * Math.sin((2.0 * Math::PI) * ((n + 0.5) / WAVE_TABLE_SAMPLES) * k) / k
  end
end

# todo: improve
$freq_table.map { |freq| (freq != 0) ? ((VCO_PHASE_RESOLUTION / 2 - 1) / (freq / 2)) : -1 }.uniq.each do |i|
  generate_wave_table_sawtooth(i) if i != -1
end

def generate_wave_tables
  $file.printf("$wave_tables = [\n  ")

  $freq_table.each_with_index do |item, idx|
    next_freq = (item != 0) ? $freq_table[idx + 1] : 0
    next_freq = FREQ_MAX if next_freq == 0
    if item != 0
      $file.printf("$wt_%-3d,", (VCO_PHASE_RESOLUTION / 2 - 1) / (next_freq / 2))
    else
      $file.printf("nil    ,")
    end
    if idx == 127
      $file.printf("\n")
    elsif idx % 12 == 11
      $file.printf("\n  ")
    else
      $file.printf(" ")
    end
  end

  $file.printf("]\n\n")
end

generate_wave_tables

$file.close
