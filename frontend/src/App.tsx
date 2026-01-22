import React, { useState } from "react";
import { Send, MapPin, Calendar, CheckCircle, Loader2 } from "lucide-react";

// Interfaces
interface Plan {
  days: {
    day: number;
    activities: string[];
  }[];
  estimated_cost: string;
}

const API_BASE_URL = import.meta.env.VITE_API_URL;

function App() {
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(false);
  const [step, setStep] = useState<
    "input" | "researching" | "planning" | "done"
  >("input");
  const [plan, setPlan] = useState<Plan | null>(null);

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!query.trim()) return;

    if (!API_BASE_URL) {
      alert("API URL not configured! Please set VITE_API_URL in frontend/.env");
      return;
    }

    setLoading(true);
    setStep("researching");

    try {
      // 1. Research
      console.log("Researching...");
      const researchRes = await fetch(`${API_BASE_URL}/research`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ input: query }),
      });
      if (!researchRes.ok) throw new Error("Research failed");
      const researchData = await researchRes.json();
      const researchOutput = researchData.output;

      setStep("planning");

      // 2. Planning
      console.log("Planning...");
      const planRes = await fetch(`${API_BASE_URL}/plan`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          research_content: researchOutput,
          user_preferences: query,
        }),
      });
      if (!planRes.ok) throw new Error("Planning failed");
      const planDataMap = await planRes.json();

      // Parse the JSON plan from the agent response
      const planData = JSON.parse(planDataMap.plan);
      setPlan(planData);

      setStep("done");
    } catch (error) {
      console.error(error);
      alert("An error occurred active agents. Check console/network.");
      setStep("input");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-4">
      <header className="mb-8 text-center">
        <h1 className="text-4xl font-bold text-blue-600 mb-2 flex items-center justify-center gap-2">
          <MapPin className="w-8 h-8" /> WanderAI
        </h1>
        <p className="text-gray-600">Your Intelligent Travel Companion.</p>
      </header>

      <main className="w-full max-w-2xl bg-white rounded-xl shadow-xl p-6">
        {step === "input" && (
          <form onSubmit={handleSearch} className="flex gap-2">
            <input
              type="text"
              className="flex-1 p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
              placeholder="Where do you want to go? (e.g., Weekend trip to Kyoto)"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
            <button
              type="submit"
              disabled={loading}
              className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition flex items-center gap-2 disabled:opacity-50"
            >
              {loading ? <Loader2 className="animate-spin" /> : <Send />}
            </button>
          </form>
        )}

        {(step === "researching" || step === "planning") && (
          <div className="text-center py-10">
            <Loader2 className="w-12 h-12 text-blue-500 animate-spin mx-auto mb-4" />
            <h2 className="text-xl font-semibold">
              {step === "researching"
                ? "Researching destinations..."
                : "Crafting your itinerary..."}
            </h2>
            <p className="text-gray-500 mt-2">
              Our agents are working their magic.
            </p>
          </div>
        )}

        {step === "done" && plan && (
          <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="flex items-center justify-between border-b pb-4">
              <h2 className="text-2xl font-bold">Your Itinerary</h2>
              <span className="bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm font-medium">
                Est. Cost: {plan.estimated_cost}
              </span>
            </div>

            <div className="space-y-4">
              {plan.days.map((day) => (
                <div
                  key={day.day}
                  className="border-l-4 border-l-blue-500 pl-4 py-2 bg-gray-50 rounded-r-lg"
                >
                  <h3 className="font-semibold text-lg text-blue-700 flex items-center gap-2">
                    <Calendar className="w-4 h-4" /> Day {day.day}
                  </h3>
                  <ul className="mt-2 space-y-1">
                    {day.activities.map((act, idx) => (
                      <li
                        key={idx}
                        className="flex items-center gap-2 text-gray-700"
                      >
                        <CheckCircle className="w-3 h-3 text-green-500" />
                        {act}
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </div>

            <button
              onClick={() => {
                setStep("input");
                setPlan(null);
                setQuery("");
              }}
              className="w-full mt-4 py-2 text-blue-600 hover:text-blue-800 underline"
            >
              Plan another trip
            </button>
          </div>
        )}
      </main>
    </div>
  );
}

export default App;
