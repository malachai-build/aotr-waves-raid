# AoTR Waves and Raid farm

The current Waves and Raid source for Attack on Titan Revolution and the Matcha executor is [`autofarmraids.lua`](autofarmraids.lua).

## Autoexec

Save this single line as `C:\matcha\autoexec\aotr_waves_raid.lua`:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/malachai-build/aotr-waves-raid/refs/heads/main/autoexec.lua"))()
```

The entrypoint supports every AoTR mission map, checks the game ID, skips the main menu, lobby and trade hub, creates the Matcha `aotr` workspace folder, downloads the pinned source, and spawns it immediately. It has no top-level wait; Matcha needs the source spawned before the autoexec caller yields. Maps do not choose the script's feature set, and new mission maps need no loader update.

Keep only one active AoTR autoexec entrypoint: choose this version for its additional features or the normal farm for its simpler, more stable titan-killing feature set. Do not enable both loadstrings together. Replace an existing full `autofarmraids.lua` autoexec copy with this line instead of adding it alongside that copy.

This source includes Waves crate delivery, Market and upgrade stations, perk management, raid chests, QTE handling, and raid boss targeting. The farm creates its `aotr` folder through Matcha's file API before writing logs or heartbeat files, including direct mission startup.

The normal mission source is maintained separately in [aotr-farm](https://github.com/malachai-build/aotr-farm). The older combined repository history was preserved before the split.

For automatic recovery, use the [two-file watchdog setup](https://github.com/malachai-build/aotr-farm#watchdog-setup). Open Matcha, save this loadstring in autoexec, run it once in the current session if needed, then start the watchdog. The farm writes `aotr/heartbeat.txt` relative to Matcha's actual workspace; users do not create folders or configure paths. The watchdog does not install scripts into autoexec.

Based on Kitty's AoTR script v1.0.7 (@roguekitty).

## HUD reloads, human skills, and menu placement

Blade reloads use the HUD fill gradient rather than blade transparency. Gradient X from -0.15 through 0 requests a reload; combat waits for full durability before resuming. The no-target safety hover is preserved. Empty spare sets (`0/3`), empty gas, or persistently unreadable HUD data request a bounded refill. Failed attempts resume farming and retry after 20 seconds. Counter readers accept unnamed labels and rich text, and startup/reload settling prevents transition frames from requesting a refill.

The gradient layout is verified for Roblox `version-f0ea5da9412f4e35`; other versions use the unreadable-HUD fallback until verified. `tests/hud_reload_test.lua` covers both sources staged at `aotr/reload_tests/normal.lua` and `raid.lua`.

Both farms use human skills after nape pulling and before slashing. Main / Human Skills includes **Use Awakening**, off by default, and the awakening slot selector. When disabled, the selected slot is skipped while other human skills remain enabled; turning it off also cancels pending awakening retries. The toggle is saved and applies to Colossal's immediate skill routine too. Automated titan transformation is disabled; the normal farm retains the former implementation and controls in comments.

Menu placement waits for a valid camera viewport before centering and preserves subsequent dragging. Recovery completion clears its status label; the normal human-skill health helper is declared before its callers so combat can continue after recovery. Regression fixtures include `tests/human_skills_test.lua`, `tests/menu_centering_test.lua`, `tests/character_recovery_test.lua`, and `tests/grab_escape_test.lua`.

## Colossal raid (local development)

The cannon/Eren-defense controller is active again; the colossal sword experiment has been removed. Sword attacks and nape pulls target normal titans, prioritizing attackers near Eren. The controller tracks cannon cooldown, prepares early for the next shot, and yields to imminent Eren danger. Aim uses the measured 500-stud/sec shell speed and 210-stud/sec-squared downward acceleration, selecting an intersecting arc through the titan body. It stays mounted through impact when Eren is safe. Full raid completion remains unverified.

Raid skills 1-5 retain their immediate readiness checks and independent input debounces. Visible cooldowns and awakening charge are respected, without a global confirmation delay. Perk menus remain deferred during this raid.

Compile in Matcha, then run `tests/colossal_controller_test.lua` with the source staged at `aotr/autofarm_branch.lua`. Local autoexec reads `C:\matcha\workspace\aotr\autofarm_branch.lua`. The original remote loader is backed up at `C:\matcha\workspace\aotr\waves_raid_loader_before_colossal.lua`; the remote autoexec pin has not changed.

Cannon calibration telemetry is written as JSON lines in `C:\matcha\workspace\aotr\cannon_calibration.txt` (Matcha disallows `.jsonl`). Shot records, actual projectile trajectories, impact times, and boss HP changes are recorded separately. `tools/analyze_cannon_calibration.py <log>` reports HP-confirmed hits, misses, rejected fire inputs, and unresolved shots; background 82,500-point ticks do not count as cannon hits.

Final aim validation: 8/8 HP-confirmed shells in the retained validation cohort, including a complete final pass with 5/5 damaging shots. See [`calibration/cannon_validation.csv`](calibration/cannon_validation.csv) and [`calibration/README.md`](calibration/README.md) for distances, damage, and measurement rules.

## Grab and ragdoll recovery

**Auto QTE / Grab Escape** uses the displayed prompt key for timed QTEs and button-only escape prompts. It releases held keys if disabled and sends no new escape input while Roblox is unfocused. The saved AutoQTE preference is preserved; enable the toggle to use automatic escape.

Character checks run at startup, after HP loss, and during combat. Ragdoll detection reads the actual native Humanoid state using the current client offsets; a persistent character Ragdoll attribute alone never blocks combat. A ragdoll, missing human body parts, or active escape prompt pauses targeting and hover. Damage clears cached character parts. After the game restores an intact character and clears the ragdoll, combat resumes after a short stability check. The script does not force game-owned ragdoll attributes or recreate destroyed body parts.

The farm writes a single `recovering` heartbeat per interrupted episode. The updated watchdog allows 20 seconds for native recovery, then uses its existing Matcha-restart/Retry sequence. Manual Unload still disables recovery. A new server/respawn may still be required if the game's character controller cannot recover.

Regression fixtures: `tests/character_recovery_test.lua` (both sources staged at `aotr/recovery_tests/normal.lua` and `raid.lua`).
