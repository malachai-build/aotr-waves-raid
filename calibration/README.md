# Cannon aim validation

Recorded on 2026-11-05. Final trajectory setup: 8 HP-confirmed hits from 8 launched shells after restoration of the validated setup. The last full raid pass produced 5 shells, all 5 damaging the colossal. Tested distances: 193.64-1,251.87 studs (see CSV for exact recorded values).

A hit requires an actual cannon projectile and a boss HP drop greater than 100,000 within 0.4 seconds of that projectile disappearing. The recurring 82,500-point background HP ticks are excluded. Fire inputs that did not create a projectile are logged separately and excluded from shell accuracy; all five fire inputs in the last pass created shells.

The measured projectile launch speed is 500 studs/second, with a fitted downward acceleration of approximately 210 studs/second squared. The active planner tests arcs against the titan body rather than scaling the starting pitch linearly by distance. Small key pulses refine aim; no shot is expended when the model predicts no safe intersection. The cannon remains occupied through impact unless Eren's emergency protection interrupts it.

`cannon_validation.csv` contains the individual final-cohort observations. Raw telemetry is at `C:\matcha\workspace\aotr\cannon_calibration.txt`. Run `python tools/analyze_cannon_calibration.py <log>` to inspect HP-confirmed outcomes, misses, rejected fire inputs, and unresolved projectiles. This validates the observed firing distances; it does not establish a full raid clear.
