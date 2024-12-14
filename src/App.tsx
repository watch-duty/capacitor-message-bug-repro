import { useEffect, useState } from "react";
import "./App.css";
import { App as CapacitorApp } from "@capacitor/app";

function App() {
  const [counter, setCounter] = useState(0);
  const [lastUrl, setLastUrl] = useState("");
  const [lastUrlDate, setLastUrlDate] = useState<Date | null>(null);

  useEffect(() => {
    CapacitorApp.addListener("appUrlOpen", (event) => {
      setLastUrl(event.url);
      setLastUrlDate(new Date());
      setCounter((prev) => prev + 1);
    });
  }, []);

  return (
    <>
      <div className="card">
        <p>Last URL: {lastUrl}</p>
        <p>Last event date: {lastUrlDate?.toString()}</p>
        <p>Did it work?: {counter > 0 ? "YES IT WORKED" : "NOPE"}</p>
      </div>
    </>
  );
}

export default App;
