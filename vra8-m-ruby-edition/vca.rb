require_relative 'common'

class VCA
  def clock(a_in, k_eg)
    return high_sbyte(a_in * (k_eg + 0x80))
  end
end
