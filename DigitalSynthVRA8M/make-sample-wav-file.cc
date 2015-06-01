#define PROGMEM

typedef signed   char  boolean;
typedef signed   char  int8_t;
typedef unsigned char  uint8_t;
typedef signed   short int16_t;
typedef unsigned short uint16_t;
typedef unsigned int   uint32_t;

inline uint8_t pgm_read_byte(const uint8_t* p) {
  return *p;
}

inline uint16_t pgm_read_word(const uint16_t* p) {
  return *p;
}

#include <stdio.h>
#include "common.h"
#include "synth.h"
#include "wav-file-out.h"

const char*    MIDI_STREAM_FILE = "sample-midi-stream.bin";
const char*    RECORDING_FILE = "a.wav";
const uint16_t RECORDING_SEC = 60;

int main() {
  // setup
  Synth::initialize();
  FILE* bin_file = ::fopen(MIDI_STREAM_FILE, "rb");
  WAVFileOut::open(RECORDING_FILE, RECORDING_SEC);

  // loop
  int c;
  while ((c = ::fgetc(bin_file)) != EOF) {
    Synth::receive_midi_byte(c);
    uint16_t r = SAMPLING_RATE / (SERIAL_SPEED / 10);
    for (uint16_t i = 0; i < r; i++) {
      uint8_t level = Synth::clock();
      WAVFileOut::write(level);
    }
  }

  // teardown
  WAVFileOut::close();
  ::fclose(bin_file);

  return 0;
}
