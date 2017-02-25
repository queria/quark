#!/usr/bin/python

# kept here for debugging purposes,
# ark-dump.py contains code without debug

# find first fresh entry missing in old_log # and append everything from it to
# end of fresh log into old_log

# start from newest entry in fresh
# iterate from newest to oldest entry
# if given entry time is newer then last entry in old_log
#  store it's index as 'first_missing'
# if given entry has same time as last entry in old_log
#  if it's exact content is not same
#   store as 'first_missing'
#  if it's exact content is same as last entry in old_log
#   stop iteration
# if given entry has older time than last entry in old_log
#   stop iteration

# known bug is, that if all entries in fresh log
# all older then (happened before) entries in old_log
# it would still append them to the end
# though this cannot happen, not at least how i intend to use this
# [i already do not have older entries than
#  what i will initialize old_log with]

old_log = [  # now unused, loading from file my.log
 'Day 1177, 00:27:47: <RichColor Color="1, 1, 0, 1">Qu dem a \'eiling\'!</>',
 'Day 1177, 00:29:37: <RichColor Color="1, 1, 0, 1">Qu dem a \'eiling\'!</>',
 'Day 1177, 00:31:16: <RichColor Color="1, 1, 0, 1">Qu dem a \'eiling\'!</>',
 'Day 1177, 00:32:51: <RichColor Color="1, 1, 0, 1">Qu dem a \'eiling\'!</>',
 'Day 1191, 18:56:32: <RichColor Color="1, 1, 0, 1">Qu dem a \'mp\'!</>',
 'Day 1191, 19:33:44: <RichColor Color="1, 1, 0, 1">Qu dem a \'all\'!</>',
 'Day 1191, 19:34:58: <RichColor Color="1, 1, 0, 1">Qu dem a \'all\'!</>',
 'Day 1191, 19:36:25: <RichColor Color="1, 1, 0, 1">Qu dem a \'ndow\'!</>',
 'Day 1191, 19:38:50: <RichColor Color="1, 1, 0, 1">Qu dem a \'nce \'!</>',
 'Day 1191, 20:12:09: <RichColor Color="1, 1, 0, 1">Qu dem a \'all\'!</>',
 'Day 1191, 20:17:52: <RichColor Color="1, 1, 0, 1">Qu dem a \'dder\'!</>',
 'Day 1232, 17:23:14: <RichColor Color="1, 1, 0, 1">Qu dem a \'llar\'!</>',
 'Day 1232, 20:52:13: <RichColor Color="1, 1, 0, 1">Qu dem a \'HERE\'!</>',
]
fresh = [
 'Day 1191, 20:12:09: <RichColor Color="1, 1, 0, 1">Qu dem a \'all\'!</>',
 'Day 1191, 20:17:52: <RichColor Color="1, 1, 0, 1">Qu dem a \'dder\'!</>',
 'Day 1232, 17:23:14: <RichColor Color="1, 1, 0, 1">Qu dem a \'llar\'!</>',
 'Day 1232, 20:52:13: <RichColor Color="1, 1, 0, 1">Qu dem a \'HERE\'!</>',
 'Day 1232, 20:52:13: <RichColor Color="1, 1, 0, 1">Qu dem a \'Diff\'!</>',
 'Day 1232, 20:55:02: <RichColor Color="1, 1, 0, 1">Qu dem a \'apdoor\'!</>',
 'Day 1232, 21:34:31: <RichColor Color="1, 1, 0, 1">Qu dem a \'ilin1\'!</>',
 'Day 1232, 22:00:37: <RichColor Color="1, 1, 0, 1">Qu dem a \'ilin2\'!</>',
 'Day 1232, 23:10:45: <RichColor Color="1, 1, 0, 1">Qu dem a \'ilin3\'!</>',
 'Day 1233, 00:32:27: <RichColor Color="1, 1, 0, 1">Qu dem a \'gn\'!</>',
 'Day 1233, 01:26:47: <RichColor Color="1, 1, 0, 1">Qu dem a \'ilin4\'!</>',
 'Day 1233, 01:28:20: <RichColor Color="1, 1, 0, 1">Qu dem a \'lla2\'!</>',
 'Day 1233, 03:04:39: <RichColor Color="1, 1, 0, 1">Qu dem a \'ilin5\'!</>',
]


def entry_time(line):
    split = line.split(',')

    day = int(split[0][4:])
    time = split[1][1:9]

    # 60 * 60 * 24 = 86400
    # 60 * 60      =  3600

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

    print('Last old: %s  ::  %s' % (last_old_time,
                                    last_old_entry))
    print('Last old time: %s' % last_old_time)

    first_missing_idx = -1
    for line_idx, line in enumerate(reversed(fresh_entries)):
        fresh_time = entry_time(line)
        if fresh_time > last_old_time:
            first_missing_idx = line_idx
            print('%s > %s   #%s  %s' %
                  (fresh_time,
                   last_old_time,
                   line_idx,
                   line))
        elif fresh_time == last_old_time:
            if line == last_old_entry:
                print('%s == %s AND line == last_old'
                      % (fresh_time, last_old_time))
                break
            else:
                print('%s == %s AND line != last_old'
                      % (fresh_time, last_old_time))
                first_missing_idx = line_idx
        elif fresh_time < last_old_time:
            print('%s < %s' % (fresh_time, last_old_time))
            break
    # as we iteraded in reverse (from the end), revert index
    first_missing_idx = ((len(fresh_entries) - 1) - first_missing_idx)

    missing = fresh_entries[first_missing_idx:]

    print('First missing: #%s  ::  %s'
          % (first_missing_idx,
             missing[0:1]))
    # now append all from that index to the end

    with open(log_filename, 'a') as log:
        log.writelines([x + '\n' for x in missing])
# end


# fresh = old_log  # for testing behaviour of 'append missing'
join_log('my.log', fresh)
