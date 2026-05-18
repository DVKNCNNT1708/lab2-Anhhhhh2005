$ErrorActionPreference = "Stop"

$BaseUrl = if ($env:BASE_URL) { $env:BASE_URL } else { "http://localhost:4010" }
$AuthHeader = "Authorization: Bearer test-token"
$CorrelationHeader = "X-Correlation-Id: corr-20260518-vision-0001"

Write-Host "[Lab02] Testing Prism mock server at $BaseUrl"
Write-Host ""

Write-Host "[1/5] Happy path: GET /health"
curl.exe -i "$BaseUrl/health"
Write-Host "`n---"

Write-Host "[2/5] Happy path: POST /vision/detect with IMAGE_URL"
$payload = '{
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
curl.exe -i -X POST "$BaseUrl/vision/detect" `
  -H $AuthHeader `
  -H $CorrelationHeader `
  -H "Idempotency-Key: idem-CAM-A2-001-20260518-0001" `
  -H "Content-Type: application/json" `
  -d $payload
Write-Host "`n---"

Write-Host "[3/5] Happy path: GET /vision/detections/{detectionId}"
curl.exe -i "$BaseUrl/vision/detections/det_01HY6AIVISION0000000001" -H $AuthHeader -H $CorrelationHeader
Write-Host "`n---"

Write-Host "[4/5] Happy path: GET /vision/models/info"
curl.exe -i "$BaseUrl/vision/models/info" -H $AuthHeader -H $CorrelationHeader
Write-Host "`n---"

Write-Host "[5/5] Happy path: GET /vision/detections/recent"
curl.exe -i "$BaseUrl/vision/detections/recent?cameraId=CAM-A2-001&limit=20" -H $AuthHeader -H $CorrelationHeader
Write-Host ""
