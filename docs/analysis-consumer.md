# Phân tích yêu cầu — vai Consumer

- Cặp đàm phán: Pair 01 — Camera Stream A2 -> AI Vision A4
- Product: Product A — Smart Campus Operations Platform
- Consumer service: Camera Stream A2
- Provider service: AI Vision A4
- Người viết: Nguyễn Đức Anh — MSV 1771020050 — Nhóm 4
- Ngày: 2026-05-18

---

## 1. Resource Consumer cần nhận/gửi

| Resource | Consumer dùng để làm gì? | Field bắt buộc với Consumer | Field có thể tùy chọn |
|---|---|---|---|
| `DetectionRequest` | Gửi frame khi phát hiện motion | `cameraId`, `capturedAt`, `motionEventId`, `source` | `requestedModelVersion`, `callbackUrl` |
| `DetectionResult` | Nhận object, confidence và risk để chuyển tiếp khi bất thường | `detectionId`, `objects`, `overallConfidence`, `riskLevel`, `modelVersion` | `riskReason`, `completedAt`, `trackId` |
| `VisionModelInfo` | Biết model version, loại object hỗ trợ và giới hạn ảnh | `modelVersion`, `supportedObjectTypes`, `maxImageBytes`, `maxProcessingMs` | Không có |
| `Problem` | Xử lý lỗi rõ ràng khi gửi frame thất bại | `status`, `detail`, `correlationId` | `errors` |

---

## 2. API Consumer cần gọi

| Method | Path | Lúc nào gọi? | Kỳ vọng response |
|---|---|---|---|
| GET | `/health` | Trước khi gửi frame hoặc khi health check định kỳ | `status=ok` hoặc `degraded` |
| POST | `/vision/detect` | Ngay khi Camera Stream phát hiện motion | `DetectionResult` với `detectionId`, `objects`, `confidence`, `riskLevel` hoặc `202` để polling |
| GET | `/vision/detections/{detectionId}` | Khi detect đang pending hoặc cần xem lại kết quả | Một `DetectionResult` |
| GET | `/vision/models/info` | Khi service khởi động hoặc cần kiểm tra model hiện tại | `VisionModelInfo` |
| GET | `/vision/detections/recent` | Sau mất mạng/retry để đối soát kết quả gần đây | `DetectionResultPage` |

---

## 3. Error case Consumer cần xử lý

| Status | Consumer hiểu là gì? | Consumer sẽ xử lý thế nào? |
|---:|---|---|
| 400 | Request sai schema hoặc thiếu field | Sửa payload/log lỗi, không retry tự động |
| 401 | Token thiếu hoặc hết hạn | Refresh/cấu hình lại token |
| 403 | Camera Stream không có quyền gọi AI Vision | Báo lỗi quyền service cho admin |
| 404 | Không tìm thấy `detectionId` khi polling | Dừng polling và ghi log đối soát |
| 409 | `Idempotency-Key` bị dùng lại với payload khác | Sinh key mới cho motion event mới, không gửi trùng event cũ |
| 413 | Frame vượt giới hạn kích thước | Giảm kích thước ảnh hoặc chỉ gửi metadata |
| 422 | Ảnh/source không xử lý được | Ghi nhận motion event lỗi và không chuyển cảnh báo |
| 500 | AI Vision lỗi nội bộ | Retry có backoff hoặc chuyển sang hàng đợi xử lý sau |

---

## 4. Giả định bổ sung

- Camera Stream có thể sinh `Idempotency-Key` ổn định theo `cameraId` và `motionEventId`.
- Camera Stream ưu tiên gửi `IMAGE_URL`; khi đường dẫn ảnh nội bộ không ổn định thì gửi `FRAME_METADATA`.
- Nếu `POST /vision/detect` trả `202`, Camera Stream sẽ polling bằng `GET /vision/detections/{detectionId}`.
- Chỉ kết quả `riskLevel=HIGH` hoặc `CRITICAL` mới được chuyển tiếp nhanh cho Core Business.

---

## 5. Câu hỏi cho Provider

1. AI Vision có cam kết xử lý đồng bộ dưới 800 ms cho frame 5 MB không?
2. Danh sách `DetectedObjectType` có thể mở rộng trong minor version không?
3. Khi model không chắc chắn, AI Vision trả `riskLevel=LOW` với confidence thấp hay trả `422`?

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
| Provider đổi model version | Kết quả detect thay đổi, khó audit | Response luôn có `modelVersion` |
| Response chậm | Camera Stream bị backlog frame | Cho phép `202` và polling |
| Sai định dạng source ảnh | Request bị 400/422 liên tục | Dùng schema `oneOf` + `discriminator` |
| Mất mạng sau khi gửi frame | Không biết detect đã được xử lý chưa | Dùng `Idempotency-Key` và `/vision/detections/recent` để đối soát |
