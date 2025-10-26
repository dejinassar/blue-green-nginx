const http = require("http");

const PORT = process.env.PORT || 8082;
const APP_POOL = "green";
const RELEASE_ID = process.env.RELEASE_ID || "v1.0.0";
let fail = false;

const server = http.createServer((req, res) => {
  if (req.url.startsWith("/chaos/start")) {
    fail = true;
    res.writeHead(200);
    res.end("Chaos started");
    return;
  }

  if (req.url.startsWith("/chaos/stop")) {
    fail = false;
    res.writeHead(200);
    res.end("Chaos stopped");
    return;
  }

  if (fail) {
    res.writeHead(500);
    res.end("Simulated failure");
    return;
  }

  if (req.url === "/version") {
    res.writeHead(200, {
      "Content-Type": "application/json",
      "X-App-Pool": APP_POOL,
      "X-Release-Id": RELEASE_ID
    });
    res.end(JSON.stringify({ pool: APP_POOL, release: RELEASE_ID }));
  } else {
    res.writeHead(200, {
      "X-App-Pool": APP_POOL,
      "X-Release-Id": RELEASE_ID
    });
    res.end(`Hello from ${APP_POOL.toUpperCase()} deployment!\n`);
  }
});

server.listen(PORT, () => {
  console.log(`✅ Green app running on port ${PORT}`);
});
