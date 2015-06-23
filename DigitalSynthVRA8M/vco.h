#pragma once

#include "common.h"
#include "mul-q.h"
#include "vco-table.h"

template <uint8_t T>
class VCO {
   static const uint8_t* m_wave_table;
   static uint16_t       m_phase;
   static uint8_t        m_pulse_saw_mix;
   static uint16_t       m_pulse_width;
   static uint16_t       m_saw_shift;
   static uint8_t        m_color_lfo_amt;

public:
  INLINE static void initialize() {
    m_wave_table = NULL;
    m_phase = 0;
    set_pulse_saw_mix(0);
    set_pulse_width(0);
    set_saw_shift(0);
    set_color_lfo_amt(0);
  }

  INLINE static void set_pulse_saw_mix(uint8_t controller_value) {
    m_pulse_saw_mix = controller_value;
  }

  INLINE static void set_pulse_width(uint8_t controller_value) {
    m_pulse_width = (controller_value + 128) << 8;
  }

  INLINE static void set_saw_shift(uint8_t controller_value) {
    m_saw_shift = controller_value << 8;
  }

  INLINE static void set_color_lfo_amt(uint8_t controller_value) {
    m_color_lfo_amt = controller_value << 1;
  }

  INLINE static int16_t clock(uint16_t pitch_control, int8_t phase_control) {
    uint8_t coarse_pitch = high_byte(pitch_control);
    uint8_t fine_pitch = low_byte(pitch_control);

    m_wave_table = g_vco_wave_tables[coarse_pitch];
    uint16_t freq = mul_q16_q16(g_vco_freq_table[coarse_pitch],
                                g_vco_tune_rate_table[fine_pitch >>
                                                      (8 - VCO_TUNE_RATE_TABLE_STEPS_BITS)]);
    m_phase += freq;

    int8_t saw_down      = +get_saw_wave_level(m_phase);
    int8_t saw_up        = -get_saw_wave_level(
                              (m_phase + m_pulse_width - (phase_control * m_color_lfo_amt)));
    int8_t saw_down_copy = +get_saw_wave_level(
                              (m_phase + m_saw_shift + (phase_control * m_color_lfo_amt)));

    int16_t mixed = saw_down      * 127 +
                    saw_up        * static_cast<uint8_t>(127 - m_pulse_saw_mix) +
                    saw_down_copy * high_byte(m_pulse_saw_mix * 192);

    return mixed >> 1;
  }

private:
  INLINE static int8_t get_saw_wave_level(uint16_t phase) {
    uint8_t curr_index = high_byte(phase);
    uint16_t tmp = pgm_read_word(m_wave_table + curr_index);
    int8_t curr_data = low_byte(tmp);
    int8_t next_data = high_byte(tmp);

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

template <uint8_t T> const uint8_t* VCO<T>::m_wave_table;
template <uint8_t T> uint16_t       VCO<T>::m_phase;
template <uint8_t T> uint8_t        VCO<T>::m_pulse_saw_mix;
template <uint8_t T> uint16_t       VCO<T>::m_pulse_width;
template <uint8_t T> uint16_t       VCO<T>::m_saw_shift;
template <uint8_t T> uint8_t        VCO<T>::m_color_lfo_amt;
