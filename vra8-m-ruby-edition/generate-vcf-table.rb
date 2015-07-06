require_relative 'common'

$file = File.open("vcf-table.rb", "w")

OCTAVES = 128.0 / 24.0

def generate_vcf_lpf_table(name, q)
  $file.printf("$vcf_lpf_table_%s = [\n  ", name)
  (0..DATA_BYTE_MAX).each do |i|
    f_0_over_fs = (2.0 ** (i / ((DATA_BYTE_MAX + 1).to_f / OCTAVES))) /
                  (2.0 ** (OCTAVES.to_f + 1.0))

    w_0 = 2.0 * Math::PI * f_0_over_fs
    alpha = Math.sin(w_0) / (2.0 * q)

    b_2 = (1.0 - Math.cos(w_0)) / 2.0
    a_0 = 1.0 + alpha
    a_1 = (-2.0) * Math.cos(w_0)

    b_2_over_a_0 = ((b_2 / a_0) * (1 << VCF_TABLE_FRACTION_BITS)).round.to_i
    b_2_over_a_0_low = b_2_over_a_0 & 0xFF
    b_2_over_a_0_high = b_2_over_a_0 >> 8
    a_1_over_a_0_high = ((a_1 / a_0) * (1 << (VCF_TABLE_FRACTION_BITS - 8))).round.to_i

    $file.printf("%+4d, %+4d, %+4d,", b_2_over_a_0_low, b_2_over_a_0_high, a_1_over_a_0_high)
    if i == DATA_BYTE_MAX
      $file.printf("\n")
    elsif i % 4 == 3
      $file.printf("\n  ")
    else
      $file.printf(" ")
    end
  end
  $file.printf("]\n\n")
end

generate_vcf_lpf_table("q_2_sqrt_2", 2.0 * Math.sqrt(2.0))
generate_vcf_lpf_table("q_1_sqrt_2", 1.0 * Math.sqrt(2.0))
generate_vcf_lpf_table("q_1_over_sqrt_2", 1.0 / Math.sqrt(2.0))

$file.close
