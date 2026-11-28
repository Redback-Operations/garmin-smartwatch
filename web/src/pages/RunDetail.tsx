import { useParams } from "react-router-dom";
import CadenceChart from "../components/CadenceChart";
import sampleRun1 from "../../sample-data/R001_run1.json";
import sampleRun2 from "../../sample-data/R001_run2.json";
import "./RunDetail.css";

// Shape of the WEB-15 sample run files in web/sample-data.
type RunPoint = {
  elapsed_s: number;
  cadence_spm: number | null;
  speed_mps: number | null;
  heart_rate: number | null;
  distance_m: number | null;
  stride_length_m?: number | null;
  vertical_oscillation_cm?: number | null;
  ground_contact_ms?: number | null;
  // Not in the sample files yet. Shown as "No data" until the files include it.
  ground_contact_balance_pct?: number | null;
};

type RunData = {
  runner_id: string;
  device_model: string;
  start_time: string;
  duration_s: number;
  distance_m: number;
  avg_cadence_spm: number;
  avg_heart_rate: number;
  points: RunPoint[];
};

type Split = { km: number; durationSec: number; cadence: number | null; heartRate: number | null };

const sampleRuns: Record<string, RunData> = {
  R001: sampleRun1,
  R001_run1: sampleRun1,
  R001_run2: sampleRun2,
};

// Shown when the page is opened without a run id.
const DEFAULT_RUN_ID = "R001_run1";

function formatDuration(totalSeconds: number): string {
  const whole = Math.round(totalSeconds);
  const h = Math.floor(whole / 3600);
  const m = Math.floor((whole % 3600) / 60);
  const s = whole % 60;
  const mm = h > 0 ? String(m).padStart(2, "0") : String(m);
  return `${h > 0 ? `${h}:` : ""}${mm}:${String(s).padStart(2, "0")}`;
}

function formatDate(startTime: string): string {
  // Sample files store "YYYY-MM-DD HH:MM:SS" in UTC.
  const date = new Date(`${startTime.replace(" ", "T")}Z`);
  return date.toLocaleDateString("en-AU", { day: "numeric", month: "short", year: "numeric", timeZone: "UTC" });
}

function average(values: (number | null | undefined)[]): number | null {
  const valid = values.filter((v): v is number => typeof v === "number" && Number.isFinite(v) && v > 0);
  return valid.length === 0 ? null : valid.reduce((sum, v) => sum + v, 0) / valid.length;
}

function show(value: number | null, unit: string, digits = 0): string {
  return value === null ? "No data" : `${value.toFixed(digits)} ${unit}`;
}

// The sample files have no lap records, so each kilometre split is worked out
// from the distance on the points. Time counts only while the runner is moving,
// so a pause does not inflate a split.
const MOVING_SPEED_MPS = 0.5;

function buildSplits(points: RunPoint[]): Split[] {
  const withDistance = points.filter((p) => typeof p.distance_m === "number") as (RunPoint & { distance_m: number })[];
  const splits: Split[] = [];
  let movingTime = 0;
  let startIndex = 0;

  for (let i = 1; i < withDistance.length; i++) {
    const prev = withDistance[i - 1];
    const cur = withDistance[i];
    const elapsed = cur.elapsed_s - prev.elapsed_s;
    const span = cur.distance_m - prev.distance_m;
    // Speed over this step, from distance covered. A paused watch leaves a long gap with little distance.
    const moving = elapsed > 0 && span / elapsed > MOVING_SPEED_MPS;
    const step = moving ? elapsed : 0;
    const target = (splits.length + 1) * 1000;

    if (cur.distance_m < target) {
      movingTime += step;
      continue;
    }

    const fraction = span > 0 ? (target - prev.distance_m) / span : 1;
    const inSplit = withDistance.slice(startIndex, i + 1);
    const cadence = average(inSplit.map((p) => p.cadence_spm));
    const heartRate = average(inSplit.map((p) => p.heart_rate));

    splits.push({
      km: splits.length + 1,
      durationSec: movingTime + fraction * step,
      cadence: cadence === null ? null : Math.round(cadence),
      heartRate: heartRate === null ? null : Math.round(heartRate),
    });
    movingTime = (1 - fraction) * step;
    startIndex = i;
  }
  return splits;
}

