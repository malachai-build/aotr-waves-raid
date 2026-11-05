# AoTR Waves and Raid farm

The current Waves and Raid source for Attack on Titan Revolution and the Matcha executor is [`autofarmraids.lua`](autofarmraids.lua).

## Autoexec

Save this single line as `C:\matcha\autoexec\aotr_waves_raid.lua`:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/malachai-build/aotr-waves-raid/refs/heads/main/autoexec.lua"))()
```

The entrypoint skips the normal mission and lobby, creates the Matcha `aotr` workspace folder, downloads the pinned source, and spawns it immediately. It has no top-level wait; Matcha needs the source spawned before the autoexec caller yields.

Keep only one active AoTR autoexec entrypoint for Waves and Raids. In particular, replace an existing full `autofarmraids.lua` autoexec copy with this line instead of adding it alongside that copy.

This source includes Waves crate delivery, Market and upgrade stations, perk management, raid chests, QTE handling, and raid boss targeting. The farm creates its `aotr` folder through Matcha's file API before writing logs or heartbeat files, including direct mission startup.

The normal mission source is maintained separately in [aotr-farm](https://github.com/malachai-build/aotr-farm). The older combined repository history was preserved before the split.

For automatic recovery, use the [two-file watchdog setup](https://github.com/malachai-build/aotr-farm#watchdog-setup). Open Matcha, save this loadstring in autoexec, run it once in the current session if needed, then start the watchdog. The farm writes `aotr/heartbeat.txt` relative to Matcha's actual workspace; users do not create folders or configure paths. The watchdog does not install scripts into autoexec.

Based on Kitty's AoTR script v1.0.7 (@roguekitty).

## Colossal raid (local development)

The cannon/Eren-defense controller is active again; the colossal sword experiment has been removed. Sword attacks and nape pulls target normal titans, prioritizing attackers near Eren. The controller tracks cannon cooldown, prepares early for the next shot, and yields to imminent Eren danger. Aim uses the measured 500-stud/sec shell speed and 210-stud/sec-squared downward acceleration, selecting an intersecting arc through the titan body. It stays mounted through impact when Eren is safe. Full raid completion remains unverified.

Raid skills 1-5 retain their immediate readiness checks and independent input debounces. Visible cooldowns and awakening charge are respected, without a global confirmation delay. Perk menus remain deferred during this raid.

Compile in Matcha, then run `tests/colossal_controller_test.lua` with the source staged at `aotr/autofarm_branch.lua`. Local autoexec reads `C:\matcha\workspace\aotr\autofarm_branch.lua`. The original remote loader is backed up at `C:\matcha\workspace\aotr\waves_raid_loader_before_colossal.lua`; the remote autoexec pin has not changed.

Cannon calibration telemetry is written as JSON lines in `C:\matcha\workspace\aotr\cannon_calibration.txt` (Matcha disallows `.jsonl`). Shot records, actual projectile trajectories, impact times, and boss HP changes are recorded separately. `tools/analyze_cannon_calibration.py <log>` reports HP-confirmed hits, misses, rejected fire inputs, and unresolved shots; background 82,500-point ticks do not count as cannon hits.

Final aim validation: 8/8 HP-confirmed shells in the retained validation cohort, including a complete final pass with 5/5 damaging shots. See [`calibration/cannon_validation.csv`](calibration/cannon_validation.csv) and [`calibration/README.md`](calibration/README.md) for distances, damage, and measurement rules.
