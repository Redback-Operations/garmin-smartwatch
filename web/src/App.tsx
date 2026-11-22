import { BrowserRouter, Link, Route, Routes } from "react-router-dom";
import RunHistory from "./pages/RunHistory";
import RunDetail from "./pages/RunDetail";
import Trends from "./pages/Trends";

export default function App() {
  return (
    <BrowserRouter>
      <nav style={{ display: "flex", gap: "1rem", padding: "1rem" }}>
        <Link to="/">Run history</Link>
        <Link to="/trends">Trends</Link>
      </nav>
      <main style={{ padding: "1rem" }}>
        <Routes>
          <Route path="/" element={<RunHistory />} />
          <Route path="/runs/:id" element={<RunDetail />} />
          <Route path="/trends" element={<Trends />} />
        </Routes>
      </main>
    </BrowserRouter>
  );
}