
---

# DECISION.md — Blue-Green with Nginx

## Overview
This document explains the reasoning and implementation choices behind the Blue-Green deployment setup.  
The goal was to simulate **zero downtime deployment** and ensure **automatic failover** using **Nginx upstreams**.

---

##  Design Choices

###  Docker Compose
- Chosen for simplicity and portability.
- Orchestrates all services — Blue, Green, and Nginx — in one command.
- Enables `.env` parameterization for flexibility in CI/CD.

###  Nginx as Reverse Proxy
- Acts as a **traffic director**.
- Configured with:
  - `upstream` blocks for Blue (primary) and Green (backup)
  - `proxy_next_upstream` for retries on failure
  - Tight timeouts and `max_fails` for quick switchovers
- Ensures **automatic failover** when Blue returns 5xx or times out.

###  Application Layer
- Node.js apps expose `/version`, `/chaos/start`, `/chaos/stop`, and `/healthz`.
- Each app sets headers:
  - `X-App-Pool` (blue | green)
  - `X-Release-Id` (v1.0.0 | v1.0.1)
- Fail simulation built into the `/chaos` endpoints.

---

##  Key Implementation Insights
| Area | Decision | Reason |
|------|-----------|--------|
| **Failover** | Use `backup` directive for Green | Allows Nginx to retry immediately without downtime |
| **Timeouts** | `proxy_connect_timeout 2s`, `proxy_read_timeout 5s` | Fast detection of errors/timeouts |
| **Retries** | `proxy_next_upstream` rules | Ensures requests auto-retry on errors or 5xx |
| **Headers** | Forwarded from app → client | Required by grader for validation |
| **Parameterization** | via `.env` | Allows easy swapping of versions in CI/CD |

---

##  Testing Approach
1. Verified baseline — traffic routed to Blue.
2. Triggered chaos on Blue → Nginx auto-switched to Green.
3. Stopped chaos → Blue recovered.
4. No downtime or 502s observed during failover.
5. Headers remained consistent (`X-App-Pool` and `X-Release-Id`).

---

##  Learnings
- Understanding how **Nginx upstream** handles failover logic.
- Implementing **Blue/Green** pattern in a containerized environment.
- Testing **resilience** and **chaos simulation** without Kubernetes.
- Importance of **timeouts and retries** for reliability.

---

##  Conclusion
This project replicates a real-world deployment pattern used by companies to achieve:
- **Zero downtime**
- **Rollback safety**
- **Deployment confidence**
