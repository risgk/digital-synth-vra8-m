require_relative 'common'

class VCA
  def clock(a_in, k_eg_in)
    return high_sbyte(a_in * k_eg_in)
  end
end
