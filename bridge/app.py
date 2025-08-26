from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import os, requests, json, time
LLAMA_SERVER_URL = os.getenv("LLAMA_SERVER_URL", "http://llama:8000")
app = FastAPI()
@app.get("/health")
def health():
    try:
        r = requests.get(f"{LLAMA_SERVER_URL}/health", timeout=1.5)
        return {"status": "ok"} if r.status_code == 200 else {"status":"degraded"}
    except Exception:
        return {"status":"down"}
@app.post("/analyze")
async def analyze(req: Request):
    payload = await req.json()
    tx = payload.get("transaction", {})
    prompt = f"Analyze transaction: {json.dumps(tx)} and return JSON with risks/explanation."
    t0=time.time()
    r = requests.post(f"{LLAMA_SERVER_URL}/completion",json={"prompt":prompt,"n_predict":120,"temperature":0.0},timeout=60)
    data=r.json(); content=data.get("content","")
    latency_ms=int((time.time()-t0)*1000)
    return JSONResponse({"analysis":content,"latency_ms":latency_ms})