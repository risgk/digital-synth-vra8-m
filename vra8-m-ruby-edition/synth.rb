require_relative 'common'

require_relative 'vco'
require_relative 'vcf'
require_relative 'vca'
require_relative 'eg'
require_relative 'lfo'
require_relative 'slew-rate-limiter'
require_relative 'voice'
require_relative 'synth-core'

# associations of units
IVCO             = VCO
IVCF             = VCF
IVCA             = VCA
IEG              = EG
ILFO             = LFO
ISlewRateLimiter = SlewRateLimiter
IVoice           = Voice
ISynthCore       = SynthCore

class Synth
  def initialize
    @synth_core = ISynthCore.new
    # p @synth_core.instance_variable_get('@note_number')  # for tests
  end

  def receive_midi_byte(b)
    @synth_core.receive_midi_byte(b)
  end

  def clock
    @synth_core.clock
  end
end
