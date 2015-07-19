#pragma once

const uint8_t EG_ATTACK_UPDATE_INTERVAL = 2;

const uint16_t g_eg_attack_rate_table[] = {
   2000,  2000,  1589,  1262,  1002,   796,   632,   502,   399,   317,   252,   200,   159,   126,   100,    80,
     63,    50,    40,    32,    25,    20,    16,    13,    10,     8,     6,     5,     4,     3,     3,     2,
  };

const uint8_t g_eg_decay_release_rate_table[] = {
    215,   215,   215,   215,   215,   215,   215,   215,   215,   215,   215,   215,   245,   245,   245,   245,
    245,   245,   245,   245,   245,   245,   251,   251,   251,   251,   251,   251,   251,   251,   251,   251,
  };

const uint16_t g_eg_decay_release_update_interval_table[] = {
      5,     5,     6,     8,    10,    12,    16,    20,    25,    31,    39,    49,    16,    20,    25,    31,
     39,    49,    62,    78,    98,   124,    79,    99,   125,   157,   198,   249,   313,   395,   497,   625,
  };

