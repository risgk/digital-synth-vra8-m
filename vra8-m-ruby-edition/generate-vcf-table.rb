require_relative 'common'

$file = File.open("vcf-table.rb", "w")

def generate_lpf_table(name, q)
  $file.printf("$lpf_table_%s = [\n  ", name)
  (0..127).each do |i|
    f_0_over_fs = (2.0 ** (i / (128.0 / 6.0))) / (2.0 ** 7.0)

    w_0 = 2.0 * Math::PI * f_0_over_fs
    alpha = Math.sin(w_0) / (2.0 * q)

    b_2 = (1.0 - Math.cos(w_0)) / 2.0
    a_0 = 1.0 + alpha
    a_1 = (-2.0) * Math.cos(w_0)
    a_2 = 1.0 - alpha

    lpf_table_one = 2 ** LPF_TABLE_FRACTION_BITS
    b_2_over_a_0 = ((b_2 / a_0) * lpf_table_one).round.to_i
    a_1_over_a_0 = ((a_1 / a_0) * lpf_table_one).round.to_i
    a_2_over_a_0 = (b_2_over_a_0 * 4) - a_1_over_a_0 - lpf_table_one

    $file.printf("%+6d, %+6d, %+6d,", b_2_over_a_0, a_1_over_a_0, a_2_over_a_0)
    if i == 127
      $file.printf("\n")
    elsif i % 4 == 3
      $file.printf("\n  ")
    else
      $file.printf(" ")
    end
  end
  $file.printf("]\n\n")
end

generate_lpf_table("q_1_over_sqrt_2", 1.0 / Math.sqrt(2.0))
generate_lpf_table("q_2_sqrt_2", 2.0 * Math.sqrt(2.0))

$file.close
