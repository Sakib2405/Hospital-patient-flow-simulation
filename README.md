# Hospital Patient Flow Simulation

A data-driven discrete-event simulation (DES) of hospital patient flow, built with
[SimPy](https://simpy.readthedocs.io/). It models patients moving through
registration → triage → ER/OPD treatment → diagnostics → ward/ICU admission →
discharge, with priority-based handling for emergency, urgent, and regular patients.

## Why these distributions

- **Arrivals**: Poisson process per patient category (exponential interarrival times) —
  the standard model for independent, random patient arrivals.
- **Quick administrative/service steps** (registration, triage, diagnostics, discharge):
  exponential service times — memoryless, matches highly variable short tasks.
- **Treatment/stay durations** (ER treatment, OPD consult, ward stay): normal
  distribution (clipped at a floor) — these cluster around a typical duration rather
  than being memoryless.

## Project layout

```
hospital_sim/
  config.py      # all tunable parameters (staff, capacity, rates, service times)
  patient.py      # Patient entity + priority category
  hospital.py     # SimPy resources + patient journey process
  stats.py        # per-patient and resource-utilization data collection
  report.py       # charts + markdown statistical report + scenario comparison
  scenarios.py    # normal / peak / pandemic scenario configs
  output/         # generated reports and charts (created on run)
main.py           # CLI entry point
```

## Setup

```bash
python -m venv .venv
./.venv/Scripts/python -m pip install -r requirements.txt   # Windows
# source .venv/bin/activate && pip install -r requirements.txt  # macOS/Linux
```

## Running

```bash
# Run all three scenarios (normal, peak, pandemic) and generate a comparison
python main.py

# Run a single scenario
python main.py --scenario pandemic

# Override simulated duration (hours) and random seed
python main.py --scenario normal --hours 336 --seed 7
```

Outputs are written to `hospital_sim/output/`:

- `<scenario>_report.md` — average/95th-percentile wait, admission & ICU rates,
  throughput, per-category waits, resource utilization, queue lengths, and the
  identified bottleneck (highest-utilization resource).
- `<scenario>_wait_distribution.png` — histogram of wait-before-treatment times.
- `<scenario>_wait_by_category.png` — boxplot comparing Emergency/Urgent/Regular waits.
- `<scenario>_utilization.png` — bar chart of average utilization per resource.
- `<scenario>_queue_over_time.png` — queue length time series per resource.
- `scenario_comparison.csv` / `scenario_comparison.png` — side-by-side comparison
  across scenarios (only generated when more than one scenario is run).

## Configuring your own scenario

Edit `hospital_sim/config.py` defaults, or build a `SimulationConfig` directly:

```python
from hospital_sim.config import SimulationConfig
from hospital_sim.hospital import run_simulation
from hospital_sim.report import write_report

cfg = SimulationConfig(name="my_scenario")
cfg.staff.er_doctors = 6
cfg.capacity.icu_beds = 10
cfg.arrivals.emergency_rate = 2.0

stats = run_simulation(cfg)
write_report(stats, out_dir=Path("hospital_sim/output"), scenario_name=cfg.name)
```

The first `cfg.warmup_hours` of simulated time are excluded from KPI calculations
so that empty-system startup effects don't skew the statistics.

## Using a real arrival dataset

By default, arrival rates are constant per category (`ArrivalConfig.emergency_rate`
etc.). To use a real hospital's historical arrival pattern instead, set
`cfg.arrivals.hourly_rates_csv` to a CSV path with columns:

```
hour,emergency_rate,urgent_rate,regular_rate
0,0.6,1.0,1.0
1,0.5,0.8,0.6
...
23,0.7,1.1,1.0
```

`hour` is 0-23 (hour of day); each `*_rate` is the mean number of arrivals per hour
for that category, for that hour. Derive these from real admission logs (group by
hour-of-day, average patients/hour per category) or from a public ER dataset. A
sample file with a typical daytime-peak pattern is included at
`hospital_sim/data/hourly_arrival_rates.csv` — replace its values with real data
when available.

```python
cfg = SimulationConfig(name="real_data")
cfg.arrivals.hourly_rates_csv = "hospital_sim/data/hourly_arrival_rates.csv"
stats = run_simulation(cfg)
```

The simulation then uses a non-homogeneous Poisson process: arrivals are still
random within each hour, but the average rate follows the hour-of-day pattern from
the CSV (e.g. a real evening ER surge), instead of being flat all day.

## Scenarios included

- **normal** — baseline arrival rates and staffing.
- **peak** — arrival rates raised ~2x to model sustained peak-hour load.
- **pandemic** — emergency/urgent surge, reduced non-urgent visits, reduced
  available staff (illness), and higher admission/ICU probabilities.

## Notes / extending further

- Priority queuing uses `simpy.PriorityResource` for the ER and ward/ICU beds so
  Emergency patients are served ahead of Urgent, ahead of Regular, when queued.
- To add a real dataset, replace the `ArrivalConfig` rates with time-varying rates
  (e.g. an hourly rate table) and drive `arrivals_process` from it instead of a
  constant Poisson rate.
- A live dashboard, ML-based arrival prediction, and a database-backed backend
  are natural next steps but are out of scope for this version — the code is
  structured (config/model/stats/report separated) to make adding them straightforward.
