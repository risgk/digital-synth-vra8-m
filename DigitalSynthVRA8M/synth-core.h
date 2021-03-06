#pragma once

#include "common.h"

template <uint8_t T>
class SynthCore {
  static uint8_t m_system_exclusive;
  static uint8_t m_system_data_remaining;
  static uint8_t m_running_status;
  static uint8_t m_first_data;
  static uint8_t m_note_number;

public:
  INLINE static void initialize() {
    IVoice<0>::initialize();
    m_note_number = NOTE_NUMBER_MIN;
    m_system_exclusive = false;
    m_system_data_remaining = 0;
    m_running_status = STATUS_BYTE_INVALID;
    m_first_data = DATA_BYTE_INVALID;

    // Preset Lead
    control_change(LFO_RATE         , 0  );
    control_change(LFO_RATE_EG_AMT  , 0  );
    control_change(LFO_LEVEL_EG_COEF, 127);
    control_change(VCO_COLOR_LFO_AMT, 64 );
    control_change(VCO_MIX          , 0  );
    control_change(VCO_MIX_EG_AMT   , 127);
    control_change(VCO_PULSE_WIDTH  , 0  );
    control_change(VCO_SAW_SHIFT    , 64 );
    control_change(VCO_PORTAMENTO   , 64 );
    control_change(VCF_CUTOFF       , 0  );
    control_change(VCF_CUTOFF_EG_AMT, 127);
    control_change(VCF_RESONANCE    , 64 );
    control_change(VCA_GAIN         , 127);
    control_change(EG_ATTACK        , 32 );
    control_change(EG_DECAY_RELEASE , 96 );
    control_change(EG_SUSTAIN       , 127);
  }

  INLINE static void receive_midi_byte(uint8_t b) {
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

  INLINE static int8_t clock() {
    return IVoice<0>::clock();
  }

private:
  INLINE static boolean is_real_time_message(uint8_t b) {
    return b >= REAL_TIME_MESSAGE_MIN;
  }

  INLINE static boolean is_system_message(uint8_t b) {
    return b >= SYSTEM_MESSAGE_MIN;
  }

  INLINE static boolean is_status_byte(uint8_t b) {
    return b >= STATUS_BYTE_MIN;
  }

  INLINE static boolean is_data_byte(uint8_t b) {
    return b <= DATA_BYTE_MAX;
  }

  INLINE static void note_on(uint8_t note_number) {
    m_note_number = note_number;
    IVoice<0>::note_on(m_note_number);
  }

  INLINE static void note_off(uint8_t note_number) {
    if (m_note_number == note_number) {
      m_note_number = 0xFF;
      IVoice<0>::note_off();
    }
  }

  INLINE static void control_change(uint8_t controller_number, uint8_t controller_value) {
    switch (controller_number) {
    case ALL_NOTES_OFF:
      m_note_number = 0xFF;
      IVoice<0>::note_off();
      break;
    default:
      IVoice<0>::control_change(controller_number, controller_value);
      break;
    }
  }
};

template <uint8_t T> uint8_t SynthCore<T>::m_system_exclusive;
template <uint8_t T> uint8_t SynthCore<T>::m_system_data_remaining;
template <uint8_t T> uint8_t SynthCore<T>::m_running_status;
template <uint8_t T> uint8_t SynthCore<T>::m_first_data;
template <uint8_t T> uint8_t SynthCore<T>::m_note_number;
