#set document(title: "Hospital Patient Flow Simulation - Project Report", author: "Nazmus Sakib")
#set page(paper: "a4", margin: (x: 2.2cm, y: 2.2cm), numbering: "1")
#set text(font: "Calibri", size: 11pt, lang: "en")
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1")

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(0.4em)
  text(size: 17pt, weight: "bold")[#it]
  v(0.2em)
  line(length: 100%, stroke: 1pt + black)
  v(0.4em)
}
#show heading.where(level: 2): it => {
  v(0.5em)
  text(size: 13pt, weight: "bold")[#it]
  v(0.3em)
}

// ---------------- Title page ----------------
#page(numbering: none)[
  #v(0.5em)
  #box(
    width: 56pt, height: 56pt, radius: 50%,
    fill: rgb("#0f7a72"), stroke: 1pt + black,
  )[
    #align(center + horizon)[#text(fill: white, weight: "bold", size: 14pt)[PSTU]]
  ]

  #v(0.3em)
  #text(size: 15pt, weight: "bold")[Patuakhali Science and Technology University] \
  #text(size: 11pt)[Faculty of Computer Science and Engineering]

  #line(length: 100%, stroke: 0.6pt + black)

  #v(0.4em)
  #text(size: 14pt, weight: "bold")[CIT 324 :: Simulation and Modeling Sessional]

  #text(size: 11pt)[Project Report]

  #line(length: 100%, stroke: 0.6pt + black)

  #v(3em)
  #align(center)[
    #box(
      width: 90pt, height: 90pt, radius: 12pt,
      fill: rgb("#0f7a72"),
    )[
      #align(center + horizon)[
        #text(fill: white, size: 26pt)[⊕]
      ]
    ]

    #v(0.6em)
    #text(size: 26pt, weight: "bold")[HospiFlow]

    #text(size: 15pt, fill: rgb("#0f7a72"))[S I M]
  ]

  #v(2em)
  #text(weight: "bold")[Project Title :] Hospital Patient Flow Simulation (HospiFlow Sim) \
  Submission Date : 11 July 2026

  #line(length: 100%, stroke: 0.6pt + black)

  #v(0.5em)
  #table(
    columns: (1fr, 1.4fr),
    stroke: 0.6pt + black,
    inset: 9pt,
    [*Submitted from,*], [*Submitted to,*],
    [
      Nazmus Sakib \
      *ID* : 2102066, \
      *Reg* : 10193, \
      *Semester* : 6 \
      (Level-3, Semester-2)
    ],
    [
      1. *Md Mahbubur Rahman* \
      Associate Professor, \
      Department of Computer Science and Information Technology, \
      Patuakhali Science and Technology University. \
      2. *Dr. Md Abdul Masud* \
      Professor, \
      Department of Computer Science and Information Technology, \
      Patuakhali Science and Technology University.
    ],
  )
]

// ---------------- Table of contents ----------------
#page(numbering: none)[
  #text(size: 20pt, weight: "bold")[Contents]
  #v(0.5em)
  #outline(title: none, indent: auto)
]

#counter(page).update(1)

// ================= 1. Introduction =================
= Introduction

#align(center)[
  #box(width: 70pt, height: 70pt, radius: 10pt, fill: rgb("#0f7a72"))[
    #align(center + horizon)[#text(fill: white, size: 22pt)[⊕]]
  ]

  #text(size: 20pt, weight: "bold")[HospiFlow Sim]

  #text(style: "italic")[A Data-Driven Discrete-Event Simulation of Hospital Patient Flow]
]

HospiFlow Sim is a discrete-event simulation (DES) of hospital operations, built to help
answer a question every hospital administrator faces but rarely can test safely: *what
happens to patient waiting times and resource utilization if staffing, bed count, or
patient demand changes?* The system models the complete patient journey — registration,
triage, emergency/outpatient treatment, diagnostics, ward or ICU admission, and discharge
— through a network of shared, capacity-limited resources (doctors, nurses, beds), with
priority-based queueing across Emergency, Urgent, and Regular patient categories.

Rather than relying on fixed, deterministic timings, the simulation draws arrivals and
service durations from probability distributions chosen to match the real variability of
each process (Poisson arrivals, exponential service times, normal treatment durations).
This lets the same model be re-run under different operating conditions — a normal day, a
peak-hour surge, a pandemic-driven crisis, or a schedule derived from a real, downloaded
patient dataset — and produce comparable, statistically grounded results, entirely on a
local machine with no hospital system integration required.

