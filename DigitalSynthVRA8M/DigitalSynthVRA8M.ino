#include "Arduino.h"
#include "common.h"
#include "synth.h"
#include "serial-in.h"
#include "audio-out.h"

void setup() {
  Synth::initialize();
  SerialIn::open();
  AudioOut::open();
}

void loop() {
  while(true) {
    if (SerialIn::available()) {
      uint8_t b = SerialIn::read();
      Synth::receiveMIDIByte(b);
    }
    int8_t level = Synth::clock();
    AudioOut::write(level);
  }
}
