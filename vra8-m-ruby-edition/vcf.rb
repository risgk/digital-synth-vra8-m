require_relative 'common'
require_relative 'vcf-table'

# refs http://www.musicdsp.org/files/Audio-EQ-Cookbook.txt
# Cookbook formulae for audio EQ biquad filter coefficients
# by Robert Bristow-Johnson

class VCF
  def initialize
    @cutoff = 127
    @resonance = 0
    @control_signal_amt = 0

    @x_1 = 0
    @x_2 = 0
    @y_1 = 0
    @y_2 = 0
  end

  def set_cutoff(controller_value)
    @cutoff = controller_value
  end

  def set_resonance(controller_value)
    @resonance = controller_value
  end

  def set_control_signal_amt(controller_value)
    @control_signal_amt = controller_value
  end

  def clock(audio_input, cutoff_control)
    cutoff = @cutoff + high_byte(@control_signal_amt * cutoff_control)
    if (cutoff > 127)
      cutoff = 127
    end

    if ((@resonance & 0x40) != 0)
      i = cutoff * 3
      b_2_over_a_0 = $vcf_lpf_table_q_2_sqrt_2[i + 0]
      a_1_over_a_0 = $vcf_lpf_table_q_2_sqrt_2[i + 1]
      a_2_over_a_0 = $vcf_lpf_table_q_2_sqrt_2[i + 2]
    else
      i = cutoff * 3
      b_2_over_a_0 = $vcf_lpf_table_q_1_over_sqrt_2[i + 0]
      a_1_over_a_0 = $vcf_lpf_table_q_1_over_sqrt_2[i + 1]
      a_2_over_a_0 = $vcf_lpf_table_q_1_over_sqrt_2[i + 2]
    end

    x_0 = audio_input << 8
    tmp  = muls_16_high(b_2_over_a_0, x_0 + (@x_1 << 1) + @x_2)
    tmp -= muls_16_high(a_1_over_a_0, @y_1)
    tmp -= muls_16_high(a_2_over_a_0, @y_2)
    y_0 = tmp << (16 - VCF_TABLE_FRACTION_BITS)
    @x_2 = @x_1
    @y_2 = @y_1
    @x_1 = x_0
    @y_1 = y_0

    return high_sbyte(y_0)
  end
end
