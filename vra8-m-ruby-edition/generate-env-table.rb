require_relative 'common'

$file = File.open("env-table.rb", "w")

$file.printf("$env_table_attack_rate = [\n  ")
(0..127).each do |time|
  sec = (EG_LEVEL_MAX.to_f / 15625) / (10.0 ** ((127.0 - time) / (127.0 / 3.0))) / 2.0
  interval = EG_LEVEL_MAX / (sec * SAMPLING_RATE)
  r = interval.round.to_i
  $file.printf("%5d,", r)
  if time == 127
    $file.printf("\n")
  elsif time % 16 == 15
    $file.printf("\n  ")
  else
    $file.printf(" ")
  end
end
$file.printf("]\n\n")

env_decay_factor = (((1.0 / 2.0) ** (1.0 / 16.0)) * 65536.0).round
$file.printf("ENV_DECAY_FACTOR = %d\n", env_decay_factor)
$file.printf("\n")

$file.printf("$env_table_decay_interval = [\n  ")
(0..127).each do |time|
  sec = 12.8 / (10.0 ** ((127.0 - time) / (127.0 / 3.0)))
  interval = (sec * SAMPLING_RATE) / (Math.log(1.0 / 1024.0) /
                                      Math.log(env_decay_factor / 65536.0))
  r = interval.round.to_i
  $file.printf("%5d,", r)
  if time == 127
    $file.printf("\n")
  elsif time % 16 == 15
    $file.printf("\n  ")
  else
    $file.printf(" ")
  end
end
$file.printf("]\n\n")
