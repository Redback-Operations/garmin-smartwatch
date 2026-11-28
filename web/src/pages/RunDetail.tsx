import { useParams } from "react-router-dom";
import CadenceChart from "../components/CadenceChart";
import sampleRun1 from "../../sample-data/R001_run1.json";
import sampleRun2 from "../../sample-data/R001_run2.json";

const sampleRuns = {
  R001: sampleRun1,
  R001_run1: sampleRun1,
  R001_run2: sampleRun2,
};

export default function RunDetail() {
  const { id } = useParams();

  const sampleRun =
    sampleRuns[id as keyof typeof sampleRuns];

  if (!sampleRun) {
    return <h1>Run not found</h1>;
  }

  const cadenceData = sampleRun.points.map((point) => ({
    time: point.elapsed_s / 60,
    cadence: point.cadence_spm,
  }));

  return (
    <div>
      <h1>Run detail: {id}</h1>
      <CadenceChart data={cadenceData} />
    </div>
  );
}
