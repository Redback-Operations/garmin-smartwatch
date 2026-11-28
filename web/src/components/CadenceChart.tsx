import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ReferenceArea,
  ReferenceLine,
  ResponsiveContainer,
  Legend,
} from "recharts";

const TARGET_CADENCE = 160;
const LOWER_LIMIT = TARGET_CADENCE * 0.95;
const UPPER_LIMIT = TARGET_CADENCE * 1.05;

type CadencePoint = {
  time: number;
  cadence: number | null;
};

const dummyData: CadencePoint[] = [
  { time: 0, cadence: 140 },
  { time: 1, cadence: 150 },
  { time: 2, cadence: 156 },
  { time: 3, cadence: 162 },
  { time: 4, cadence: 165 },
  { time: 5, cadence: 172 },
  { time: 6, cadence: 175 },
  { time: 7, cadence: 164 },
  { time: 8, cadence: 160 },
  { time: 9, cadence: 155 },
  { time: 10, cadence: 148 },
  { time: 11, cadence: 158 },
  { time: 12, cadence: 166 },
  { time: 13, cadence: 170 },
  { time: 14, cadence: 162 },
  { time: 15, cadence: 154 },
];

type CadenceChartProps = {
  data?: CadencePoint[];
};

// Calculate the percentage of valid recorded time
// spent within the target cadence zone.
function calculateTimeInZone(data: CadencePoint[]) {
  let totalTime = 0;
  let timeInZone = 0;

  for (let i = 0; i < data.length - 1; i++) {
    const cadence = data[i].cadence;
    const duration = data[i + 1].time - data[i].time;

    if (
      cadence === null ||
      !Number.isFinite(cadence) ||
      cadence <= 0 ||
      !Number.isFinite(duration) ||
      duration <= 0
    ) {
      continue;
    }

    totalTime += duration;

    if (cadence >= LOWER_LIMIT && cadence <= UPPER_LIMIT) {
      timeInZone += duration;
    }
  }

  return totalTime > 0
    ? (timeInZone / totalTime) * 100
    : null;
}

export default function CadenceChart({
  data = dummyData,
}: CadenceChartProps) {
  const percentageInZone = calculateTimeInZone(data);

  return (
    <section
      style={{
        width: "100%",
        maxWidth: "1000px",
        margin: "24px auto",
        padding: "24px",
        backgroundColor: "#ffffff",
        color: "#1f2937",
        borderRadius: "12px",
        border: "1px solid #e5e7eb",
        boxSizing: "border-box",
      }}
    >
      <h2 style={{ marginTop: 0, color: "#1f2937" }}>
        Running Cadence Analysis
      </h2>

      <p style={{ color: "#64748b" }}>
        Monitor running cadence over time and compare
        performance against the target zone.
      </p>

      {/* Summary statistics */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns:
            "repeat(auto-fit, minmax(140px, 1fr))",
          gap: "16px",
          marginBottom: "24px",
        }}
      >
        <div
          style={{
            backgroundColor: "#f8fafc",
            padding: "16px",
            borderRadius: "8px",
            border: "1px solid #e2e8f0",
            textAlign: "center",
          }}
        >
          <strong>Target Cadence</strong>
          <p style={{ fontSize: "22px", margin: "8px 0 0" }}>
            {TARGET_CADENCE} SPM
          </p>
        </div>

        <div
          style={{
            backgroundColor: "#f8fafc",
            padding: "16px",
            borderRadius: "8px",
            border: "1px solid #e2e8f0",
            textAlign: "center",
          }}
        >
          <strong>Target Zone</strong>
          <p style={{ fontSize: "22px", margin: "8px 0 0" }}>
            {LOWER_LIMIT} – {UPPER_LIMIT} SPM
          </p>
        </div>

        <div
          style={{
            backgroundColor: "#f0fdf4",
            padding: "16px",
            borderRadius: "8px",
            border: "1px solid #bbf7d0",
            textAlign: "center",
          }}
        >
          <strong>Time in Target Zone</strong>
          <p
            style={{
              fontSize: "22px",
              margin: "8px 0 0",
              color: "#15803d",
              fontWeight: "bold",
            }}
          >
            {percentageInZone === null
              ? "N/A"
              : `${percentageInZone.toFixed(1)}%`}
          </p>
        </div>
      </div>

      {/* Cadence line chart */}
      <ResponsiveContainer width="100%" height={350}>
        <LineChart
          data={data}
          margin={{
            top: 20,
            right: 20,
            left: 15,
            bottom: 30,
          }}
        >
          <CartesianGrid
            strokeDasharray="3 3"
            stroke="#e5e7eb"
          />

          <XAxis
            dataKey="time"
            type="number"
            domain={["dataMin", "dataMax"]}
            tickFormatter={(value) =>
              Number(value).toFixed(1)
            }
            label={{
              value: "Elapsed Time (minutes)",
              position: "insideBottom",
              offset: -15,
            }}
          />

          <YAxis
            domain={[0, "auto"]}
            label={{
              value: "Cadence (SPM)",
              angle: -90,
              position: "insideLeft",
            }}
          />

          <Tooltip />

          <Legend verticalAlign="top" />

          <ReferenceArea
            y1={LOWER_LIMIT}
            y2={UPPER_LIMIT}
            fill="#22c55e"
            fillOpacity={0.18}
            strokeOpacity={0}
            ifOverflow="extendDomain"
          />

          <ReferenceLine
            y={TARGET_CADENCE}
            stroke="#16a34a"
            strokeDasharray="5 5"
            label="Target: 160"
          />

          <Line
            type="linear"
            dataKey="cadence"
            name="Running Cadence"
            stroke="#2563eb"
            strokeWidth={2.5}
            dot={false}
            activeDot={{ r: 5 }}
            connectNulls={false}
          />
        </LineChart>
      </ResponsiveContainer>

      {/* Target zone legend */}
      <div
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          gap: "8px",
          marginTop: "12px",
        }}
      >
        <span
          style={{
            width: "18px",
            height: "12px",
            backgroundColor: "#bbf7d0",
            border: "1px solid #22c55e",
          }}
        />
        <span>Target zone (152–168 SPM)</span>
      </div>
    </section>
  );
}
