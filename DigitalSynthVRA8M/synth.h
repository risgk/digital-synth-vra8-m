#pragma once

// #define private public  // for tests

#include "common.h"

// associations of units
#define IVCO             VCO
#define IVCF             VCF
#define IVCA             VCA
#define IEG              EG
#define ILFO             LFO
#define ISlewRateLimiter SlewRateLimiter
#define IVoice           Voice
#define ISynthCore       SynthCore

#include "vco.h"
#include "vcf.h"
#include "vca.h"
#include "eg.h"
#include "lfo.h"
#include "slew-rate-limiter.h"
#include "voice.h"
#include "synth-core.h"

template <uint8_t T>
class Synth {
public:
  INLINE static void initialize() {
    ISynthCore<0>::initialize();
  }

  INLINE static void receive_midi_byte(uint8_t b) {
    return ISynthCore<0>::receive_midi_byte(b);
  }

  INLINE static int8_t clock() {
    return ISynthCore<0>::clock();
  }
};
