/**
 * Simple Express App - Fixed Version
 * ----------------------------------
 * Original bug: Random HTTP 500 errors caused by intentional failure logic (Math.random()).
 * Fix: Removed random failures, added try/catch error handling and structured logging.
 */

const express = require('express');
const app = express();

// Simple in-memory cache
let cache = {};

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Main data endpoint
app.get('/data', (req, res) => {
  try {
    const key = Math.floor(Math.random() * 5);

    // Simulate normal cache usage
    if (!cache[key]) {
      console.warn(`⚠️ Cache miss for key ${key}`);
      cache[key] = { value: `data-${key}` };
    }

    // Successful response
    console.log(`✅ Served key ${key} from cache`);
    res.status(200).json({
      result: cache[key],
      timestamp: new Date().toISOString(),
    });
  } catch (err) {
    console.error("❌ Unexpected error occurred:", err.message);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Start the app
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 App running on port ${PORT}`);
});

