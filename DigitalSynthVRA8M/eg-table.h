#pragma once

const uint16_t g_eg_attack_rate_table[] PROGMEM = {
   2000,  2000,  1589,  1262,  1002,   796,   632,   502,   399,   317,   252,   200,   159,   126,   100,    80,
     63,    50,    40,    32,    25,    20,    16,    13,    10,     8,     6,     5,     4,     3,     3,     2,
  };

const uint16_t EG_DECAY_RELEASE_RATE = 245;

const uint16_t g_eg_decay_release_update_interval_table[] PROGMEM = {
      1,     1,     2,     2,     3,     3,     4,     5,     6,     8,    10,    13,    16,    20,    25,    32,
     40,    50,    64,    80,   101,   127,   160,   201,   253,   318,   401,   504,   635,   800,  1007,  1267,
  };