= Objectives

+ To build a modular discrete-event simulation of the full patient journey through a
  hospital, from registration to discharge, using SimPy.
+ To model patient arrivals, service times, and treatment durations using statistically
  appropriate probability distributions (Poisson process, exponential, normal) rather than
  fixed constants.
+ To implement category-based priority queueing (Emergency, Urgent, Regular) for shared
  resources such as the Emergency Room and ward/ICU beds.
+ To make every operational parameter — staff counts, bed capacity, arrival rates, service
  times — independently configurable, so that different scenarios can be compared on equal
  footing.
+ To automatically generate statistical reports and charts (wait-time distributions,
  resource utilization, queue length over time) and identify the system's bottleneck.
+ To integrate a real, downloaded patient dataset as an alternative input source, and to
  validate simulation assumptions against it.
+ To present results in an accessible, interactive, locally hosted web dashboard.

= Problem Statement

Hospital administrators must continually decide where to invest limited resources — an
extra doctor, another ward bed, a second diagnostic technician — under uncertain and
variable patient demand. Testing such changes directly on a live hospital is expensive,
slow, and risky: a poorly chosen staffing change can measurably harm patient outcomes
before it is reversed. At the same time, purely analytical queueing formulas (e.g. M/M/c
models) struggle to capture the full complexity of a real patient journey, which involves
multiple sequential departments, category-dependent priority, and probabilistic branching
(not every patient needs diagnostics; not every patient is admitted).

Existing options are each incomplete. Spreadsheet-based capacity planning uses average
values and cannot represent queueing variability or bottleneck formation. Generic
flowcharting tools (draw.io, Lucidchart, Visio) document a process visually but simulate
nothing. Commercial discrete-event simulation packages (Arena, FlexSim Healthcare, Simul8)
can model this problem well but are proprietary, expensive, and closed-source, which makes
them unsuitable for a student project or a small clinic wanting to experiment freely. There
is a need for an open, transparent, and freely extensible simulation that a student,
researcher, or small hospital administrator can run locally, inspect fully, and adapt to
their own data.

= Literature Review

Discrete-event simulation of healthcare systems has a substantial academic foundation.
Kleinrock [1] formalizes queueing theory, showing that mean waiting time rises
sharply and non-linearly as a resource's utilization approaches 100% — the same effect
observed in this project's Peak Hours and Pandemic scenarios, where ER and ward utilization
saturate and average wait times increase by more than an order of magnitude. Little's Law
[2] — that the mean number of entities in a system equals the arrival rate multiplied
by the mean time spent in the system — underlies the intuition that throughput and
queue length cannot both be controlled independently once a resource is at capacity, which
is directly visible in the simulation's queue-length-over-time charts.

Jacobson, Hall, and Swisher [3] survey the specific application of discrete-event
simulation to healthcare systems, documenting how patient flow through registration,
triage, treatment, and discharge is naturally represented as a network of queues and
servers — the same structure this project implements in SimPy. Fone et al. [4]
conducted a systematic review of simulation modelling in public health and found DES to be
one of the most common and effective techniques for evaluating "what-if" policy and
resourcing questions before real-world implementation, directly motivating this project's
scenario-comparison approach (Normal vs. Peak vs. Pandemic vs. Real-Data-driven).

= Related Commercial Projects

+ *Arena (Rockwell Automation)* [5] is an industry-standard discrete-event simulation
  package widely used for healthcare capacity planning, but it is proprietary, licensed
  per-seat, and not accessible for open student experimentation.
+ *FlexSim Healthcare* [6] is a purpose-built healthcare simulation product with 3D
  visualization of patient flow, but like Arena it is commercial, closed-source, and
  requires a paid license.
+ *Simul8* [7] offers general-purpose process simulation used in healthcare consulting,
  again as a closed, licensed desktop application.
+ *SimPy* [8] is the open-source Python discrete-event simulation library this project
  is built on. It is not a hospital-specific product but the enabling engine — comparable
  to how React Flow enables a node editor — on which HospiFlow Sim's patient-journey
  processes, resources, and priority queues are implemented.

Compared to the commercial tools, HospiFlow Sim trades 3D visualization and industrial
support for being free, open, fully inspectable, and easy to extend with new departments,
distributions, or real datasets — appropriate for an educational and small-scale planning
context rather than enterprise deployment.

= Scope

