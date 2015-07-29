#pragma once

#include "common.h"
#include "mul-q.h"
#include "eg-table.h"

template <uint8_t T>
class EG {
  static const uint8_t  STATE_ATTACK        = 0;
  static const uint8_t  STATE_DECAY_SUSTAIN = 1;
  static const uint8_t  STATE_RELEASE       = 2;
  static const uint8_t  STATE_IDLE          = 3;

  static uint8_t  m_state;
  static uint16_t m_count;
  static uint16_t m_level;
  static uint16_t m_attack_rate;
  static uint8_t  m_eg_decay_release_rate;
  static uint16_t m_decay_release_update_interval;
  static uint16_t m_sustain_level;

public:
  INLINE static void initialize() {
    m_state = STATE_IDLE;
    m_count = 0;
    m_level = 0;
    set_attack(0);
    set_decay_release(0);
    set_sustain(127);
  }

  INLINE static void set_attack(uint8_t controller_value) {
    m_attack_rate =
      g_eg_attack_rate_table[controller_value >> (7 - EG_CONTROLLER_STEPS_BITS)];
  }

  INLINE static void set_decay_release(uint8_t controller_value) {
    uint8_t time = controller_value >> (7 - EG_CONTROLLER_STEPS_BITS);
    m_eg_decay_release_rate         = g_eg_decay_release_rate_table[time];
    m_decay_release_update_interval = g_eg_decay_release_update_interval_table[time];
  }

  INLINE static void set_sustain(uint8_t controller_value) {
    m_sustain_level = (controller_value << 1) << 8;
  }

  INLINE static void note_on() {
    m_state = STATE_ATTACK;
    m_count = EG_ATTACK_UPDATE_INTERVAL;
  }

  INLINE static void note_off() {
    m_state = STATE_RELEASE;
    m_count = m_decay_release_update_interval;
  }

  INLINE static int8_t clock() {
    switch (m_state) {
    case STATE_ATTACK:
      m_count--;
      if (m_count == 0) {
        m_count = EG_ATTACK_UPDATE_INTERVAL;
        if (m_level >= EG_LEVEL_MAX - m_attack_rate) {
          m_state = STATE_DECAY_SUSTAIN;
          m_level = EG_LEVEL_MAX;
        } else {
          m_level += m_attack_rate;
        }
      }
      break;
    case STATE_DECAY_SUSTAIN:
      m_count--;
      if (m_count == 0) {
        m_count = m_decay_release_update_interval;
        if (m_level > m_sustain_level) {
          if (m_level <= m_sustain_level + (EG_LEVEL_MAX >> 10)) {
            m_level = m_sustain_level;
          } else {
            m_level = m_sustain_level +
                      mul_q16_q8(m_level - m_sustain_level, m_eg_decay_release_rate);
          }
        }
      }
      break;
    case STATE_RELEASE:
      m_count--;
      if (m_count == 0) {
        m_count = m_decay_release_update_interval;
        if (m_level <= (EG_LEVEL_MAX >> 10)) {
          m_state = STATE_IDLE;
          m_level = 0;
        } else {
          m_level = mul_q16_q8(m_level, m_eg_decay_release_rate);
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

template <uint8_t T> uint8_t  EG<T>::m_state;
template <uint8_t T> uint16_t EG<T>::m_count;
template <uint8_t T> uint16_t EG<T>::m_level;
template <uint8_t T> uint16_t EG<T>::m_attack_rate;
template <uint8_t T> uint8_t  EG<T>::m_eg_decay_release_rate;
template <uint8_t T> uint16_t EG<T>::m_decay_release_update_interval;
template <uint8_t T> uint16_t EG<T>::m_sustain_level;
