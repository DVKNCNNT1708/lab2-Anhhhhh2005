# Phân tích yêu cầu — vai Provider

- Cặp đàm phán: Pair 01 — Camera Stream A2 -> AI Vision A4
- Product: Product A — Smart Campus Operations Platform
- Provider service: AI Vision A4
- Consumer service: Camera Stream A2
- Người viết: Nguyễn Đức Anh — MSV 1771020050 — Nhóm 4
- Ngày: 2026-05-18

---

## 1. Resource chính

| Resource | Mô tả | Thuộc tính bắt buộc | Thuộc tính tùy chọn |
|---|---|---|---|
| `DetectionRequest` | Yêu cầu phân tích một frame khi Camera Stream phát hiện motion | `cameraId`, `campusId`, `capturedAt`, `motionEventId`, `source` | `requestedModelVersion`, `callbackUrl` |
| `FrameSource` | Nguồn ảnh gửi sang AI Vision | `sourceType` và field theo từng loại source | Không có |
| `DetectionResult` | Kết quả detect object trả về cho Camera Stream | `detectionId`, `objects`, `overallConfidence`, `riskLevel`, `modelVersion`, `createdAt` | `riskReason`, `completedAt`, `trackId` |
| `VisionModelInfo` | Thông tin model AI đang hoạt động | `modelVersion`, `supportedSourceTypes`, `supportedObjectTypes`, `maxImageBytes`, `maxProcessingMs` | Không có |
| `Problem` | Response lỗi theo Problem Details | `type`, `title`, `status`, `detail`, `instance`, `correlationId` | `errors` |

---

## 2. Action/API dự kiến

| Method | Path | Mục đích | Consumer gọi khi nào? |
|---|---|---|---|
| GET | `/health` | Kiểm tra AI Vision còn sẵn sàng xử lý | Camera Stream kiểm tra định kỳ trước khi gửi frame |
| POST | `/vision/detect` | Gửi frame hoặc metadata để AI Vision detect object | Khi camera phát hiện motion |
| GET | `/vision/detections/{detectionId}` | Lấy kết quả detect theo id | Khi request được nhận `202 PENDING` hoặc cần audit |
| GET | `/vision/models/info` | Lấy model version và giới hạn xử lý | Khi Camera Stream khởi động hoặc cần kiểm tra compatibility |
| GET | `/vision/detections/recent` | Lấy danh sách detect gần đây | Khi Camera Stream cần đối soát sau retry/mất mạng ngắn |

---

## 3. Error case

| Status | Tình huống | Response body dự kiến |
|---:|---|---|
| 400 | Payload sai JSON/schema hoặc thiếu field bắt buộc | `Problem` |
| 401 | Thiếu hoặc sai Bearer token | `Problem` |
| 403 | Token hợp lệ nhưng Camera Stream không có quyền gọi AI Vision | `Problem` |
| 404 | Không tìm thấy `detectionId` | `Problem` |
| 409 | Trùng `Idempotency-Key` nhưng payload khác | `Problem` |
| 413 | Ảnh/frame vượt giới hạn kích thước đã đàm phán | `Problem` |
| 422 | Ảnh đúng schema nhưng không đọc được, checksum sai hoặc source hết hạn | `Problem` |
| 500 | AI Vision hoặc model inference lỗi nội bộ | `Problem` |

---

## 4. Giả định bổ sung

- Lab 02 dùng JSON body với `IMAGE_URL` hoặc `FRAME_METADATA`, không dùng multipart để hợp đồng dễ mock bằng Prism.
- AI Vision cố gắng trả kết quả đồng bộ `200`; nếu xử lý lâu sẽ trả `202` kèm `pollUrl`.
- Ảnh tối đa 5 MB, thời gian xử lý mục tiêu tối đa 800 ms cho một frame.
- `callbackUrl` có thể là `null`; khi `null`, Camera Stream tự polling bằng `detectionId`.
- `riskReason`, `completedAt`, `trackId` có thể là `null` theo OpenAPI 3.1 union type.

---

## 5. Câu hỏi cho Consumer

1. Camera Stream muốn gửi ảnh bằng URL hay chỉ gửi metadata trỏ đến object storage?
2. `motionEventId` có ổn định qua retry để AI Vision chống xử lý lặp không?
3. Camera Stream cần threshold `riskLevel` nào để chuyển tiếp cảnh báo cho Core Business?

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
| Frame quá lớn | Tăng latency hoặc inference timeout | Chốt `maxImageBytes=5242880` và trả `413` khi vượt giới hạn |
| Retry tạo detect trùng | Core Business nhận nhiều cảnh báo cho cùng motion event | Bắt buộc `Idempotency-Key` |
| Consumer và Provider hiểu khác `riskLevel` | Cảnh báo bị bỏ sót hoặc quá nhiều false positive | Chuẩn hóa enum `LOW`, `MEDIUM`, `HIGH`, `CRITICAL` |
| Nguồn ảnh có 2 dạng khác nhau | Provider parse sai payload | Dùng `oneOf` + `discriminator` theo `sourceType` |
