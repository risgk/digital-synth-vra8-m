require './common'

class VCA
  def clock(a_in, k_eg)
    a = a_in * (k_eg << 1)

    return high_byte(a)
  end
end
