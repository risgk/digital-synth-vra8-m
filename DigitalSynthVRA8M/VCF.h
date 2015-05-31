#pragma once

#include "common.h"
#include "vcf-table.h"

// refs http://www.musicdsp.org/files/Audio-EQ-Cookbook.txt

class VCF
{
  static int16_t         m_x_1;
  static int16_t         m_x_2;
  static int16_t         m_y_1;
  static int16_t         m_y_2;
  static uint16_t        m_cutoff;
  static const uint16_t* m_lpf_table;
  static uint8_t         m_cv_amt;

public:
  static void initialize()
  {
    m_x_1 = 0;
    m_x_2 = 0;
    m_y_1 = 0;
    m_y_2 = 0;
    set_cutoff(127);
    set_resonance(0);
    set_cv_amt(0);
  }

  static void set_cutoff(uint8_t controller_value)
  {
    m_cutoff = controller_value;
  }

  static void set_resonance(uint8_t controller_value)
  {
    if (controller_value >= 96) {
      m_lpf_table = g_vcf_lpf_table_q_2_sqrt_2;
    } else if (controller_value >= 32) {
      m_lpf_table = g_vcf_lpf_table_q_1_sqrt_2;
    } else {
      m_lpf_table = g_vcf_lpf_table_q_1_over_sqrt_2;
    }
  }

  static void set_cv_amt(uint8_t controller_value)
  {
    m_cv_amt = controller_value;
  }

  static int8_t clock(int8_t audio_input, uint8_t cutoff_control)
  {
    uint8_t cutoff = m_cutoff + high_byte(m_cv_amt * cutoff_control);
    if (cutoff > 127) {
      cutoff = 127;
    }

    const uint16_t* p = m_lpf_table + (cutoff * 3);
    int16_t b_2_over_a_0 = pgm_read_word(p++);
    int16_t a_1_over_a_0 = pgm_read_word(p++);
    int16_t a_2_over_a_0 = pgm_read_word(p++);

    int16_t x_0 = audio_input << 8;

    int16_t tmp  = mul_q15_q15(b_2_over_a_0, x_0 + m_x_2);
    tmp         += mul_q15_q15(b_2_over_a_0, m_x_1 << 1);
    tmp         -= mul_q15_q15(a_1_over_a_0, m_y_1);
    tmp         -= mul_q15_q15(a_2_over_a_0, m_y_2);
    int16_t y_0 = tmp << ((15 - VCF_TABLE_FRACTION_BITS) << 1);
    m_x_2 = m_x_1;
    m_y_2 = m_y_1;
    m_x_1 = x_0;
    m_y_1 = y_0;

    return high_sbyte(y_0);
  }
};

int16_t         VCF::m_x_1;
int16_t         VCF::m_x_2;
int16_t         VCF::m_y_1;
int16_t         VCF::m_y_2;
uint16_t        VCF::m_cutoff;
const uint16_t* VCF::m_lpf_table;
uint8_t         VCF::m_cv_amt;
