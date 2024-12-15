import { useEffect, useState } from "react";
import "./App.css";
import { App as CapacitorApp } from "@capacitor/app";

const getResultMessage = (gotTestUrl: boolean, isTestComplete: boolean) => {
  if (gotTestUrl) {
    return "YES IT WORKED";
  }
  if (!isTestComplete) {
    return "WAITING";
  }
  return "NOPE";
};

function App() {
  const [gotTestMessage, setGotTestMessage] = useState(false);
  const [isTestComplete, setIsTestComplete] = useState(false);
  const [lastUrlDate, setLastUrlDate] = useState<Date | null>(null);

  useEffect(() => {
    CapacitorApp.addListener("appUrlOpen", (event) => {
      if (event.url == "capmessagebug://test") {
        setGotTestMessage(true);
        setLastUrlDate(new Date());
      } else if (event.url == "capmessagebug://complete") {
        setIsTestComplete(true);
      }
    });
  }, []);

  return (
    <>
      <div className="card">
        <p>Test message at: {lastUrlDate?.toString()}</p>
        <p>Did it work?: {getResultMessage(gotTestMessage, isTestComplete)}</p>
      </div>
    </>
  );
}

export default App;
