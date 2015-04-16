#include "Arduino.h"
#include "Common.h"
#include "Synth.h"
#include "SerialIn.h"
#include "AudioOut.h"

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
