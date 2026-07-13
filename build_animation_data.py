"""Generates per-patient event-timeline JSON files for the browser animation view.

Runs each scenario for a short horizon (default 16 simulated hours) so the
resulting JSON stays small and the animation stays readable (not thousands of
overlapping dots), then writes output/anim_<scenario>.json.
"""

from pathlib import Path

from hospital_sim.animation_export import write_animation_json
from hospital_sim.hospital import run_simulation
from hospital_sim.scenarios import ALL_SCENARIOS

OUTPUT_DIR = Path(__file__).parent / "output"
HORIZON_HOURS = 16.0
TEMPLATE_SOURCE = Path(__file__).parent / "hospital_sim" / "output" / "animation.html"


def write_animation_page(out_dir: Path) -> Path | None:
    if not TEMPLATE_SOURCE.exists():
        return None

    out_dir.mkdir(parents=True, exist_ok=True)
    path = out_dir / "animation.html"
    path.write_text(TEMPLATE_SOURCE.read_text(encoding="utf-8"), encoding="utf-8")
    return path


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

    page_path = write_animation_page(OUTPUT_DIR)
    if page_path is not None:
        print(f"Animation page written to {page_path}")


if __name__ == "__main__":
    main()
