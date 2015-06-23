#pragma once

#include "common.h"

template <uint8_t T>
class LFO {
  static uint16_t m_phase;
  static uint8_t  m_rate;

public:
  INLINE static void initialize() {
    m_phase = 0x4000;
    set_rate(0);
  }

  INLINE static void set_rate(uint8_t controller_value) {
    m_rate = (controller_value >> 2) + 1;
  }

  INLINE static int8_t clock() {
    m_phase += m_rate;
    uint16_t level = m_phase;
    if ((level & 0x8000) != 0) {
      level = ~level;
    }
    level -= 0x4000;
    return high_sbyte(level << 1);
  }
};

template <uint8_t T> uint16_t LFO<T>::m_phase;
template <uint8_t T> uint8_t  LFO<T>::m_rate;
