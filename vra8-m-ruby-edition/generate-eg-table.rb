require_relative 'common'

$file = File.open("eg-table.rb", "w")

$file.printf("$eg_attack_rate_table = [\n  ")
(0..((1 << EG_CONTROLLER_STEPS_BITS) - 1)).each do |time|
  t = time
  t = 1 if t == 0
  sec = (EG_LEVEL_MAX.to_f / SAMPLING_RATE) /
        (10.0 ** ((((1 << EG_CONTROLLER_STEPS_BITS) - 1) - t) /
                  (((1 << EG_CONTROLLER_STEPS_BITS) - 2) / 3.0))) / 2.0
  rate = (EG_LEVEL_MAX / (sec * SAMPLING_RATE)).round.to_i

  $file.printf("%5d,", rate)
  if time == DATA_BYTE_MAX
    $file.printf("\n")
  elsif time % 16 == 15
    $file.printf("\n  ")
  else
    $file.printf(" ")
  end
end
$file.printf("]\n\n")

HALF_LIFE = 16
eg_decay_release_rate = (((1.0 / 2.0) ** (1.0 / HALF_LIFE)) *
                         (1 << EG_DECAY_RELEASE_RATE_DENOMINATOR_BITS)).round
$file.printf("EG_DECAY_RELEASE_RATE = %d\n", eg_decay_release_rate)
$file.printf("\n")

$file.printf("$eg_decay_release_update_interval_table = [\n  ")
(0..((1 << EG_CONTROLLER_STEPS_BITS) - 1)).each do |time|
  t = time
  t = 1 if t == 0
  sec = 12.8 / (10.0 ** ((((1 << EG_CONTROLLER_STEPS_BITS) - 1) - t) /
                         (((1 << EG_CONTROLLER_STEPS_BITS) - 2) / 3.0)))
  update_interval = ((sec * SAMPLING_RATE) /
                     (Math.log(1.0 / 1024.0) /
                      Math.log(eg_decay_release_rate.to_f / (1 << EG_DECAY_RELEASE_RATE_DENOMINATOR_BITS)))
                    ).round.to_i

  $file.printf("%5d,", update_interval)
  if time == DATA_BYTE_MAX
    $file.printf("\n")
  elsif time % 16 == 15
    $file.printf("\n  ")
  else
    $file.printf(" ")
  end
end
$file.printf("]\n\n")

$file.close
