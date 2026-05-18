# Prism Mock Curl Report

Ngày chạy: 2026-05-18

Người thực hiện: Nguyễn Đức Anh — MSV 1771020050 — Nhóm 4.

Contract: Pair 01 — Camera Stream A2 -> AI Vision A4.

Prism mock server đã chạy tại `http://127.0.0.1:4010`.

Các request đã kiểm tra bằng `bash scripts/test_mock_with_curl.sh`:

| # | Request | Kết quả |
|---:|---|---|
| 1 | `GET /health` | `200 OK` |
| 2 | `POST /vision/detect` | `200 OK` |
| 3 | `GET /vision/detections/det_01HY6AIVISION0000000001` | `200 OK` |
| 4 | `GET /vision/models/info` | `200 OK` |
| 5 | `GET /vision/detections/recent?cameraId=CAM-A2-001&limit=20` | `200 OK` |
