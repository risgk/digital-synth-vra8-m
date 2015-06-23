#include "common.h"
#include "vco.h"
#include "vcf.h"
#include "vca.h"
#include "eg.h"
#include "lfo.h"
#include "slew-rate-limiter.h"

template <uint8_t T>
class Voice {
  static uint8_t m_note_number;

public:
  INLINE static void initialize() {
    VCO<0>::initialize();
    VCF<0>::initialize();
    VCA<0>::initialize();
    EG<0>::initialize();
    LFO<0>::initialize();
    SlewRateLimiter<0>::initialize();
    m_note_number = NOTE_NUMBER_MIN;
  }

  INLINE static void note_on(uint8_t note_number) {
    m_note_number = note_number;
    EG<0>::note_on();
  }

  INLINE static void note_off() {
    EG<0>::note_off();
  }

  INLINE static void control_change(uint8_t controller_number, uint8_t controller_value) {
    switch (controller_number) {
    case VCO_PULSE_SAW_MIX:
      VCO<0>::set_pulse_saw_mix(controller_value);
      break;
    case VCO_PULSE_WIDTH:
      VCO<0>::set_pulse_width(controller_value);
      break;
    case VCO_SAW_SHIFT:
      VCO<0>::set_saw_shift(controller_value);
      break;
    case VCF_CUTOFF:
      VCF<0>::set_cutoff(controller_value);
      break;
    case VCF_RESONANCE:
      VCF<0>::set_resonance(controller_value);
      break;
    case VCF_EG_AMT:
      VCF<0>::set_cv_amt(controller_value);
      break;
    case VCA_GAIN:
      VCA<0>::set_gain(controller_value);
      break;
    case EG_ATTACK:
      EG<0>::set_attack(controller_value);
      break;
    case EG_DECAY_RELEASE:
      EG<0>::set_decay_release(controller_value);
      break;
    case EG_SUSTAIN:
      EG<0>::set_sustain(controller_value);
      break;
    case LFO_RATE:
      LFO<0>::set_rate(controller_value);
      break;
    case LFO_VCO_COLOR_AMT:
      VCO<0>::set_color_lfo_amt(controller_value);
      break;
    case PORTAMENTO:
      SlewRateLimiter<0>::set_slew_time(controller_value);
      break;
    case ALL_NOTES_OFF:
      EG<0>::note_off();
      break;
    }
  }

  INLINE static int8_t clock() {
    uint8_t  eg_output = EG<0>::clock();
    uint8_t  lfo_output = LFO<0>::clock();
    uint16_t srl_output = SlewRateLimiter<0>::clock(m_note_number << 8);
    int16_t  vco_output = VCO<0>::clock(srl_output, lfo_output);
    int16_t  vcf_output = VCF<0>::clock(vco_output, eg_output);
    int16_t  vca_output = VCA<0>::clock(vcf_output, eg_output);
    return high_sbyte(vca_output);
  }
};

template <uint8_t T> uint8_t Voice<T>::m_note_number;
