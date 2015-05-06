require './common'

$file = File::open("env-table.rb", "w")

env_attack_factor = (((1.0 / 2.0) ** (1.0 / 160.0)) * 65536.0).round
env_decay_factor = (((1.0 / 2.0) ** (1.0 / 32.0)) * 65536.0).round

$file.printf("ENV_ATTACK_FACTOR = %d\n", env_attack_factor)
$file.printf("ENV_DECAY_FACTOR = %d\n", env_decay_factor)
$file.printf("\n")

$file.printf("$env_table_interval_from_time = [\n  ")
(0..127).each do |time|
  t = [time, 32].max
  sec = 10.0 / (10.0 ** ((128.0 - t) / (128.0 / 4.0)))
  interval = (sec * SAMPLING_RATE) / (Math.log(1.0 / 2.0) /
                                      Math.log(env_attack_factor / 65536.0))

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
