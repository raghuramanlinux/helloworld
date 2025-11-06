const express = require('express');
const app = express();
let cache = {};

app.get('/data', (req, res) => {
  // Simulate random 500 error
  if (Math.random() < 0.3) {
    console.error("❌ Simulated failure: Random crash condition met");
    return res.status(500).json({ error: 'Internal Server Error (random)' });
  }

  // Random cache behavior
  const key = Math.floor(Math.random() * 5);
  if (!cache[key]) {
    console.warn(`⚠️ Cache miss for key ${key}`);
    cache[key] = { value: `data-${key}` };
  }

  res.json({ result: cache[key], timestamp: new Date().toISOString() });
});

app.listen(3000, () => console.log("🚀 App running on port 3000"));

