require './common'

$file = File::open("env-table.rb", "w")

$file.printf("$env_table_attack_interval_from_time = [\n  ")
(0..127).each do |time|
  t = [time, 32].max
  sec = 10.0 / (10.0 ** ((128.0 - t) / (128.0 / 4.0)))
  interval = (sec * SAMPLING_RATE) / (Math.log(1.0 / 2.0) /
                                      Math.log(EG_CHANGE_FACTOR / 65536.0))

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

$file.printf("$env_table_decay_interval_from_time = [\n  ")
(0..127).each do |time|
  t = [time, 32].max
  sec = 10.0 / (10.0 ** ((128.0 - t) / (128.0 / 4.0)))
  interval = (sec * SAMPLING_RATE) / (Math.log(1.0 / 32.0) /
                                      Math.log(EG_CHANGE_FACTOR / 65536.0))

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