HospiFlow Sim is delivered as a Python package (`hospital_sim`) built on SimPy, NumPy,
Pandas, and Matplotlib, together with a static HTML/CSS/JavaScript dashboard for reviewing
results. It runs entirely locally: there is no server-side application, no database, and no
patient data is transmitted anywhere. The simulation ships with four ready-to-run
scenarios (Normal, Peak Hours, Pandemic, and a Real-Dataset-driven scenario), a scenario
comparison report, and per-scenario statistical reports and charts, generated automatically
into an output folder. All operational parameters — staffing levels, bed/ICU capacity,
arrival rates, service-time distributions, admission probabilities — are defined in a
single, human-readable configuration module and can be freely edited or extended with new
scenarios without touching the simulation engine itself.

== Job Market Relevance

The skills exercised by this project — discrete-event simulation, probabilistic modelling,
data engineering (real-dataset ingestion and cleaning), statistical reporting, and
dashboard visualization — map closely onto in-demand roles in both software engineering and
data/operations analytics. Simulation and operations-research skills (SimPy, queueing
theory, Monte Carlo / DES modelling) are frequently listed for supply-chain, healthcare
analytics, and industrial-engineering positions, while the Python data stack used here
(NumPy, Pandas, Matplotlib) is foundational to nearly all data-analyst and data-science job
postings in Bangladesh and internationally. Building a complete, real-data-validated
simulation end to end is a demonstrable portfolio artifact for both software engineering
and analytics-oriented roles.

= Methodology

== Technology Stack

Development followed an iterative approach: the core simulation engine was built and
verified first, followed by statistical reporting, then scenario configuration, then the
dashboard, and finally real-dataset integration.

#table(
  columns: (1fr, 1.6fr),
  stroke: 0.5pt + rgb("#666666"),
  inset: 8pt,
  fill: (col, row) => if row == 0 { rgb("#eef6f4") } else { white },
  [*Component*], [*Technology*],
  [Simulation engine], [Python 3.13, SimPy 4.1 (discrete-event process/resource model)],
  [Randomness / distributions], [NumPy (`Generator`) --- Poisson, exponential, normal],
  [Data handling], [Pandas (per-patient records, resource samples, CSV ingestion)],
  [Charts], [Matplotlib (histograms, boxplots, bar charts, time series)],
  [Reports], [Markdown (per-scenario statistical report)],
  [Dashboard], [Static HTML5 / CSS3 / vanilla JavaScript, tabbed single-page layout],
  [Local hosting], [Python's built-in `http.server`],
  [This report], [Typst],
)

== Design Principles

+ *Separation of configuration from engine.* All tunable parameters (staff counts,
  capacities, arrival rates, service-time means/SDs, admission probabilities) live in a
  single `config.py` dataclass hierarchy, never hard-coded inside the simulation logic.
+ *Statistically honest randomness.* Every stochastic element uses a distribution chosen
  for the nature of the process (Poisson process for arrivals, exponential for short
  administrative tasks, normal for treatment/stay durations) rather than a uniform or fixed
  value, so results reflect realistic variability, not just an average case.
+ *Reproducibility.* Each simulation run is seeded (`random_seed`), so results are
  deterministic and comparable across scenario or parameter changes.
+ *Separation of engine, statistics, and reporting.* The SimPy process model
  (`hospital.py`) only records raw events; aggregation, KPI calculation, and chart
  generation are handled by independent `stats.py` / `report.py` modules, so the reporting
  layer can be extended without touching simulation logic.
+ *Data-driven extensibility.* Arrival rates can be swapped from constant, hand-picked
  values to an hourly rate table loaded from any CSV file — including one derived from a
  real dataset — without modifying the simulation engine.

= Simulation Model

Every simulated patient is an independent SimPy process that acquires and releases a
sequence of shared `Resource` / `PriorityResource` objects as it moves through the
hospital. The simulation clock is event-driven: rather than advancing second by second, it
jumps directly to the next scheduled event (an arrival, a service completion), which allows
a full simulated week (168 hours) to run in a few seconds of real time.

#align(center)[
  #box(fill: rgb("#eef6f4"), stroke: 0.8pt + black, radius: 6pt, inset: 12pt)[
    #text(weight: "bold")[
      Registration → Triage → ER / OPD Treatment →
      Diagnostics (p) → Ward / ICU Admission (p) → Discharge
    ]
  ]
]

#v(0.3em)

