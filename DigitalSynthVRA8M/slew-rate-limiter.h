#pragma once

#include "common.h"

class SlewRateLimiter
{
  static const uint8_t UPDATE_INTERVAL = 5;

  static uint8_t m_count;
  static uint16_t m_level;
  static uint16_t m_slew_rate;

public:
  static void initialize()
  {
    m_count = 0;
    m_level = NOTE_NUMBER_MIN << 8;
    set_slew_time(NOTE_NUMBER_MIN);
  }

  static void set_slew_time(uint8_t controller_value)
  {
    m_slew_rate = 0x8000 >> (controller_value >> 3);
  }

  static uint16_t clock(uint16_t input)
  {
    m_count += 1;
    if (m_count >= UPDATE_INTERVAL) {
      m_count = 0;
      if (m_level > input + m_slew_rate) {
        m_level -= m_slew_rate;
      } else if (m_level < input - m_slew_rate) {
        m_level += m_slew_rate;
      } else {
        m_level = input;
      }
    }
    return m_level;
  }
};
