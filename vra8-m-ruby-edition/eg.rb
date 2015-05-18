require './common'
require './env-table'

class EG
  STATE_ATTACK        = 0
  STATE_DECAY_SUSTAIN = 1
  STATE_RELEASE       = 2
  STATE_IDLE          = 3

  def initialize
    @attack_speed   = $env_table_attack_speed[0]
    @decay_interval = $env_table_decay_interval[0]
    @sustain_level  = (127 << 1) << 8
    @state          = STATE_IDLE
    @level          = 0
    @decay_count    = 0
  end

  def set_attack(attack)
    @attack_speed    = $env_table_attack_speed[attack]
  end

  def set_decay(decay)
    @decay_interval = $env_table_decay_interval[decay]
  end

  def set_sustain(sustain)
    @sustain_level = (sustain << 1) << 8
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
      if (@level >= EG_MAX_LEVEL_16 - @attack_speed)
        @state = STATE_DECAY_SUSTAIN
        @level = EG_MAX_LEVEL_16
      else
        @level += @attack_speed
      end
    when STATE_DECAY_SUSTAIN
      @decay_count += 1
      if (@decay_count < @decay_interval)
        return high_byte(@level) - 128
      end
      @decay_count = 0

      if (@level > @sustain_level)
        if (@level <= (32 + @sustain_level))
          @level = @sustain_level
        elsif
          @level = @sustain_level +
                   mulsu_h16(@level - @sustain_level, ENV_DECAY_FACTOR)
        end
      end
    when STATE_RELEASE
      @decay_count += 1
      if (@decay_count < @decay_interval)
        return high_byte(@level) - 128
      end
      @decay_count = 0

      @level = mulsu_h16(@level, ENV_DECAY_FACTOR)
      if (@level <= 32)
        @state = STATE_IDLE
        @level = 0
      end
    when STATE_IDLE
      @level = 0
    end

    return high_byte(@level) - 128
  end
end
