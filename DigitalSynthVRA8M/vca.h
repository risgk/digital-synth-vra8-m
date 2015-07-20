#pragma once

#include "common.h"

template <uint8_t T>
class VCA {
  static uint8_t m_gain;

public:
  INLINE static void initialize() {
    set_gain(127);
  }

  INLINE static void set_gain(uint8_t controller_value) {
    m_gain = controller_value << 1;
  }

  INLINE static int16_t clock(int16_t audio_input, uint8_t gain_control) {
    uint8_t g = high_byte(m_gain * gain_control);
    return high_sbyte(audio_input) * g;
  }
};

template <uint8_t T> uint8_t VCA<T>::m_gain;
