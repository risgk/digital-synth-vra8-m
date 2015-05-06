require './common'
require './env-table'

class EG
  STATE_ATTACK        = 0
  STATE_DECAY_SUSTAIN = 1
  STATE_RELEASE       = 2
  STATE_IDLE          = 3

  LEVEL_127 = 127 << 8
  LEVEL_254 = 254 << 8

  def initialize
    @attack_interval = $env_table_interval_from_time[0]
    @decay_interval  = $env_table_interval_from_time[0]
    @sustain_level   = 127 << 8
    @state           = STATE_IDLE
    @level           = 0
    @count           = 0
  end

  def set_attack(attack)
    @attack_interval = $env_table_interval_from_time[attack]
  end

  def set_decay(decay)
    @decay_interval = $env_table_interval_from_time[decay]
  end

  def set_sustain(sustain)
    @sustain_level = sustain << 8
  end

  def note_on
    @state = STATE_ATTACK
    @count = 0
  end

  def note_off
    @state = STATE_RELEASE
    @count = 0
  end

  def sound_off
    @state = STATE_IDLE
    @count = 0
    @level = 0
  end

  def clock
    case (@state)
    when STATE_ATTACK
      @count += 1
      if (@count < @attack_interval)
        return high_byte(@level)
      end
      @count = 0

      @level = LEVEL_254 - mulsu_16(LEVEL_254 - @level, ENV_ATTACK_FACTOR)
      if (@level >= LEVEL_127)
        @state = STATE_DECAY_SUSTAIN
        @level = LEVEL_127
      end
    when STATE_DECAY_SUSTAIN
      @count += 1
      if (@count < @decay_interval)
        return high_byte(@level)
      end
      @count = 0

      if (@level > @sustain_level)
        if (@level <= (32 + @sustain_level))
          @level = @sustain_level
        elsif
          @level = @sustain_level +
                   mulsu_16(@level - @sustain_level, ENV_DECAY_FACTOR)
        end
      end
    when STATE_RELEASE
      @count += 1
      if (@count < @decay_interval)
        return high_byte(@level)
      end
      @count = 0

      @level = mulsu_16(@level, ENV_DECAY_FACTOR)
      if (@level <= 32)
        @state = STATE_IDLE
        @level = 0
      end
    when STATE_IDLE
      @level = 0
    end

    return high_byte(@level)
  end
end
