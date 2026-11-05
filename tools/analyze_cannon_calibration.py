"""Summarize cannon accuracy from shot, projectile-end and boss-HP telemetry."""
import argparse
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("log", type=Path)
parser.add_argument("--last", type=int, default=20)
args = parser.parse_args()
records = []
for line in args.log.read_text().splitlines():
    try:
        records.append(json.loads(line))
    except (ValueError, TypeError):
        pass
shots = [r for r in records if r.get("kind") == "shot"][-args.last:]
counts = {"hit": 0, "miss": 0, "pending": 0, "not_fired": 0}
for shot in shots:
    following = [r for r in records if r.get("id") == shot["id"] and 0 <= r["clock"] - shot["clock"] <= 8]
    launched = any(r.get("kind") == "flight" or (r.get("kind") == "shot_acceptance" and r.get("accepted")) for r in following)
    ends = [r for r in following if r.get("kind") == "projectile_end"]
    damage = []
    if ends:
        end = ends[0]["clock"]
        damage = [r["delta"] for r in records if r.get("kind") == "hp" and r.get("job") == shot["job"] and abs(r["clock"] - end) < 0.4 and r["delta"] > 100000]
    result = "not_fired" if not launched else ("hit" if damage else ("miss" if ends else "pending"))
    counts[result] += 1
    print(f"{shot['time']} {result:9s} range={shot['range']:6.0f} pitch={shot['pitch']:6.2f} part={shot.get('aimPart', '-'):12s} damage={max(damage, default=0):.0f} id={shot['id']}")
print(counts)