#table(
  columns: (1fr, 1fr, 1.6fr),
  stroke: 0.5pt + rgb("#666666"),
  inset: 8pt,
  fill: (col, row) => if row == 0 { rgb("#eef6f4") } else { white },
  [*Process*], [*Distribution*], [*Rationale*],
  [Patient arrivals (per category)], [Poisson process (exponential interarrival time)],
  [Independent, random walk-in demand --- the standard queueing-theory model.],
  [Registration, triage, diagnostics, discharge], [Exponential],
  [Short, highly variable administrative tasks; memoryless service time.],
  [ER treatment, OPD consult, ward stay], [Normal (clipped at a floor)],
  [Durations cluster around a typical value rather than being memoryless.],
)

Priority is enforced via SimPy's `PriorityResource` for the ER and ward/ICU beds: Emergency
patients (priority 0) are served ahead of Urgent (1), ahead of Regular (2), whenever
multiple patients are waiting for the same resource. This priority governs queue order
only — it is non-preemptive, so a patient already receiving treatment is never displaced.
After primary treatment, each patient independently rolls a configurable probability for
requiring diagnostics, and a separate, category-dependent probability for ward or ICU
admission, before proceeding to a dedicated discharge desk and leaving the system. Resource
utilization and queue length are sampled at fixed intervals throughout the run; the first
`warmup_hours` (default 24h) of simulated time are excluded from all KPI calculations so
that empty-system startup effects do not bias the results.

= Feature Comparison

#table(
  columns: (1.3fr, auto, auto, auto, auto, auto),
  stroke: 0.5pt + rgb("#666666"),
  inset: 7pt,
  fill: (col, row) => if row == 0 { rgb("#eef6f4") } else { white },
  align: center,
  [*Tool*], [*DES engine*], [*Priority queueing*], [*Real-data ingestion*], [*Free / OSS*], [*Dashboard*],
  [*HospiFlow Sim*], [✓], [✓], [✓], [✓], [✓],
  [Arena], [✓], [✓], [✓], [--], [--],
  [FlexSim Healthcare], [✓], [✓], [✓], [--], [partial],
  [Simul8], [✓], [partial], [✓], [--], [--],
  [Spreadsheet capacity model], [--], [--], [✓], [✓], [--],
  [draw.io / Lucidchart], [--], [--], [--], [✓], [--],
)

= Visual Models

== System Architecture

#align(center)[
  #grid(
    columns: 1, row-gutter: 8pt,
    box(stroke: 0.8pt + black, inset: 8pt, radius: 4pt, width: 70%)[
      *Configuration Layer* --- `config.py` (staff, capacity, arrival rates, service-time
      distributions, admission probabilities)
    ],
    align(center)[↓],
    box(stroke: 0.8pt + black, inset: 8pt, radius: 4pt, width: 70%)[
      *Simulation Engine* --- `hospital.py` (SimPy resources, patient-journey process,
      arrival processes, resource-utilization monitor)
    ],
    align(center)[↓],
    box(stroke: 0.8pt + black, inset: 8pt, radius: 4pt, width: 70%)[
      *Statistics Layer* --- `stats.py` (per-patient records, resource samples →
      Pandas DataFrames)
    ],
    align(center)[↓],
    box(stroke: 0.8pt + black, inset: 8pt, radius: 4pt, width: 70%)[
      *Reporting Layer* --- `report.py` (KPI summary, Markdown report, Matplotlib charts,
      scenario comparison)
    ],
    align(center)[↓],
    box(stroke: 0.8pt + black, inset: 8pt, radius: 4pt, width: 70%)[
      *Presentation Layer* --- static HTML/CSS/JS dashboard, served locally
    ],
  )
]

== Simulation Flow

#align(center)[
  #grid(
    columns: 1, row-gutter: 6pt,
    box(stroke: 0.8pt + black, inset: 7pt, radius: 4pt, width: 78%)[Poisson arrival process generates a new patient (category assigned)],
    align(center)[↓],
    box(stroke: 0.8pt + black, inset: 7pt, radius: 4pt, width: 78%)[Acquire waiting room → Registration (exponential) → Triage (exponential)],
    align(center)[↓],
    box(stroke: 0.8pt + black, inset: 7pt, radius: 4pt, width: 78%)[Priority-queue for ER (Emergency/Urgent) or OPD (Regular); treatment duration (normal)],
    align(center)[↓],
    box(stroke: 0.8pt + black, inset: 7pt, radius: 4pt, width: 78%)[Probability check: Diagnostics needed? → if yes, queue + exponential service],
    align(center)[↓],
    box(stroke: 0.8pt + black, inset: 7pt, radius: 4pt, width: 78%)[Category-weighted probability: Ward/ICU admission? → if yes, priority-queue for bed, normal-distributed stay],
    align(center)[↓],
    box(stroke: 0.8pt + black, inset: 7pt, radius: 4pt, width: 78%)[Discharge desk (exponential) → patient departs; timestamps recorded to stats collector],
  )
]

