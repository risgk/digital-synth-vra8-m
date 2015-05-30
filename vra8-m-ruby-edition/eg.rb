require_relative 'common'
require_relative 'eg-table'

class EG
  STATE_ATTACK        = 0
  STATE_DECAY_SUSTAIN = 1
  STATE_RELEASE       = 2
  STATE_IDLE          = 3

  def initialize
    @state = STATE_IDLE
    @decay_release_count = 0
    @level = 0
    set_attack(0)
    set_decay_release(0)
    set_sustain(127)
  end

  def set_attack(controller_value)
    @attack_rate = $eg_attack_rate_table[controller_value]
  end

  def set_decay_release(controller_value)
    @decay_release_interval = $eg_decay_release_interval_table[controller_value]
  end

  def set_sustain(controller_value)
    @sustain_level = (controller_value << 1) << 8
  end

  def note_on
    @state = STATE_ATTACK
    @decay_release_count = 0
  end

  def note_off
    @state = STATE_RELEASE
    @decay_release_count = 0
  end

  def clock
    case (@state)
    when STATE_ATTACK
      if (@level >= EG_LEVEL_MAX - @attack_rate)
        @state = STATE_DECAY_SUSTAIN
        @level = EG_LEVEL_MAX
      else
        @level += @attack_rate
      end
    when STATE_DECAY_SUSTAIN
      @decay_release_count += 1
      if (@decay_release_count >= @decay_release_interval)
        @decay_release_count = 0
        if (@level > @sustain_level)
          if (@level <= @sustain_level + (EG_LEVEL_MAX >> 10))
            @level = @sustain_level
          elsif
            @level = @sustain_level +
                     mul_q15_q16(@level - @sustain_level, ENV_DECAY_FACTOR)
          end
        end
      end
    when STATE_RELEASE
      @decay_release_count += 1
      if (@decay_release_count >= @decay_release_interval)
        @decay_release_count = 0
        @level = mul_q15_q16(@level, ENV_DECAY_FACTOR)
        if (@level <= EG_LEVEL_MAX >> 10)
          @state = STATE_IDLE
          @level = 0
        end
      end
    when STATE_IDLE
      @level = 0
    end
    return high_byte(@level)
  end
end
