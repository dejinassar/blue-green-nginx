#!/bin/bash

# Config
NGINX_URL="http://localhost:8080"
BLUE_POOL="blue"
GREEN_POOL="green"
ACTIVE_ENV_FILE=".env"
APP_CONTAINER="blue-green-app_blue"

echo " Starting Stage 3 automated test..."

# 1 Hit active pool a few times
echo "Step 1: Hitting current active pool..."
for i in {1..5}; do
  curl -s -o /dev/null "$NGINX_URL"
done
echo " Baseline requests sent."

# 2 Simulate failover
echo "Step 2: Simulating failover..."
sed -i "s/^ACTIVE_POOL=.*/ACTIVE_POOL=$GREEN_POOL/" $ACTIVE_ENV_FILE
sed -i "s/^ACTIVE_RELEASE=.*/ACTIVE_RELEASE=v1.0.1/" $ACTIVE_ENV_FILE
docker compose restart nginx
sleep 5

# Hit new pool a few times to trigger failover alert
echo "Sending requests to new pool..."
for i in {1..5}; do
  curl -s -o /dev/null "$NGINX_URL"
done
echo " Failover requests sent. Slack should show failover alert."

# 3 Inject 500 responses for error-rate alert
echo "Step 3: Simulating high error rate..."
docker compose exec $APP_CONTAINER sh -c "echo 'app.get(\"/fail\", (req, res) => res.status(500).send(\"Simulated error\"));' >> /app/dist/app.js"
docker compose restart $APP_CONTAINER
sleep 5

# Send requests to /fail to trigger error-rate alert
for i in {1..50}; do
  curl -s -o /dev/null "$NGINX_URL/fail"
done
echo " Error-rate requests sent. Slack should show high error-rate alert."

# 4 Show last 10 Nginx logs
echo "Step 4: Last 10 Nginx access logs:"
docker compose exec nginx tail -n 10 /var/log/nginx/access.log

echo " Stage 3 automated test complete. Take screenshots of Slack alerts and logs for submission."
