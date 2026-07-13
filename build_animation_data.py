"""Generates per-patient event-timeline JSON files for the browser animation view.

Runs each scenario for a short horizon (default 16 simulated hours) so the
resulting JSON stays small and the animation stays readable (not thousands of
overlapping dots), then writes hospital_sim/output/anim_<scenario>.json.
"""

from pathlib import Path

from hospital_sim.animation_export import write_animation_json
from hospital_sim.hospital import run_simulation
from hospital_sim.scenarios import ALL_SCENARIOS

OUTPUT_DIR = Path(__file__).parent / "hospital_sim" / "output"
HORIZON_HOURS = 16.0


def main():
    for name, factory in ALL_SCENARIOS.items():
        cfg = factory()
        cfg.sim_time_hours = HORIZON_HOURS
        cfg.warmup_hours = 0  # keep every patient for animation purposes

        print(f"Simulating {name} for animation ({HORIZON_HOURS}h)...")
        stats = run_simulation(cfg)
        path = write_animation_json(stats, OUTPUT_DIR, name, max_hours=HORIZON_HOURS)
        n = len(stats.all_patients)
        print(f"  -> {n} patients, written to {path.name}")


if __name__ == "__main__":
    main()
