#pragma once

#include "common.h"
#include "vco-table.h"

class VCO {
   static const uint8_t* m_wave_table;
   static uint16_t m_phase;
   static uint8_t  m_pulse_saw_mix;
   static uint16_t m_pulse_width;
   static uint16_t m_saw_shift;
   static uint8_t  m_color_lfo_amt;

public:
  static void initialize() {
    m_wave_table = NULL;
    m_phase = 0;
    set_pulse_saw_mix(0);
    set_pulse_width(0);
    set_saw_shift(0);
    set_color_lfo_amt(0);
  }

  static void set_pulse_saw_mix(uint8_t controller_value) {
    m_pulse_saw_mix = controller_value;
  }

  static void set_pulse_width(uint8_t controller_value) {
    m_pulse_width = (controller_value + 128) << 8;
  }

  static void set_saw_shift(uint8_t controller_value) {
    m_saw_shift = controller_value << 8;
  }

  static void set_color_lfo_amt(uint8_t controller_value) {
    m_color_lfo_amt = controller_value << 1;
  }

  static int8_t clock(uint16_t pitch_control, int8_t phase_control) {
    uint8_t coarse_pitch = high_byte(pitch_control);
    uint8_t fine_pitch = low_byte(pitch_control);

    uint16_t freq = mul_q16_q16(g_vco_freq_table[coarse_pitch], g_vco_tune_rate_table[fine_pitch]);
    m_wave_table = g_vco_wave_tables[coarse_pitch];
    m_phase += freq;

    int8_t saw_down      = +get_level_from_wave_table(m_phase);
    int8_t saw_up        = -get_level_from_wave_table(
                              (m_phase + m_pulse_width - (phase_control * m_color_lfo_amt)));
    int8_t saw_down_copy = +get_level_from_wave_table(
                              (m_phase + m_saw_shift + (phase_control * m_color_lfo_amt)));

    int16_t output = saw_down      * 127 +
                     saw_up        * (127 - m_pulse_saw_mix) +
                     saw_down_copy * high_byte(m_pulse_saw_mix * 192);

    return high_sbyte(output) >> 1;
  }

private:
  static int8_t get_level_from_wave_table(uint16_t phase) {
    uint8_t curr_index = high_byte(phase);
    uint8_t next_index = curr_index + 0x01;

    int8_t curr_data = pgm_read_byte(m_wave_table + curr_index);
    int8_t next_data = pgm_read_byte(m_wave_table + next_index);

    uint8_t curr_weight = -low_byte(phase);
    uint8_t next_weight = -curr_weight;

    int8_t level;
    if (next_weight == 0) {
      level = curr_data;
    } else {
      level = high_sbyte((curr_data * curr_weight) + (next_data * next_weight));
    }

    return level;
  }
};

const uint8_t* VCO::m_wave_table;
uint16_t VCO::m_phase;
uint8_t  VCO::m_pulse_saw_mix;
uint16_t VCO::m_pulse_width;
uint16_t VCO::m_saw_shift;
uint8_t  VCO::m_color_lfo_amt;
