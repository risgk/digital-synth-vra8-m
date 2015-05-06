require './common'
require './env-table'

class EG
  STATE_ATTACK        = 0
  STATE_DECAY_SUSTAIN = 1
  STATE_RELEASE       = 2
  STATE_IDLE          = 3
  LEVEL16_127         = 32767
  LEVEL16_255         = 65534

  def initialize
    @attack_interval  = $env_table_interval_from_time[0]
    @decay_interval   = $env_table_interval_from_time[0]
    @sustain_level_16 = 127
    @state            = STATE_IDLE
    @level_16         = 0
    @count            = 0
  end

  def set_attack_time(attack_time)
    @attack_interval = $env_table_interval_from_time[attack_time]
  end

  def set_decay_time(decay_time)
    @decay_interval = $env_table_interval_from_time[decay_time]
  end

  def set_sustain_level(sustain_level)
    @sustain_level_16 = sustain_level << 8
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
    @level_16 = 0
  end

  def clock
    case (@state)
    when STATE_ATTACK
      @count += 1
      if (@count < @attack_interval)
        return high_byte(@level_16)
      end
      @count = 0

      @level_16 = LEVEL16_255 -
                  muls_16(LEVEL16_255 - @level_16, ENV_ATTACK_FACTOR)
      if (@level_16 >= LEVEL16_127)
        @state = STATE_DECAY_SUSTAIN
        @level_16 = LEVEL16_127
      end
    when STATE_DECAY_SUSTAIN
      @count += 1
      if (@count < @decay_interval)
        return high_byte(@level_16)
      end
      @count = 0

      if (@level_16 > @sustain_level_16)
        if (@level_16 <= (32 + @sustain_level_16))
          @level_16 = @sustain_level_16
        elsif
          @level_16 = @sustain_level_16 +
                      muls_16(@level_16 - @sustain_level_16, ENV_DECAY_FACTOR)
        end
      end
    when STATE_RELEASE
      @count += 1
      if (@count < @decay_interval)
        return high_byte(@level_16)
      end
      @count = 0

      @level_16 = muls_16(@level_16, ENV_DECAY_FACTOR)
      if (@level_16 <= 32)
        @state = STATE_IDLE
        @level_16 = 0
      end
    when STATE_IDLE
      @level_16 = 0
    end

    return high_byte(@level_16)
  end
end
