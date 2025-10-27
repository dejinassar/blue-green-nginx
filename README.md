# Blue-Green Deployment with Nginx (Auto-Failover + Manual Toggle)

## Overview
This project implements a **Blue-Green deployment setup** using **Docker Compose** and **Nginx upstreams**.
The goal is to simulate a zero-downtime deployment setup where **Blue** is the active service and **Green** serves as a hot standby.
If the Blue service fails, Nginx automatically switches traffic to Green ensuring clients experience no downtime.

---

## Architecture
- **Blue app** Active instance (port `8081`)
- **Green app** Backup instance (port `8082`)
- **Nginx** Acts as a reverse proxy and failover controller (public entrypoint on `8080`)

Nginx monitors the health of the Blue app and automatically retries requests on Green when Blue becomes unavailable or returns 5xx errors.

---

## How to Run Locally

1.  **Clone and navigate into the repo**
    ```bash
    git clone 
    cd blue-green-nginx
    ```

2.  **Create your .env file**
    ```bash
    cp .env.example .env
    ```

3.  **Start all services**
    ```bash
    docker-compose up --build
    ```

This starts:
* **Blue** on port `8081`
* **Green** on port `8082`
* **Nginx** on port `8080` (entrypoint)

---

## Test the Setup

### 1. Check baseline (Blue active)
```bash
curl -i http://localhost:8080/version
You should see headers like:

X-App-Pool: blue
X-Release-Id: v1.0.0
2.  Simulate Blue failure (Chaos)
Bash

curl -X POST http://localhost:8081/chaos/start
3. Test failover
Bash

curl -i http://localhost:8080/version
Now the response should come from Green:

X-App-Pool: green
X-Release-Id: v1.0.1
4. Stop chaos
Bash

curl -X POST http://localhost:8081/chaos/stop
>>>>>>> 0161b00 (Initial commit - Blue Green Nginx project)
