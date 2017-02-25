#!/usr/bin/env python

from arkpy.ark import ArkProfile
from arkpy.ark import ArkTribe
from arkpy.ark import StatMap
import datetime
import os
import pprint  # noqa
import sys

stats_base = {
    StatMap.Health: 100,
    StatMap.Stamina: 100,
    StatMap.Oxygen: 100,
    StatMap.Food: 100,
    StatMap.Water: 100,
    StatMap.Weight: 100,
    StatMap.Melee_Damage: 100,
    StatMap.Movement_Speed: 100,
    StatMap.Fortitude: 0,
    StatMap.Crafting_Speed: 100
}
stats_inc = {
    StatMap.Health: 10,
    StatMap.Stamina: 10,
    StatMap.Oxygen: 20,
    StatMap.Food: 10,
    StatMap.Water: 10,
    StatMap.Weight: 10,
    StatMap.Melee_Damage: 5,
    StatMap.Movement_Speed: 2,
    StatMap.Fortitude: 2,
    StatMap.Crafting_Speed: 1
}


# log processing, with debug info in ark-log-merge.py
def entry_time(line):
    split = line.split(',')

    day = int(split[0][4:])
    time = split[1][1:9]

    return (86400 * day +
            3600 * int(time[0:2]) +
            60 * int(time[3:5]) +
            int(time[6:8]))


def join_log(log_filename, fresh_entries, old_log=[]):

    if not old_log:
        try:
            with open(log_filename) as log:
                old_log = [x.strip() for x in log.readlines()]
        except IOError as exc:
            print('Cannot read from persistent tribe log %s: %s'
                  % (log_filename, exc))
            pass  # assume it's not existing file ...

    last_old_entry = old_log[-1] if old_log else ''
    last_old_time = entry_time(last_old_entry) if last_old_entry else 0

    first_missing_idx = -1
    for line_idx, line in enumerate(reversed(fresh_entries)):

        fresh_time = entry_time(line)

        if fresh_time > last_old_time:
            first_missing_idx = line_idx

        elif fresh_time == last_old_time:
            if line == last_old_entry:
                break
            else:
                first_missing_idx = line_idx

        elif fresh_time < last_old_time:
            break

    # as we iteraded in reverse (from the end), revert index
    first_missing_idx = ((len(fresh_entries) - 1) - first_missing_idx)

    missing = fresh_entries[first_missing_idx:]

    with open(log_filename, 'a') as log:
        log.writelines([x + '\n' for x in missing])

    return old_log + missing


def main(data_dir):
    print('ArkDump: reading dir %s' % data_dir)
    os.chdir(data_dir)

    for localfile in os.listdir(data_dir):
        if not localfile.endswith('.arkprofile'):
            continue
        profile = ArkProfile(localfile)
        char = profile.character

        print('==[ %s lvl %s ]==' % (char.name.value, (char.level_ups.value + 1)))
        print(' played by %s ' % (profile.player_name.value))
        print('%s engram points, %s experience' % (char.engram_points.value,
                                                   char.experience.value))

        # Get all the Stat points allocated and print them with a string
        # identifying which stat they are
        stats = profile.character.stat_points
        for stat in StatMap:
            print('  +%2d = %3d  %s ' % (
                stats[stat].value,
                stats_base[stat] + (stats_inc[stat] * stats[stat].value),
                stat.name.lower()))

        print('')

    for localfile in os.listdir('.'):
        if not localfile.endswith('.arktribe'):
            continue
        tribe = ArkTribe(localfile)
        # with open('tribe_%s.log' % tribe.tribe_id.value) as log:

        print('%s / %s Tribe Log:' % (tribe.name.value, tribe.tribe_id.value))
        fresh_log = [x.value for x in tribe.log.value]

        # comment next line if you don't want to store permanent tribe logs
        full_log = join_log('tribe_%s.log' % tribe.tribe_id.value, fresh_log)

        for log_entry in reversed(full_log):
            print(' %s' % log_entry)

    print('ArkDump: generated at %s UTC'
          % (datetime.datetime.utcnow().isoformat()))


if __name__ == '__main__':
    data_dir = '.'
    if len(sys.argv) > 1:
        data_dir = sys.argv[1]
    main(data_dir)