function Tile({ label, value }: { label: string; value: string }) {
  return (
    <div className="run-tile">
      <div className="run-label">{label}</div>
      <div className="run-value">{value}</div>
    </div>
  );
}

export default function RunDetail() {
  const { id = DEFAULT_RUN_ID } = useParams();
  const run = sampleRuns[id];

  if (!run) {
    return <h1>Run not found</h1>;
  }

  const cadenceData = run.points.map((point) => ({
    time: point.elapsed_s / 60,
    cadence: point.cadence_spm,
  }));

  const splits = buildSplits(run.points);
  const strideLength = average(run.points.map((p) => p.stride_length_m));
  const verticalOscillation = average(run.points.map((p) => p.vertical_oscillation_cm));
  const groundContact = average(run.points.map((p) => p.ground_contact_ms));
  // Vertical ratio is vertical oscillation as a percentage of stride length.
  const verticalRatio = average(
    run.points.map((p) =>
      p.vertical_oscillation_cm && p.stride_length_m ? p.vertical_oscillation_cm / p.stride_length_m : null,
    ),
  );
  // Share of ground contact time on the left foot. The right foot is the remainder.
  const balanceLeft = average(run.points.map((p) => p.ground_contact_balance_pct));

  return (
    <div className="run">
      <header className="run-header">
        <h1>Run on {formatDate(run.start_time)}</h1>
        <p className="run-muted">
          Runner {run.runner_id}, recorded on {run.device_model}. Sample data ({id}).
        </p>
      </header>

      <section className="run-tiles" aria-label="Summary">
        <Tile label="Distance" value={`${(run.distance_m / 1000).toFixed(2)} km`} />
        <Tile label="Time" value={formatDuration(run.duration_s)} />
        <Tile label="Avg cadence" value={`${run.avg_cadence_spm} spm`} />
        <Tile label="Avg heart rate" value={`${run.avg_heart_rate} bpm`} />
      </section>

      <CadenceChart data={cadenceData} />

      <div className="run-columns">
        <section className="run-card">
          <h2>Splits</h2>
          <div className="run-scroll">
            <table className="run-table">
              <thead>
                <tr>
                  <th>Km</th>
                  <th>Time</th>
                  <th>Cadence</th>
                  <th>Heart rate</th>
                </tr>
              </thead>
              <tbody>
                {splits.map((split) => (
                  <tr key={split.km}>
                    <td>{split.km}</td>
                    <td>{formatDuration(split.durationSec)}</td>
                    <td>{split.cadence ?? "-"}</td>
                    <td>{split.heartRate ?? "-"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>

        <section className="run-card">
          <h2>Running dynamics</h2>
          <dl className="run-list">
            <dt>Cadence</dt>
            <dd>{show(run.avg_cadence_spm ?? null, "spm")}</dd>
            <dt>Stride length</dt>
            <dd>{show(strideLength, "m", 2)}</dd>
            <dt>Vertical oscillation</dt>
            <dd>{show(verticalOscillation, "cm", 1)}</dd>
            <dt>Vertical ratio</dt>
            <dd>{verticalRatio === null ? "No data" : `${verticalRatio.toFixed(1)}%`}</dd>
            <dt>Ground contact time</dt>
            <dd>{show(groundContact, "ms")}</dd>
            <dt>Ground contact balance</dt>
            <dd>
              {balanceLeft === null
                ? "No data"
                : `${balanceLeft.toFixed(1)}% L / ${(100 - balanceLeft).toFixed(1)}% R`}
            </dd>
          </dl>
        </section>
      </div>
    </div>
  );
}