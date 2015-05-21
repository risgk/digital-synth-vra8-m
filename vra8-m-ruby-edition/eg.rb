require_relative 'common'
require_relative 'eg-table'

class EG
  STATE_ATTACK        = 0
  STATE_DECAY_SUSTAIN = 1
  STATE_RELEASE       = 2
  STATE_IDLE          = 3

  def initialize
    @attack_rate = $eg_attack_rate_table[0]
    @decay_interval = $eg_decay_interval_table[0]
    @sustain_level = (127 << 1) << 8

    @state = STATE_IDLE
    @decay_count = 0
    @level = 0
  end

  def set_attack(controller_value)
    @attack_rate = $eg_attack_rate_table[controller_value]
  end

  def set_decay(controller_value)
    @decay_interval = $eg_decay_interval_table[controller_value]
  end

  def set_sustain(controller_value)
    @sustain_level = (controller_value << 1) << 8
  end

  def note_on
    @state = STATE_ATTACK
    @decay_count = 0
  end

  def note_off
    @state = STATE_RELEASE
    @decay_count = 0
  end

  def sound_off
    @state = STATE_IDLE
    @decay_count = 0
    @level = 0
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
      @decay_count += 1
      if (@decay_count < @decay_interval)
        return high_byte(@level)
      end
      @decay_count = 0

      if (@level > @sustain_level)
        if (@level <= (32 + @sustain_level))
          @level = @sustain_level
        elsif
          @level = @sustain_level +
                   mulsu_16_high(@level - @sustain_level, ENV_DECAY_FACTOR)
        end
      end
    when STATE_RELEASE
      @decay_count += 1
      if (@decay_count < @decay_interval)
        return high_byte(@level)
      end
      @decay_count = 0

      @level = mulsu_16_high(@level, ENV_DECAY_FACTOR)
      if (@level <= (EG_LEVEL_MAX >> 10))
        @state = STATE_IDLE
        @level = 0
      end
    when STATE_IDLE
      @level = 0
    end

    return high_byte(@level)
  end
end
