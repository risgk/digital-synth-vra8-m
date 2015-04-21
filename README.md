# Digital Synth VRA8-M 0.0.0

- 2015-04-21 ISGK Instruments
- <https://github.com/risgk/DigitalSynthVRA8M>

## Concept

- 8-bit Virtual Analog (Monophonic) Synthesizer
- No Keyboard, MIDI Sound Module
- For Arduino Uno

## VRA8-M Features

- Sketch for Arduino Uno
- Serial MIDI In (38400 bps), PWM Audio Out (Pin 6), PWM Rate: 62500 Hz
- Sampling Rate: 15625 Hz, Bit Depth: 8 bits
- Recommending [Hairless MIDI<->Serial Bridge](http://projectgus.github.io/hairless-midiserial/) to connect PC
- Files
    - "DigitalSynthVRA8M.ino" for Arduino Uno
    - "MakeSampleWavFile.cc" for Debugging on PC, makes a sample WAV file

## VRA8-M Ruby Edition Features

- Simulator of VRA8-M, Software Synthesizer for Windows
- Sampling Rate: 15625 Hz, Bit Depth: 8 bits
- Using Ruby (JRuby), UniMIDI, and win32-sound
    - `jgem install unimidi`
    - `jgem install win32-sound`
- Usage
    - `jruby main.rb` starts VRA8-M Ruby Edition
    - `jruby main.rb sample-midi-stream.bin` makes a sample WAV file
- Known Issues
    - VRA8-M Ruby Edition uses the full power of 2 CPU cores...

## VRA8-M CTRL Features

- Parameter Editor (MIDI Controller) for VRA8-M, HTML5 App
- Please enable Web MIDI API of Google Chrome
    - `chrome://flags/#enable-web-midi`
- Recommending [loopMIDI](http://www.tobias-erichsen.de/software/loopmidi.html) (virtual loopback MIDI cable) to connect VRA8-M

## Controllers

    +----------------+----------+----------+-----------+-----------+------------+-----------------+
    | Controller     | 0        | 42       | 64        | 85        | 127        | Notes           |
    +----------------+----------+----------+-----------+-----------+------------+-----------------+
    | VCO Mix        | Saw 100% | ...      | ...       | ...       | Pulse 100% | Saw/Pulse       |
    | VCO SS         | -360 deg | ...      | -270 deg  | ...       | 181.4 deg  | Saw Shift       |
    | VCO SS LFO Amt | 0%       | ...      | 50.4%     | ...       | 100%       |                 |
    | VCO PW         | 1/2      | ...      | 1/4       | ...       | 1/128      | Pulse Width     |
    | VCO PW LFO Amt | 0%       | ...      | 50.4%     | ...       | 100%       |                 |
    +----------------+----------+----------+-----------+-----------+------------+-----------------+
    | VCF Cutoff     | 488.3 Hz | 971.2 Hz | ...       | 1963.8 Hz | 3906.3 Hz  |                 |
    | VCF Resonance  | Q = 0.7  | Q = 1.0  | ...       | Q = 1.4   | Q = 2.0    | Only 4 patterns |
    | VCF EG Amt     | -100%    | ...      | 0%        | ...       | +98.4%     |                 |
    +----------------+----------+----------+-----------+-----------+------------+-----------------+
    | EG Attack      | 10 ms    | 98.2 ms  |           | 1018.3 ms | 10000 ms   |                 |
    | EG Decay       | 10 ms    | 98.2 ms  |           | 1018.3 ms | 10000 ms   |                 |
    | EG Sustain     | 0%       | ...      | 50.4%     | ...       | 100%       |                 |
    +----------------+----------+----------+-----------+-----------+------------+-----------------+
    | LFO Rate       | 0.07 Hz  | ...      | 4.2 Hz    | ...       | 8.4 Hz     |                 |
    +----------------+----------+----------+-----------+-----------+------------+-----------------+
    | Portamento     |          | ...      |   cent/ms |           |            |                 |
    +----------------+----------+----------+-----------+-----------+------------+-----------------+

## MIDI Implementation Chart

      [Virtual Analog Synthesizer]                                    Date: 2015-04-21       
      Model  Digital Synth VRA8-M     MIDI Implementation Chart       Version: 0.0.0         
    +-------------------------------+---------------+---------------+-----------------------+
    | Function...                   | Transmitted   | Recognized    | Remarks               |
    +-------------------------------+---------------+---------------+-----------------------+
    | Basic        Default          | x             | 1             |                       |
    | Channel      Changed          | x             | x             |                       |
    +-------------------------------+---------------+---------------+-----------------------+
    | Mode         Default          | x             | Mode 4 (M=1)  |                       |
    |              Messages         | x             | x             |                       |
    |              Altered          | ************* |               |                       |
    +-------------------------------+---------------+---------------+-----------------------+
    | Note                          | x             | 0-127         |                       |
    | Number       : True Voice     | ************* | 24-96         |                       |
    +-------------------------------+---------------+---------------+-----------------------+
    | Velocity     Note ON          | x             | x             |                       |
    |              Note OFF         | x             | x             |                       |
    +-------------------------------+---------------+---------------+-----------------------+
    | After        Key's            | x             | x             |                       |
    | Touch        Ch's             | x             | x             |                       |
    +-------------------------------+---------------+---------------+-----------------------+
    | Pitch Bend                    | x             | x             |                       |
    +-------------------------------+---------------+---------------+-----------------------+
    | Control                    14 | x             | o             | VCO Mix               |
    | Change                     15 | x             | o             | VCO SS                |
    |                            16 | x             | o             | VCO SS LFO Amt        |
    |                            17 | x             | o             | VCO PW                |
    |                            18 | x             | o             | VCO PW LFO Amt        |
    |                            19 | x             | o             | VCF Cutoff            |
    |                            20 | x             | o             | VCF Resonance         |
    |                            21 | x             | o             | VCF EG Amt            |
    |                            22 | x             | o             | EG Attack             |
    |                            23 | x             | o             | EG Decay              |
    |                            24 | x             | o             | EG Sustain            |
    |                            25 | x             | o             | LFO Rate              |
    |                            26 | x             | o             | Portamento            |
    +-------------------------------+---------------+---------------+-----------------------+
    | Program                       | x             | x             |                       |
    | Change       : True #         | ************* |               |                       |
    +-------------------------------+---------------+---------------+-----------------------+
    | System Exclusive              | x             | x             |                       |
    +-------------------------------+---------------+---------------+-----------------------+
    | System       : Song Pos       | x             | x             |                       |
    | Common       : Song Sel       | x             | x             |                       |
    |              : Tune           | x             | x             |                       |
    +-------------------------------+---------------+---------------+-----------------------+
    | System       : Clock          | x             | x             |                       |
    | Real Time    : Commands       | x             | x             |                       |
    +-------------------------------+---------------+---------------+-----------------------+
    | Aux          : Local ON/OFF   | x             | x             |                       |
    | Messages     : All Notes OFF  | x             | o             |                       |
    |              : Active Sense   | x             | x             |                       |
    |              : Reset          | x             | x             |                       |
    +-------------------------------+---------------+---------------+-----------------------+
    | Notes                         |                                                       |
    |                               |                                                       |
    +-------------------------------+-------------------------------------------------------+
      Mode 1: Omni On,  Poly          Mode 2: Omni On,  Mono          o: Yes                 
      Mode 3: Omni Off, Poly          Mode 4: Omni Off, Mono          x: No                  
