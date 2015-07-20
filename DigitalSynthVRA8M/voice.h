#include "common.h"

template <uint8_t T>
class Voice {
  static uint8_t m_note_number;

public:
  INLINE static void initialize() {
    IVCO<0>::initialize();
    IVCF<0>::initialize();
    IVCA<0>::initialize();
    IEG<0>::initialize();
    ILFO<0>::initialize();
    ISlewRateLimiter<0>::initialize();
    m_note_number = NOTE_NUMBER_MIN;
  }

  INLINE static void note_on(uint8_t note_number) {
    if ((note_number >= NOTE_NUMBER_MIN) && (note_number <= NOTE_NUMBER_MAX)) {
      m_note_number = note_number;
      IEG<0>::note_on();
    }
  }

  INLINE static void note_off() {
    IEG<0>::note_off();
  }

  INLINE static void control_change(uint8_t controller_number, uint8_t controller_value) {
    switch (controller_number) {
    case LFO_RATE:
      ILFO<0>::set_rate(controller_value);
      break;
    case LFO_RATE_EG_AMT:
      ILFO<0>::set_rate_eg_amt(controller_value);
      break;
    case LFO_LEVEL_EG_COEF:
      ILFO<0>::set_level_eg_coef(controller_value);
      break;
    case VCO_COLOR_LFO_AMT:
      IVCO<0>::set_color_lfo_amt(controller_value);
      break;
    case VCO_MIX:
      IVCO<0>::set_mix(controller_value);
      break;
    case VCO_MIX_EG_AMT:
      IVCO<0>::set_mix_eg_amt(controller_value);
      break;
    case VCO_PULSE_WIDTH:
      IVCO<0>::set_pulse_width(controller_value);
      break;
    case VCO_SAW_SHIFT:
      IVCO<0>::set_saw_shift(controller_value);
      break;
    case VCO_PORTAMENTO:
      ISlewRateLimiter<0>::set_slew_time(controller_value);
      break;
    case VCF_CUTOFF:
      IVCF<0>::set_cutoff(controller_value);
      break;
    case VCF_RESONANCE:
      IVCF<0>::set_resonance(controller_value);
      break;
    case VCF_CUTOFF_EG_AMT:
      IVCF<0>::set_cutoff_eg_amt(controller_value);
      break;
    case VCA_GAIN:
      IVCA<0>::set_gain(controller_value);
      break;
    case EG_ATTACK:
      IEG<0>::set_attack(controller_value);
      break;
    case EG_DECAY_RELEASE:
      IEG<0>::set_decay_release(controller_value);
      break;
    case EG_SUSTAIN:
      IEG<0>::set_sustain(controller_value);
      break;
    case ALL_NOTES_OFF:
      IEG<0>::note_off();
      break;
    }
  }

  INLINE static int8_t clock() {
    uint8_t  eg_output = IEG<0>::clock();
    int8_t   lfo_output = ILFO<0>::clock(eg_output);
    uint16_t srl_output = ISlewRateLimiter<0>::clock(m_note_number << 8);
    int16_t  vco_output = IVCO<0>::clock(srl_output, eg_output, lfo_output);
    int16_t  vcf_output = IVCF<0>::clock(vco_output, eg_output);
    int16_t  vca_output = IVCA<0>::clock(vcf_output, eg_output);
    return high_sbyte(vca_output);
  }
};

template <uint8_t T> uint8_t Voice<T>::m_note_number;
