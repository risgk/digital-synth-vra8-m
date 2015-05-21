require_relative 'common'
require 'win32/sound'

class AudioOut
  extend Windows::SoundFunctions

  class << self
    include Windows::SoundStructs

    WAVE_MAPPER = -1
    WHDR_DONE = 0x00000001

    def open(buffer_size, num_of_buffer)
      @buffer_size = buffer_size
      @num_of_buffer = num_of_buffer

      @hwaveout = HWAVEOUT.new
      @waveformatex = WAVEFORMATEX.new(SAMPLING_RATE, 8, 1)
      waveOutOpen(@hwaveout.pointer, WAVE_MAPPER, @waveformatex.pointer, 0, 0, 0)

      @buffer = []
      @wavehdr = []
      @array = Array.new(@buffer_size, 0x80)
      (0...@num_of_buffer).each do |i|
        @buffer[i] = FFI::MemoryPointer.new(:uint8, @buffer_size)
        @buffer[i].write_array_of_uint8(@array)
        @wavehdr[i] = WAVEHDR.new(@buffer[i], @buffer_size)
        waveOutPrepareHeader(@hwaveout[:i], @wavehdr[i].pointer, @wavehdr[i].size)
        waveOutWrite(@hwaveout[:i], @wavehdr[i].pointer, @wavehdr[i].size)
      end

      @index = 0
      @array = []
    end

    def write(audio_input)
      @array.push(audio_input + 0x80)
      if (@array.length == @buffer_size)
        while ((@wavehdr[@index][:dwFlags] & WHDR_DONE) == 0)
          # do nothing
        end
        waveOutUnprepareHeader(@hwaveout[:i], @wavehdr[@index].pointer, @wavehdr[@index].size)
        @buffer[@index].write_array_of_uint8(@array)
        waveOutPrepareHeader(@hwaveout[:i], @wavehdr[@index].pointer, @wavehdr[@index].size)
        waveOutWrite(@hwaveout[:i], @wavehdr[@index].pointer, @wavehdr[@index].size)
        @index = (@index + 1) % @num_of_buffer
        @array = []
      end
    end
  end
end
