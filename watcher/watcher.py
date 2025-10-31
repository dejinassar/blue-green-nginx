import time, os, requests
from collections import deque

LOG_FILE = "/logs/access.log"  # mount nginx_logs here
WINDOW_SIZE = int(os.getenv("WINDOW_SIZE", 200))
ERROR_THRESHOLD = float(os.getenv("ERROR_RATE_THRESHOLD", 2))
COOLDOWN = int(os.getenv("ALERT_COOLDOWN_SEC", 300))
SLACK_WEBHOOK = os.getenv("SLACK_WEBHOOK_URL")

last_pool = None
last_alert_time = 0
error_window = deque(maxlen=WINDOW_SIZE)

def send_slack(msg):
    try:
        requests.post(SLACK_WEBHOOK, json={"text": msg})
    except Exception as e:
        print(f"Slack alert failed: {e}")

def parse_line(line):
    parts = line.split()
    pool = next((p.split('=')[1] for p in parts if p.startswith("pool=")), None)
    status = int(next((s.split('=')[1] for s in parts if s.startswith("upstream_status=")), 0))
    return pool, status

with open(LOG_FILE) as f:
    while True:
        line = f.readline()
        if not line:
            time.sleep(0.1)
            continue

        pool, status = parse_line(line)

        # Track 5xx error rate
        error_window.append(1 if 500 <= status < 600 else 0)
        error_rate = sum(error_window)/len(error_window) * 100

        # High error rate alert
        if error_rate > ERROR_THRESHOLD and (time.time() - last_alert_time) > COOLDOWN:
            send_slack(f":warning: High error rate detected: {error_rate:.2f}%")
            last_alert_time = time.time()

        # Pool failover detection
        if last_pool and last_pool != pool and (time.time() - last_alert_time) > COOLDOWN:
            send_slack(f":arrows_counterclockwise: Failover detected: {last_pool} → {pool}")
            last_alert_time = time.time()

        last_pool = pool
