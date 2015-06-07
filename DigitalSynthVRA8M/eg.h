#pragma once

#include "common.h"
#include "eg-table.h"

class EG {
  static const uint8_t  STATE_ATTACK        = 0;
  static const uint8_t  STATE_DECAY_SUSTAIN = 1;
  static const uint8_t  STATE_RELEASE       = 2;
  static const uint8_t  STATE_IDLE          = 3;

  static uint8_t  m_state;
  static uint16_t m_decay_release_count;
  static uint16_t m_level;
  static uint16_t m_attack_rate;
  static uint16_t m_decay_release_update_interval;
  static uint16_t m_sustain_level;

public:
  static void initialize() {
    m_state = STATE_IDLE;
    m_decay_release_count = 0;
    m_level = 0;
    set_attack(0);
    set_decay_release(0);
    set_sustain(127);
  }

  static void set_attack(uint8_t controller_value) {
    m_attack_rate = pgm_read_word(g_eg_attack_rate_table + controller_value);
  }

  static void set_decay_release(uint8_t controller_value) {
    m_decay_release_update_interval = pgm_read_word(g_eg_decay_release_update_interval_table +
                                                    controller_value);
  }

  static void set_sustain(uint8_t controller_value) {
    m_sustain_level = (controller_value << 1) << 8;
  }

  static void note_on() {
    m_state = STATE_ATTACK;
    m_decay_release_count = 0;
  }

  static void note_off() {
    m_state = STATE_RELEASE;
    m_decay_release_count = 0;
  }

  static int8_t clock() {
    switch (m_state) {
    case STATE_ATTACK:
      if (m_level >= EG_LEVEL_MAX - m_attack_rate) {
        m_state = STATE_DECAY_SUSTAIN;
        m_level = EG_LEVEL_MAX;
      } else {
        m_level += m_attack_rate;
      }
      break;
    case STATE_DECAY_SUSTAIN:
      m_decay_release_count++;
      if (m_decay_release_count >= m_decay_release_update_interval) {
        m_decay_release_count = 0;
        if (m_level > m_sustain_level) {
          if (m_level <= m_sustain_level + (EG_LEVEL_MAX >> 10)) {
            m_level = m_sustain_level;
          } else {
            m_level = m_sustain_level +
                      mul_q16_q16(m_level - m_sustain_level, EG_DECAY_RELEASE_RATE);
          }
        }
      }
      break;
    case STATE_RELEASE:
      m_decay_release_count++;
      if (m_decay_release_count >= m_decay_release_update_interval) {
        m_decay_release_count = 0;
        if (m_level <= EG_LEVEL_MAX >> 10) {
          m_state = STATE_IDLE;
          m_level = 0;
        } else {
          m_level = mul_q16_q16(m_level, EG_DECAY_RELEASE_RATE);
        }
      }
      break;
    case STATE_IDLE:
      m_level = 0;
      break;
    }
    return high_byte(m_level);
  }
};

uint8_t  EG::m_state;
uint16_t EG::m_decay_release_count;
uint16_t EG::m_level;
uint16_t EG::m_attack_rate;
uint16_t EG::m_decay_release_update_interval;
uint16_t EG::m_sustain_level;
