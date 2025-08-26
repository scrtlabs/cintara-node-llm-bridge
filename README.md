# Cintara Phase-1 — Validator + LLM + Bridge (Shareable Pack)

This package runs a **Cintara testnet validator node** side-by-side with a **CPU LLM (llama.cpp)** and a small **FastAPI bridge** that turns API calls into LLM prompts and returns **JSON**.

---

## Contents

- `docker-compose.yml` — Full stack (node + llama + bridge + patcher)
- `Dockerfile` — Node image with prebuilt `cintarad` baked in
- `entrypoint.sh` — Init vs. start controller
- `.env.example` — Copy to `.env` and fill `PUBLIC_IP`, etc.
- `bridge/` — FastAPI app with JSON grammar-constrained output
- `scripts/` — Patcher + cleanup scripts
- `models/` — Put your `.gguf` model here
- `data/` — Chain home persists here

---

## 1. EC2 Setup

- **AMI:** Ubuntu Server 22.04 LTS (x86_64)
- **Instance type:**
  - `c6i.2xlarge` (8 vCPU / 16 GB) recommended
  - `c6i.xlarge` possible, slower
  - `c6i.4xlarge` faster
- **Storage:** 150 GB gp3
- **Inbound rules:**
  - TCP 26656 (P2P)
  - TCP 26657 (RPC)
  - TCP 8080 (Bridge, optional)
  - TCP 22 (SSH if needed)

---

## 2. Install Docker + Compose

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg unzip jq
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker
```

---

## 3. Project Setup

```bash
unzip cintara-phase1-shareable.zip -d ~/cintara-phase1
cd ~/cintara-phase1
cp .env.example .env
nano .env   # set PUBLIC_IP=<your EC2 public IP/DNS>
```

---

## 4. Download a Model (GGUF)

```bash
cd models
wget https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf -O mistral-7b-instruct.Q4_K_M.gguf
cd ..
```
Ensure `.env` → `MODEL_FILE` matches your filename.

---

## 5. Build, Init, Patch, Run

```bash
docker compose build
docker compose run --rm -e RUN_MODE=init cintara-node
docker compose run --rm config-patcher
docker compose up -d
```

---

## 6. Verify

```bash
curl -s http://localhost:26657/status | jq .sync_info.catching_up
curl -s http://localhost:8080/health
curl -s -X POST http://localhost:8080/analyze \
  -H "content-type: application/json" \
  -d '{"transaction":{"hash":"0xabc","amount":"123"}}' | jq .
```

From your laptop:
```bash
curl -s http://<PUBLIC_IP>:26657/status | jq .
```

---

## 7. Cleanup

```bash
./scripts/cleanup.sh
```

---

## 8. Autostart with systemd (optional)

Create a systemd service:

```bash
sudo tee /etc/systemd/system/cintara-compose.service >/dev/null <<'EOF'
[Unit]
Description=Cintara Phase-1 Compose
After=network-online.target docker.service
Wants=network-online.target

[Service]
Type=oneshot
WorkingDirectory=/home/ubuntu/cintara-phase1
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now cintara-compose
```

---
