require_relative 'common'
require_relative 'lpf-table'

# refs http://www.musicdsp.org/files/Audio-EQ-Cookbook.txt
# Cookbook formulae for audio EQ biquad filter coefficients
# by Robert Bristow-Johnson

class VCF
  def initialize
    @cutoff = 127
    @resonance = OFF
    @eg_amt = 0
    @x1 = 0
    @x2 = 0
    @y1 = 0
    @y2 = 0
  end

  def set_cutoff(controller_value)
    @cutoff = controller_value
  end

  def set_resonance(controller_value)
    @resonance = controller_value
  end

  def set_eg_amt(controller_value)
    @eg_amt = controller_value
  end

  def clock(a_in, k_eg)
    cutoff = @cutoff + high_byte(@eg_amt * (k_eg + 0x80))
    if (cutoff > 127)
      cutoff = 127
    end

    if ((@resonance & 0x40) != 0)
      i = cutoff * 3
      b2_over_a0 = $lpf_table_q_2_sqrt_2[i + 0]
      a1_over_a0 = $lpf_table_q_2_sqrt_2[i + 1]
      a2_over_a0 = $lpf_table_q_2_sqrt_2[i + 2]
    else
      i = cutoff * 3
      b2_over_a0 = $lpf_table_q_1_over_sqrt_2[i + 0]
      a1_over_a0 = $lpf_table_q_1_over_sqrt_2[i + 1]
      a2_over_a0 = $lpf_table_q_1_over_sqrt_2[i + 2]
    end

    x0 = a_in << 8
    r = x0 + (@x1 << 1) + @x2
    tmp  = muls_16_high(b2_over_a0, r)
    tmp -= muls_16_high(a1_over_a0, @y1)
    tmp -= muls_16_high(a2_over_a0, @y2)
    y0 = tmp << (16 - LPF_TABLE_BITS)
    @x2 = @x1
    @y2 = @y1
    @x1 = x0
    @y1 = y0

    return high_sbyte(y0)
  end
end
