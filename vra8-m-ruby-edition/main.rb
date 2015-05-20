# VRA8-M Ruby Edition

require_relative 'common'
require_relative 'synth'
require_relative 'audio-out'
require_relative 'wav-file-out'

RECORDING_FILE = "a.wav"
RECORDING_SEC = 60
RECORDING_REAL_TIME = false

AUDIO_OUT_BUFFER_SIZE = 500
AUDIO_OUT_NUM_OF_BUFFER = 4

$synth = Synth.new

if ARGV.length == 1

  # make WAV file

  File.open(ARGV[0], "rb") do |bin_file|
    wav_file_out = WAVFileOut.new(RECORDING_FILE, RECORDING_SEC)
    while(c = bin_file.read(1)) do
      b = c.ord
      $synth.receive_midi_byte(b)
      4.times do
        a = $synth.clock
        wav_file_out.write(a)
      end
    end
    wav_file_out.close
  end

else

  # real time play

  require 'unimidi'
  # workaround: midi-jruby (0.0.12) cannot receive a data byte 2 with a value of 0
  module MIDIJRuby
    class Input
      class InputReceiver
        def send(msg, timestamp = -1)
          if msg.respond_to?(:get_packed_msg)
            m = msg.get_packed_msg
            @buf << [m & 0xFF, (m & 0xFF00) >> 8, (m & 0xFF0000) >> 16].take(msg.get_length)
          else
            str = String.from_java_bytes(msg.get_data)
            arr = str.unpack("C" * str.length)
            arr.insert(0, msg.get_status)
            @buf << arr
          end
        end
      end
    end
  end

  require 'thread'
  q = Queue.new
  t = Thread.new do
    wav_file_out = WAVFileOut.new(RECORDING_FILE, RECORDING_SEC) if RECORDING_REAL_TIME
    AudioOut.open(AUDIO_OUT_BUFFER_SIZE, AUDIO_OUT_NUM_OF_BUFFER)
    loop do
      if (!q.empty?)
        n = q.pop
        n.each do |e|
          e[:data].each do |b|
            $synth.receive_midi_byte(b)
          end
        end
      end
      a = $synth.clock
      wav_file_out.write(a) if RECORDING_REAL_TIME
      AudioOut.write(a)
    end
  end
  UniMIDI::Input.gets do |input|
    loop do
      m = input.gets
      q.push(m)
    end
  end

end