== Data Flow

#align(center)[
  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 10pt, row-gutter: 8pt,
    box(stroke: 0.8pt + black, inset: 7pt, radius: 4pt)[Config change / new scenario],
    box(stroke: 0.8pt + black, inset: 7pt, radius: 4pt)[SimPy `env.run()` executes all patient + monitor processes],
    box(stroke: 0.8pt + black, inset: 7pt, radius: 4pt)[Raw events → `StatsCollector`],
    box(stroke: 0.8pt + black, inset: 7pt, radius: 4pt)[Pandas aggregation (waits, utilization, queues)],
    box(stroke: 0.8pt + black, inset: 7pt, radius: 4pt)[Matplotlib charts + Markdown report written to disk],
    box(stroke: 0.8pt + black, inset: 7pt, radius: 4pt)[Charts base64-embedded → dashboard HTML],
  )
]

== Priority and Admission Rules

#table(
  columns: (auto, auto, 1fr),
  stroke: 0.5pt + rgb("#666666"),
  inset: 8pt,
  fill: (col, row) => if row == 0 { rgb("#eef6f4") } else { white },
  [*Category*], [*Queue priority*], [*Primary treatment path*],
  [Emergency], [Highest (0)], [Emergency Room],
  [Urgent], [Medium (1)], [Emergency Room],
  [Regular], [Standard (2)], [Outpatient Department],
)

== Timeline (Development Plan)

#table(
  columns: (2.2fr, auto, auto, auto, auto, auto, auto),
  stroke: 0.5pt + rgb("#666666"),
  inset: 6pt,
  align: center,
  fill: (col, row) => if row == 0 { rgb("#eef6f4") } else { white },
  [*Task*], [Wk 1], [Wk 2], [Wk 3], [Wk 4], [Wk 5], [Wk 6],
  [Requirements, model design, config schema], [✓], [], [], [], [], [],
  [Core SimPy engine (patient journey, resources)], [], [✓], [✓], [], [], [],
  [Statistics collection, KPI aggregation], [], [], [✓], [], [], [],
  [Report + chart generation (Matplotlib)], [], [], [✓], [✓], [], [],
  [Scenarios (Normal / Peak / Pandemic) + comparison], [], [], [], [✓], [], [],
  [Dashboard (HTML/CSS/JS) + local hosting], [], [], [], [], [✓], [],
  [Real-dataset ingestion, validation, final report], [], [], [], [], [✓], [✓],
)

= User Interface

The results dashboard is a single static HTML page with tab-based navigation across a
Comparison view and one tab per scenario (Normal, Peak Hours, Pandemic, Real Dataset), plus
a Methodology tab explaining the distribution choices. Each scenario tab shows KPI cards,
a per-category wait-time comparison, a resource-utilization table with color-coded status
(Healthy / Elevated / Critical), and the four auto-generated charts for that scenario.

#figure(
  image("hospital_sim/output/ui_comparison.png", width: 92%),
  caption: [The Comparison tab: all four scenarios side by side, with KPI table, comparison
    chart, and key takeaways.],
)

#figure(
  image("hospital_sim/output/pandemic_utilization.png", width: 70%),
  caption: [Auto-generated resource-utilization chart for the Pandemic scenario, showing
    ER, Ward, and ICU saturated at or near 100%.],
)

= Security and Privacy

HospiFlow Sim runs entirely on the local machine: the simulation engine, dashboard, and
local HTTP server all execute without any external network calls, account, or
authentication. Synthetic scenarios generate no real patient information whatsoever —
every "patient" is a randomly generated in-memory object that exists only for the duration
of the simulation run. The Real-Dataset scenario uses a publicly available, pre-anonymized
Kaggle dataset (patient identifiers are already synthetic placeholders in the source data,
not linked to real individuals); the simulation reads it only to derive an hourly
arrival-rate table and an aggregate admission probability, and never stores or transmits
individual records beyond the local machine. Because there is no backend and no
transmission of patient-level data, the design has no meaningful attack surface for data
exfiltration.

