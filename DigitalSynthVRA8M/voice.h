#include "common.h"
#include "vco.h"
#include "vcf.h"
#include "vca.h"
#include "eg.h"
#include "lfo.h"
#include "slew-rate-limiter.h"

class Voice {
  static uint8_t m_note_number;

public:
  INLINE static void initialize() {
    VCO::initialize();
    VCF::initialize();
    VCA::initialize();
    EG::initialize();
    LFO::initialize();
    SlewRateLimiter::initialize();
    m_note_number = NOTE_NUMBER_MIN;

    // Preset #1
    control_change(VCO_PULSE_SAW_MIX, 64 );
    control_change(VCO_PULSE_WIDTH,   0  );
    control_change(VCO_SAW_SHIFT,     64 );
    control_change(VCF_CUTOFF,        0  );
    control_change(VCF_RESONANCE,     127);
    control_change(VCF_EG_AMT,        127);
    control_change(VCA_GAIN,          96 );
    control_change(EG_ATTACK,         32 );
    control_change(EG_DECAY_RELEASE,  96 );
    control_change(EG_SUSTAIN,        127);
    control_change(LFO_RATE,          32 );
    control_change(LFO_VCO_COLOR_AMT, 32 );
    control_change(PORTAMENTO,        96 );
  }

  INLINE static void note_on(uint8_t note_number) {
    m_note_number = note_number;
    EG::note_on();
  }

  INLINE static void note_off() {
    EG::note_off();
  }

  INLINE static void control_change(uint8_t controller_number, uint8_t controller_value) {
    switch (controller_number) {
    case VCO_PULSE_SAW_MIX:
      VCO::set_pulse_saw_mix(controller_value);
      break;
    case VCO_PULSE_WIDTH:
      VCO::set_pulse_width(controller_value);
      break;
    case VCO_SAW_SHIFT:
      VCO::set_saw_shift(controller_value);
      break;
    case VCF_CUTOFF:
      VCF::set_cutoff(controller_value);
      break;
    case VCF_RESONANCE:
      VCF::set_resonance(controller_value);
      break;
    case VCF_EG_AMT:
      VCF::set_cv_amt(controller_value);
      break;
    case VCA_GAIN:
      VCA::set_gain(controller_value);
      break;
    case EG_ATTACK:
      EG::set_attack(controller_value);
      break;
    case EG_DECAY_RELEASE:
      EG::set_decay_release(controller_value);
      break;
    case EG_SUSTAIN:
      EG::set_sustain(controller_value);
      break;
    case LFO_RATE:
      LFO::set_rate(controller_value);
      break;
    case LFO_VCO_COLOR_AMT:
      VCO::set_color_lfo_amt(controller_value);
      break;
    case PORTAMENTO:
      SlewRateLimiter::set_slew_time(controller_value);
      break;
    case ALL_NOTES_OFF:
      EG::note_off();
      break;
    }
  }

  INLINE static int8_t clock() {
    uint8_t  eg_output = EG::clock();
    uint8_t  lfo_output = LFO::clock();
    uint16_t srl_output = SlewRateLimiter::clock(m_note_number << 8);
    int16_t  vco_output = VCO::clock(srl_output, lfo_output);
    int16_t  vcf_output = VCF::clock(vco_output, eg_output);
    int16_t  vca_output = VCA::clock(vcf_output, eg_output);
    return high_sbyte(vca_output);
  }
};

uint8_t Voice::m_note_number;
