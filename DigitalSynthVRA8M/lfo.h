#pragma once

#include "common.h"

template <uint8_t T>
class LFO {
  static uint16_t m_phase;
  static uint8_t  m_level_eg_coef;
  static uint8_t  m_rate;

public:
  INLINE static void initialize() {
    m_phase = 0x4000;
    set_level_eg_coef(0);
    set_rate(0);
  }

  INLINE static void set_level_eg_coef(uint8_t controller_value) {
    m_level_eg_coef = controller_value << 1;
  }

  INLINE static void set_rate(uint8_t controller_value) {
    m_rate = (controller_value >> 1) + 1;
  }

  INLINE static int8_t clock(uint8_t rate_eg_control) {
    m_phase += m_rate;
    uint16_t level = m_phase;
    if ((level & 0x8000) != 0) {
      level = ~level;
    }
    level -= 0x4000;
    level = high_sbyte(high_sbyte(level << 1) *
                       (high_byte(m_level_eg_coef * rate_eg_control) +
                        static_cast<uint8_t>(254 - m_level_eg_coef)));
    return level;
  }
};

template <uint8_t T> uint16_t LFO<T>::m_phase;
template <uint8_t T> uint8_t  LFO<T>::m_level_eg_coef;
template <uint8_t T> uint8_t  LFO<T>::m_rate;