= Future Plans

+ A live, interactive web dashboard (Flask or FastAPI + WebSockets) allowing parameters
  (staff counts, bed capacity, arrival rates) to be adjusted with a slider and results to
  update in real time, rather than requiring a full re-run.
+ AI-based arrival-rate forecasting (e.g. a lightweight time-series model such as Prophet
  or an LSTM) trained on real historical admission data, to replace the fixed ESI-based
  category split with a learned, data-driven one.
+ Direct ingestion of hospital admission logs in common formats (HL7/FHIR exports, EHR CSV
  extracts) with an automated column-mapping step.
+ Modeling additional real-world constraints: ambulance diversion when the ER is
  saturated, staff shift schedules (rather than constant capacity), and multi-day
  length-of-stay distributions per diagnosis.
+ Packaging the simulation and dashboard as a single Docker container for one-command
  deployment on a hospital's internal network.

= Result

+ A modular discrete-event simulation was delivered, modeling the complete patient
  journey (registration through discharge) with priority-based queueing across three
  patient categories and fully configurable staff/capacity parameters.
+ Arrivals and service times are drawn from statistically appropriate distributions
  (Poisson, exponential, normal) rather than fixed constants, verified to produce
  realistic, non-degenerate queueing behavior across all tested scenarios.
+ Four scenarios (Normal, Peak Hours, Pandemic, Real-Dataset-driven) were implemented and
  run end to end, each automatically producing a statistical report, four charts, and a
  bottleneck identification.
+ A real, downloaded Kaggle Emergency Room dataset (9,216 patient records across 579
  days) was successfully ingested, revealing a real admission rate of 50% --- roughly ten
  times higher than the hand-picked assumption used in the synthetic scenarios, and
  demonstrating the practical value of validating simulation inputs against real data.
+ A locally hosted, tab-based interactive dashboard was built and verified in-browser,
  presenting all four scenarios, a cross-scenario comparison, and a methodology
  explanation in a single page with no external dependencies.

= Conclusion

HospiFlow Sim demonstrates that a credible, statistically grounded hospital patient-flow
simulation can be built entirely with open-source tools, without requiring proprietary
software licenses or access to a real hospital's live systems. By combining a clean
separation between configuration, simulation engine, statistics, and reporting with
well-justified probability distributions for every random process, the tool identifies
different operational bottlenecks (bed capacity, ER staffing, diagnostic throughput)
depending on the scenario, and its real-dataset integration shows concretely why
simulation assumptions must be checked against real records whenever they are available ---
in this project, a single miscalibrated probability (admission rate) was off by an order of
magnitude before validation. The resulting system is both a usable planning aid for
identifying where additional hospital investment would help most, and a compact
demonstration of discrete-event simulation, statistical modelling, and data-engineering
skills applied to a real-world operations problem.

#pagebreak(weak: true)
#set heading(numbering: none)
= References

#set text(size: 10.5pt)

#[
  #set enum(numbering: "[1]", full: true)

  + #[L. Kleinrock, #emph[Queueing Systems, Volume 1: Theory]. Wiley-Interscience, 1975.]
  + #[J. D. C. Little, "A Proof for the Queuing Formula: L = λ W," #emph[Operations Research], vol. 9, no. 3, pp. 383-387, 1961, doi: 10.1287/opre.9.3.383.]
  + #[S. H. Jacobson, S. N. Hall, and J. R. Swisher, "Discrete-Event Simulation of Health Care Systems," in #emph[Patient Flow: Reducing Delay in Healthcare Delivery], R. W. Hall, Ed. Springer, 2006.]
  + #[D. Fone et al., "Systematic review of the use of simulation modelling in public health," #emph[Journal of Public Health Medicine], vol. 25, no. 4, pp. 325-335, 2003.]
  + #[Rockwell Automation, "Arena Simulation Software." [Online]. Available: https://www.rockwellautomation.com/en-us/products/software/arena-simulation.html]
  + #[FlexSim Software Products, "FlexSim Healthcare." [Online]. Available: https://www.flexsim.com/healthcare/]
  + #[Simul8 Corporation, "Simul8 Simulation Software." [Online]. Available: https://www.simul8.com/]
  + #[Team SimPy, "SimPy: Discrete Event Simulation for Python." [Online]. Available: https://simpy.readthedocs.io/]
]

#align(center)[#text(weight: "bold")[THE END]]
