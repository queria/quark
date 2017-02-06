#!/usr/bin/env python

from arkpy.ark import ArkProfile
from arkpy.ark import ArkTribe
from arkpy.ark import StatMap
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

data_dir = '.'
if len(sys.argv) > 1:
    data_dir = sys.argv[1]
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
    pprint.pprint(tribe.log_index)
    pprint.pprint(tribe.log.value)
