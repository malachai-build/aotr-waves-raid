# AoTR Waves and Raid farm

The current Waves and Raid source for Attack on Titan Revolution and the Matcha executor is [`autofarmraids.lua`](autofarmraids.lua).

## Autoexec

Save this single line as `C:\matcha\autoexec\aotr_waves_raid.lua`:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/malachai-build/aotr-waves-raid/refs/heads/main/autoexec.lua"))()
```

The entrypoint skips the normal mission and lobby, creates the Matcha `aotr` workspace folder, downloads the pinned source, and spawns it immediately. It has no top-level wait; Matcha needs the source spawned before the autoexec caller yields.

This source includes Waves crate delivery, Market and upgrade stations, perk management, raid chests, QTE handling, and raid boss targeting. It is the same code currently staged at `C:\matcha\workspace\aotr\autofarm_branch.lua` and `C:\matcha\autoexec\autofarmraids.lua` (verified by SHA-256 on 2026-11-05).

The normal mission source is maintained separately in [aotr-farm](https://github.com/malachai-build/aotr-farm). The older combined repository history was preserved before the split.

Based on Kitty's AoTR script v1.0.7 (@roguekitty).
