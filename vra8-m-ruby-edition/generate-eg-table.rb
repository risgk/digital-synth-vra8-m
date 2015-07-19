require_relative 'common'

$file = File.open("eg-table.rb", "w")

EG_ATTACK_UPDATE_INTERVAL = 2
$file.printf("EG_ATTACK_UPDATE_INTERVAL = %d\n", EG_ATTACK_UPDATE_INTERVAL)
$file.printf("\n")

$file.printf("$eg_attack_rate_table = [\n  ")
(0..((1 << EG_CONTROLLER_STEPS_BITS) - 1)).each do |time|
  t = time
  t = 1 if t == 0
  sec = (EG_LEVEL_MAX.to_f / SAMPLING_RATE) * EG_ATTACK_UPDATE_INTERVAL /
        (10.0 ** ((((1 << EG_CONTROLLER_STEPS_BITS) - 1) - t) /
                  (((1 << EG_CONTROLLER_STEPS_BITS) - 2) / 3.0))) / 2.0
  rate = (EG_LEVEL_MAX * EG_ATTACK_UPDATE_INTERVAL / (sec * SAMPLING_RATE)).round.to_i

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

def decay_release_rate(t)
  case t
  when 0..11
    rate = (((1.0 / 2.0) ** (1.0 / 4.0))  *
            (1 << EG_DECAY_RELEASE_RATE_DENOMINATOR_BITS)).round
  when 12..21
    rate = (((1.0 / 2.0) ** (1.0 / 16.0)) *
            (1 << EG_DECAY_RELEASE_RATE_DENOMINATOR_BITS)).round
  when 22..31
    rate = (((1.0 / 2.0) ** (1.0 / 32.0)) *
            (1 << EG_DECAY_RELEASE_RATE_DENOMINATOR_BITS)).round
  end
  rate
end

def decay_release_update_interval(t)
  sec = 10.0 / (10.0 ** ((((1 << EG_CONTROLLER_STEPS_BITS) - 1) - t) /
                         (((1 << EG_CONTROLLER_STEPS_BITS) - 2) / 3.0)))

  # error correction
  case t
  when 22..31
    sec = sec * 1.125
  end

  update_interval = ((sec * SAMPLING_RATE) /
                     (Math.log(1.0 / 256.0) /
                      Math.log(decay_release_rate(t).to_f /
                      (1 << EG_DECAY_RELEASE_RATE_DENOMINATOR_BITS)))
                    ).round.to_i
end

$file.printf("$eg_decay_release_rate_table = [\n  ")
(0..((1 << EG_CONTROLLER_STEPS_BITS) - 1)).each do |time|
  t = time
  t = 1 if t == 0
  rate = decay_release_rate(t)

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

$file.printf("$eg_decay_release_update_interval_table = [\n  ")
(0..((1 << EG_CONTROLLER_STEPS_BITS) - 1)).each do |time|
  t = time
  t = 1 if t == 0
  update_interval = decay_release_update_interval(t)

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
