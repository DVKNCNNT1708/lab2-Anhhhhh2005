#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:4010}"
AUTH_HEADER="Authorization: Bearer test-token"
CORRELATION_HEADER="X-Correlation-Id: corr-20260518-vision-0001"

echo "[Lab02] Testing Prism mock server at $BASE_URL"
echo

echo "[1/5] Happy path: GET /health"
curl -i "$BASE_URL/health"
echo "
---"

echo "[2/5] Happy path: POST /vision/detect with IMAGE_URL"
curl -i -X POST "$BASE_URL/vision/detect" \
  -H "$AUTH_HEADER" \
  -H "$CORRELATION_HEADER" \
  -H "Idempotency-Key: idem-CAM-A2-001-20260518-0001" \
  -H "Content-Type: application/json" \
  -d '{
    "cameraId": "CAM-A2-001",
    "campusId": "CAMPUS-HCM",
    "capturedAt": "2026-05-18T06:10:15Z",
    "motionEventId": "motion-20260518-0001",
    "source": {
      "sourceType": "IMAGE_URL",
      "imageUrl": "https://media.smart-campus.local/frames/CAM-A2-001/2026/05/18/frame-0001.jpg",
      "checksumSha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    },
    "requestedModelVersion": "vision-campus-v1.4",
    "callbackUrl": null
  }'
echo "
---"

echo "[3/5] Happy path: GET /vision/detections/{detectionId}"
curl -i "$BASE_URL/vision/detections/det_01HY6AIVISION0000000001" \
  -H "$AUTH_HEADER" \
  -H "$CORRELATION_HEADER"
echo "
---"

echo "[4/5] Happy path: GET /vision/models/info"
curl -i "$BASE_URL/vision/models/info" \
  -H "$AUTH_HEADER" \
  -H "$CORRELATION_HEADER"
echo "
---"

echo "[5/5] Happy path: GET /vision/detections/recent"
curl -i "$BASE_URL/vision/detections/recent?cameraId=CAM-A2-001&limit=20" \
  -H "$AUTH_HEADER" \
  -H "$CORRELATION_HEADER"
echo
