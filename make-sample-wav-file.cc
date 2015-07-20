#define PROGMEM

typedef signed   char  boolean;
typedef signed   char  int8_t;
typedef unsigned char  uint8_t;
typedef signed   short int16_t;
typedef unsigned short uint16_t;
typedef unsigned int   uint32_t;

inline uint8_t pgm_read_byte(const void* addr) {
  const uint8_t* p = (const uint8_t*) addr;
  return p[0];
}

inline uint16_t pgm_read_word(const void* addr) {
  // for little endian cpu
  const uint8_t* p = (const uint8_t*) addr;
  return p[0] | (p[1] << 8);
}

#include <stdio.h>
#include "./DigitalSynthVRA8M/common.h"
#include "./DigitalSynthVRA8M/synth.h"
#include "./DigitalSynthVRA8M/wav-file-out.h"

const uint16_t RECORDING_SEC = 60;

int main(int argc, char *argv[]) {
  // setup
  Synth::initialize();
  FILE* bin_file = ::fopen(argv[1], "rb");
  WAVFileOut::open(argv[2], RECORDING_SEC);

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
