# Digital Synth VRA8-M 0.0.0

- 2015-00-00 ISGK Instruments
- <https://github.com/risgk/DigitalSynthVRA8M>

## Concept

- Virtual Analog Synthesizer (MIDI Sound Module) for Arduino Uno

## VRA8-M Features

- Sketch for Arduino Uno
- Serial MIDI In (38400 bps), PWM Audio Out (Pin 6), PWM Rate: 62500 Hz
- Sampling Rate: 15625 Hz, Bit Depth: 8 bits
- Recommending [Hairless MIDI<->Serial Bridge](http://projectgus.github.io/hairless-midiserial/) to connect PC
- Files
    - "DigitalSynthVRA8M.ino" for Arduino Uno
    - "MakeSampleWavFile.cc" for Debugging on PC, that makes a sample WAV file

## VRA8-M Ruby Edition Features

- Simulator of VRA8-M, Software Synthesizer for Windows
- Sampling Rate: 15625 Hz, Bit Depth: 8 bits
- Requiring Ruby (JRuby), UniMIDI, and win32-sound
    - `jgem install unimidi`
    - `jgem install win32-sound`
- Usage
    - `jruby main.rb` starts VRA8-M Ruby Edition
    - `jruby main.rb sample-midi-stream.bin` makes a sample WAV file
- Known Issues
    - VRA8-M Ruby Edition spends the full power of 2 CPU cores...

## VRA8-M CTRL Features

- Parameter Editor (MIDI Controller) for VRA8-M, HTML5 App
- We recommend Google Chrome, which implements Web MIDI API
- Recommending [loopMIDI](http://www.tobias-erichsen.de/software/loopmidi.html) (virtual loopback MIDI cable) to connect VRA8-M

## Controllers

    +-------------------+---------------+---------------+---------------+
    | Controller        | Value 0       | Value 64      | Value 127     |
    +-------------------+---------------+---------------+---------------+
    | VCO Pulse/Saw Mix | Pulse 100%    | Pulse 50.4%   | Pulse 0%      |
    |                   | Saw 0%        | Saw 49.6%     | Saw 100%      |
    | VCO Pulse Width   | 50%           | 25%           | 0.4%          |
    | VCO Saw Shift     | 0%            | 25%           | 49.6%         |
    +-------------------+---------------+---------------+---------------+
    | VCF Cutoff        | 122.1 Hz      | 976.6 Hz      | 7562.7 Hz     |
    | VCF Resonance     | OFF (Q = 0.7) | ON (Q = 2.8)  | ON (Q = 2.8)  |
    | VCF EG Amt        | 0%            | 50%           | 99.2%         |
    +-------------------+---------------+---------------+---------------+
    | EG Attack         | 2.1 ms        | 67.6 ms       | 2.1 s         |
    | EG Decay/Release  | 10.2 ms       | 415.9 ms      | 10.2 s        |
    | EG Sustain        | 0%            | 50%           | 99.2%         |
    +-------------------+---------------+---------------+---------------+
    | LFO Rate          | 0.24 Hz       | 4.1 Hz        | 7.9 Hz        |
    | LFO VCO Color Amt | 0%            | 50%           | 99.2%         |
    +-------------------+---------------+---------------+---------------+
    | Portamento        | 0.03 ms/Oct   | 7.7 ms/Oct    | 1.0 s/Oct     |
    +-------------------+---------------+---------------+---------------+

## MIDI Implementation Chart

      [Virtual Analog Synthesizer]                                    Date: 2015-00-00       
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
    | Number       : True Voice     | ************* | 36-96         |                       |
    +-------------------------------+---------------+---------------+-----------------------+
    | Velocity     Note ON          | x             | x             |                       |
    |              Note OFF         | x             | x             |                       |
    +-------------------------------+---------------+---------------+-----------------------+
    | After        Key's            | x             | x             |                       |
    | Touch        Ch's             | x             | x             |                       |
    +-------------------------------+---------------+---------------+-----------------------+
    | Pitch Bend                    | x             | x             |                       |
    +-------------------------------+---------------+---------------+-----------------------+
    | Control                    14 | x             | o             | VCO Pulse/Saw Mix     |
    | Change                     15 | x             | o             | VCO Pulse Width       |
    |                            16 | x             | o             | VCO Saw Shift         |
    |                            17 | x             | o             | VCF Cutoff            |
    |                            18 | x             | o             | VCF Resonance         |
    |                            19 | x             | o             | VCF EG Amt            |
    |                            20 | x             | o             | EG Attack             |
    |                            21 | x             | o             | EG Decay/Release      |
    |                            22 | x             | o             | EG Sustain            |
    |                            23 | x             | o             | LFO Rate              |
    |                            24 | x             | o             | LFO VCO Color Amt     |
    |                            25 | x             | o             | Portamento            |
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
