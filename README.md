# Canary Release Hands-on Lab

Learn canary deployments using Docker + Traefik!

## What is Canary Release?

A deployment strategy that releases new versions to a **small subset of users** first, then gradually rolls out to everyone after validating there are no issues.

```
         ┌─────────────────┐
         │     Traefik     │
         │ (Load Balancer) │
         └────────┬────────┘
                  │
       ┌──────────┴──────────┐
       │ 90%            10%  │
       ▼                     ▼
┌─────────────┐      ┌─────────────┐
│   v1.0.0    │      │   v2.0.0    │
│  (STABLE)   │      │  (CANARY)   │
└─────────────┘      └─────────────┘
```

## File Structure

```
canary-demo/
├── docker-compose.yml    # Service definitions
├── traefik-dynamic.yml   # Traefik routing config (weights here!)
├── Dockerfile            # Container build config
├── server.py             # Python web server
├── templates/
│   └── index.html        # HTML template
├── test-canary.sh        # Test script
└── README.md
```

## Hands-on Steps

### Step 1: Start the services

```bash
docker compose up -d --build
```

### Step 2: Verify it works

Open in your browser:
- **App**: http://localhost (refresh multiple times!)
- **Traefik Dashboard**: http://localhost:8080

### Step 3: Check traffic distribution

```bash
chmod +x test-canary.sh
./test-canary.sh
```

You should see approximately 90:10 distribution.

### Step 4: Change the ratio

Edit `traefik-dynamic.yml` weights:

```yaml
services:
  app-weighted:
    weighted:
      services:
        - name: app-stable@docker
          weight: 50
        - name: app-canary@docker
          weight: 50
```

Traefik will auto-reload the config (no restart needed).
Note: Somehow, it requires restart. If it does not change, please perform "docker compose restart traefik"

Run the test again to see the new distribution!

### Step 5: Rollback

If issues occur, stop the canary:

```bash
docker compose stop app-canary
```

All traffic now goes to STABLE.

### Step 6: Full rollout

If everything looks good, set CANARY to 100%:


## Cleanup

```bash
docker compose down
```

