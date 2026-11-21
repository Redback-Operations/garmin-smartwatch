import { useParams } from "react-router-dom";

export default function RunDetail() {
  const { id } = useParams();
  return <h1>Run detail: {id}</h1>;
}