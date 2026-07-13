import argparse
import os
import webbrowser
import threading
import http.server
import socketserver
from pathlib import Path

from hospital_sim.animation_export import write_animation_json
from hospital_sim.hospital import run_simulation
from hospital_sim.report import write_report, write_scenario_comparison
from hospital_sim.scenarios import ALL_SCENARIOS

OUTPUT_DIR = Path(__file__).parent / "output"
PORT = 8000
ANIMATION_HORIZON_HOURS = 16.0


def _start_server(directory: Path, port: int) -> socketserver.TCPServer:
    os.chdir(str(directory))

    class Handler(http.server.SimpleHTTPRequestHandler):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=str(directory), **kwargs)

        def log_message(self, format, *args):
            pass  # suppress default request logs

    server = socketserver.TCPServer(("", port), Handler)

    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    return server


def _open_browser(port: int, path: str = ""):
    url = f"http://localhost:{port}/{path}"
    try:
        webbrowser.open(url)
    except Exception:
        pass
    return url


def main():
    parser = argparse.ArgumentParser(description="Hospital patient flow simulation")
    parser.add_argument("--scenario", choices=list(ALL_SCENARIOS) + ["all"], default="all")
    parser.add_argument("--hours", type=float, default=None, help="Override simulated hours")
    parser.add_argument("--seed", type=int, default=None, help="Override random seed")
    parser.add_argument("--no-server", action="store_true", help="Do not start web server")
    args = parser.parse_args()

    scenario_names = list(ALL_SCENARIOS) if args.scenario == "all" else [args.scenario]

    summaries = {}
    for name in scenario_names:
        cfg = ALL_SCENARIOS[name]()
        if args.hours is not None:
            cfg.sim_time_hours = args.hours
        if args.seed is not None:
            cfg.random_seed = args.seed

        print(f"Running scenario: {name} ({cfg.sim_time_hours}h simulated)...")
        stats = run_simulation(cfg)
        summary = write_report(stats, OUTPUT_DIR, name)
        write_animation_json(stats, OUTPUT_DIR, name, max_hours=ANIMATION_HORIZON_HOURS)
        summaries[name] = summary
        print(f"  -> {summary['n_patients']} patients processed, "
              f"avg wait {summary.get('avg_wait_before_treatment_min', 0):.1f} min, "
              f"bottleneck: {summary.get('bottleneck')}")

    if len(summaries) > 1:
        write_scenario_comparison(summaries, OUTPUT_DIR)
        print(f"\nScenario comparison written to {OUTPUT_DIR / 'scenario_comparison.csv'}")

    print(f"\nAll outputs written to: {OUTPUT_DIR}")

    # Build dashboard
    try:
        from build_dashboard import build
        build()
    except ImportError:
        print("Note: build_dashboard.py not found, skipping dashboard build")

    try:
        from build_animation_data import write_animation_page
        page_path = write_animation_page(OUTPUT_DIR)
        if page_path is not None:
            print(f"Animation page written to: {page_path}")
    except ImportError:
        print("Note: build_animation_data.py not found, skipping animation page copy")

    # Start web server and open browser
    if not args.no_server:
        _start_server(OUTPUT_DIR, PORT)
        url = _open_browser(PORT, "animation.html")
        print(f"\n{'='*55}")
        print(f"  Web server started at: http://localhost:{PORT}")
        print(f"  Open in browser: {url}")
        print(f"  {url}")
        print(f"  Press Ctrl+C to stop the server")
        print(f"{'='*55}")
        try:
            input("\nPress Enter to stop the server...")
        except KeyboardInterrupt:
            pass


if __name__ == "__main__":
    main()
