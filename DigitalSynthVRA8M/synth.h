#pragma once

#include "common.h"
#include "voice.h"

class Synth {
  static uint8_t m_system_exclusive;
  static uint8_t m_system_data_remaining;
  static uint8_t m_running_status;
  static uint8_t m_first_data;
  static uint8_t m_note_number;

public:
  static void initialize() {
    Voice::initialize();
    m_note_number = NOTE_NUMBER_MIN;
    m_system_exclusive = false;
    m_system_data_remaining = 0;
    m_running_status = STATUS_BYTE_INVALID;
    m_first_data = DATA_BYTE_INVALID;
  }

  static void receive_midi_byte(uint8_t b) {
    if (is_data_byte(b)) {
      if (m_system_exclusive) {
        // do nothing
      } else if (m_system_data_remaining != 0) {
        m_system_data_remaining--;
      } else if (m_running_status == (NOTE_ON | MIDI_CH)) {
        if (!is_data_byte(m_first_data)) {
          m_first_data = b;
        } else if (b == 0) {
          note_off(m_first_data);
          m_first_data = DATA_BYTE_INVALID;
        } else {
          note_on(m_first_data);
          m_first_data = DATA_BYTE_INVALID;
        }
      } else if (m_running_status == (NOTE_OFF | MIDI_CH)) {
        if (!is_data_byte(m_first_data)) {
          m_first_data = b;
        } else {
          note_off(m_first_data);
          m_first_data = DATA_BYTE_INVALID;
        }
      } else if (m_running_status == (CONTROL_CHANGE | MIDI_CH)) {
        if (!is_data_byte(m_first_data)) {
          m_first_data = b;
        } else {
          control_change(m_first_data, b);
          m_first_data = DATA_BYTE_INVALID;
        }
      }
    } else if (is_system_message(b)) {
      switch (b) {
      case SYSTEM_EXCLUSIVE:
        m_system_exclusive = true;
        m_running_status = STATUS_BYTE_INVALID;
        break;
      case EOX:
      case TUNE_REQUEST:
      case 0xF4:
      case 0xF5:
        m_system_exclusive = false;
        m_system_data_remaining = 0;
        m_running_status = STATUS_BYTE_INVALID;
        break;
      case TIME_CODE:
      case SONG_SELECT:
        m_system_exclusive = false;
        m_system_data_remaining = 1;
        m_running_status = STATUS_BYTE_INVALID;
        break;
      case SONG_POSITION:
        m_system_exclusive = false;
        m_system_data_remaining = 2;
        m_running_status = STATUS_BYTE_INVALID;
        break;
      }
    } else if (is_status_byte(b)) {
      m_system_exclusive = false;
      m_running_status = b;
      m_first_data = DATA_BYTE_INVALID;
    }
  }

  static int8_t clock() {
    return Voice::clock();
  }

private:
  static boolean is_real_time_message(uint8_t b) {
    return b >= REAL_TIME_MESSAGE_MIN;
  }

  static boolean is_system_message(uint8_t b) {
    return b >= SYSTEM_MESSAGE_MIN;
  }

  static boolean is_status_byte(uint8_t b) {
    return b >= STATUS_BYTE_MIN;
  }

  static boolean is_data_byte(uint8_t b) {
    return b <= DATA_BYTE_MAX;
  }

  static void note_on(uint8_t note_number) {
    m_note_number = note_number;
    Voice::note_on(m_note_number);
  }

  static void note_off(uint8_t note_number) {
    if (m_note_number == note_number) {
      m_note_number = 0xFF;
      Voice::note_off();
    }
  }

  static void control_change(uint8_t controller_number, uint8_t controller_value) {
    switch (controller_number) {
    case ALL_NOTES_OFF:
      m_note_number = 0xFF;
      Voice::note_off();
      break;
    default:
      Voice::control_change(controller_number, controller_value);
      break;
    }
  }
};

uint8_t Synth::m_system_exclusive;
uint8_t Synth::m_system_data_remaining;
uint8_t Synth::m_running_status;
uint8_t Synth::m_first_data;
uint8_t Synth::m_note_number;
