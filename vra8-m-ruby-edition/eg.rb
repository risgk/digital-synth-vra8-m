require_relative 'common'
require_relative 'mul-q'
require_relative 'eg-table'

class EG
  STATE_ATTACK        = 0
  STATE_DECAY_SUSTAIN = 1
  STATE_RELEASE       = 2
  STATE_IDLE          = 3

  def initialize
    @state = STATE_IDLE
    @count = 0
    @level = 0
    set_attack(0)
    set_decay_release(0)
    set_sustain(127)
  end

  def set_attack(controller_value)
    @attack_rate = $eg_attack_rate_table[controller_value >> (7 - EG_CONTROLLER_STEPS_BITS)]
  end

  def set_decay_release(controller_value)
    time = controller_value >> (7 - EG_CONTROLLER_STEPS_BITS)
    @eg_decay_release_rate         = $eg_decay_release_rate_table[time]
    @decay_release_update_interval = $eg_decay_release_update_interval_table[time]
  end

  def set_sustain(controller_value)
    @sustain_level = (controller_value << 1) << 8
  end

  def note_on
    @state = STATE_ATTACK
    @count = EG_ATTACK_UPDATE_INTERVAL
  end

  def note_off
    @state = STATE_RELEASE
    @count = @decay_release_update_interval
  end

  def clock
    case (@state)
    when STATE_ATTACK
      @count -= 1
      if (@count == 0)
        @count = EG_ATTACK_UPDATE_INTERVAL
        if (@level >= EG_LEVEL_MAX - @attack_rate)
          @state = STATE_DECAY_SUSTAIN
          @level = EG_LEVEL_MAX
        else
          @level += @attack_rate
        end
      end
    when STATE_DECAY_SUSTAIN
      @count -= 1
      if (@count == 0)
        @count = @decay_release_update_interval
        if (@level > @sustain_level)
          if (@level <= @sustain_level + (EG_LEVEL_MAX >> 10))
            @level = @sustain_level
          else
            @level = @sustain_level +
                     mul_q16_q8(@level - @sustain_level, @eg_decay_release_rate)
          end
        end
      end
    when STATE_RELEASE
      @count -= 1
      if (@count == 0)
        @count = @decay_release_update_interval
        if (@level <= (EG_LEVEL_MAX >> 10))
          @state = STATE_IDLE
          @level = 0
        else
          @level = mul_q16_q8(@level, @eg_decay_release_rate)
        end
      end
    when STATE_IDLE
      @level = 0
    end
    return high_byte(@level)
  end
end
