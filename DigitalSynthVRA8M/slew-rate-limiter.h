#pragma once

#include "common.h"

template <uint8_t T>
class SlewRateLimiter {
  static const uint8_t UPDATE_INTERVAL = 10;

  static uint8_t  m_count;
  static uint16_t m_level;
  static uint16_t m_slew_rate;

public:
  INLINE static void initialize() {
    m_count = 0;
    m_level = NOTE_NUMBER_MIN << 8;
    set_slew_time(NOTE_NUMBER_MIN);
  }

  INLINE static void set_slew_time(uint8_t controller_value) {
    if (controller_value < 4) {
      m_slew_rate = 0x8000;
    } else {
      m_slew_rate = 33 - (controller_value >> 2);
    }
  }

  INLINE static uint16_t clock(uint16_t input) {
    m_count++;
    if (m_count >= UPDATE_INTERVAL) {
      m_count = 0;
      if (m_level > input + m_slew_rate) {
        m_level -= m_slew_rate;
      } else if (m_level + m_slew_rate < input) {
        m_level += m_slew_rate;
      } else {
        m_level = input;
      }
    }
    return m_level;
  }
};

template <uint8_t T> uint8_t  SlewRateLimiter<T>::m_count;
template <uint8_t T> uint16_t SlewRateLimiter<T>::m_level;
template <uint8_t T> uint16_t SlewRateLimiter<T>::m_slew_rate;
