#pragma once

#include "common.h"

class VCA
{
  static uint8_t m_gain;

public:
  void initialize()
  {
    set_gain(64);
  }

  void set_gain(uint8_t controller_value)
  {
    m_gain = controller_value << 1;
  }

  static int8_t clock(int8_t audio_input, uint8_t gain_control)
  {
    uint8_t g = high_byte(m_gain * gain_control);
    return high_sbyte(audio_input * g);
  }
};
