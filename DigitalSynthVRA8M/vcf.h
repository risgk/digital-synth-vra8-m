#pragma once

// refs http://www.musicdsp.org/files/Audio-EQ-Cookbook.txt

#include "common.h"
#include "mul-q.h"
#include "vcf-table.h"

template <uint8_t T>
class VCF {
  static int16_t        m_x_1;
  static int16_t        m_x_2;
  static int16_t        m_y_1;
  static int16_t        m_y_2;
  static uint8_t        m_cutoff;
  static const uint8_t* m_lpf_table;
  static uint8_t        m_cutoff_eg_amt;

  static const uint8_t AUDIO_FRACTION_BITS = 14;

public:
  INLINE static void initialize() {
    m_x_1 = 0;
    m_x_2 = 0;
    m_y_1 = 0;
    m_y_2 = 0;
    set_cutoff(127);
    set_resonance(0);
    set_cutoff_eg_amt(0);
  }

  INLINE static void set_cutoff(uint8_t controller_value) {
    m_cutoff = controller_value;
  }

  INLINE static void set_resonance(uint8_t controller_value) {
    if (controller_value >= 96) {
      m_lpf_table = g_vcf_lpf_table_q_4_sqrt_2;
    } else if (controller_value >= 32) {
      m_lpf_table = g_vcf_lpf_table_q_2;
    } else {
      m_lpf_table = g_vcf_lpf_table_q_1_over_sqrt_2;
    }
  }

  INLINE static void set_cutoff_eg_amt(uint8_t controller_value) {
    m_cutoff_eg_amt = controller_value;
  }

  INLINE static int16_t clock(int16_t audio_input, uint8_t cutoff_eg_control) {
    uint8_t cutoff = m_cutoff + high_byte(m_cutoff_eg_amt * cutoff_eg_control);
    if (cutoff > 127) {
      cutoff = 127;
    }

    const uint8_t* p = m_lpf_table + (cutoff * 3);
    uint8_t b_2_over_a_0_low  = *p++;
    int8_t  b_2_over_a_0_high = *p++;
    int8_t  a_1_over_a_0_high = *p;
    int16_t b_2_over_a_0      = b_2_over_a_0_low | (b_2_over_a_0_high << 8);
    int16_t a_2_over_a_0      = (b_2_over_a_0 << 2) - (a_1_over_a_0_high << 8) -
                                                      (1 << VCF_TABLE_FRACTION_BITS);

    int16_t x_0  = audio_input >> (16 - AUDIO_FRACTION_BITS);
    int16_t tmp  = mul_q15_q15(x_0 + (m_x_1 << 1) + m_x_2, b_2_over_a_0);
    tmp         -= mul_q15_q7( m_y_1,                      a_1_over_a_0_high);
    tmp         -= mul_q15_q15(m_y_2,                      a_2_over_a_0);
    int16_t y_0  = tmp << (16 - VCF_TABLE_FRACTION_BITS);

    if (y_0 > ((1 << (AUDIO_FRACTION_BITS - 1)) - 1)) {
      y_0 = ((1 << (AUDIO_FRACTION_BITS - 1)) - 1);
    }
    if (y_0 < -(1 << (AUDIO_FRACTION_BITS - 1))) {
      y_0 = -(1 << (AUDIO_FRACTION_BITS - 1));
    }

    m_x_2 = m_x_1;
    m_y_2 = m_y_1;
    m_x_1 = x_0;
    m_y_1 = y_0;

    return y_0 << 2;
  }
};

template <uint8_t T> int16_t        VCF<T>::m_x_1;
template <uint8_t T> int16_t        VCF<T>::m_x_2;
template <uint8_t T> int16_t        VCF<T>::m_y_1;
template <uint8_t T> int16_t        VCF<T>::m_y_2;
template <uint8_t T> uint8_t        VCF<T>::m_cutoff;
template <uint8_t T> const uint8_t* VCF<T>::m_lpf_table;
template <uint8_t T> uint8_t        VCF<T>::m_cutoff_eg_amt;
