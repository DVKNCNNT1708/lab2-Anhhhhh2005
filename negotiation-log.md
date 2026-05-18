# Biên bản đàm phán hợp đồng API

- Cặp đàm phán: Pair 01 — Camera Stream A2 -> AI Vision A4
- Product: Product A — Smart Campus Operations Platform
- Provider: AI Vision A4
- Consumer: Camera Stream A2
- Phiên: v1.0
- Người viết: Nguyễn Đức Anh — MSV 1771020050 — Nhóm 4
- Ngày: 2026-05-18

---

## Issue #1

- Raised by: Consumer
- Endpoint: `POST /vision/detect`
- Concern: Camera Stream cần response nhanh gồm `detectionId`, objects, confidence và `riskLevel` để chuyển tiếp khi có bất thường.
- Proposal: Provider trả `200 DetectionResult` khi xử lý xong trong giới hạn thời gian, hoặc `202 DetectionAccepted` nếu cần polling.
- Resolution: Accepted
- Rationale: Luồng motion cần nhanh, nhưng vẫn cần fallback khi inference lâu hơn dự kiến.
- Impact: `POST /vision/detect` có response `200` và `202`.

---

## Issue #2

- Raised by: Provider
- Endpoint: `POST /vision/detect`
- Concern: Ảnh gửi dạng multipart làm mock và validate phức tạp trong Lab 02.
- Proposal: Dùng JSON body, source ảnh là `IMAGE_URL` hoặc `FRAME_METADATA`.
- Resolution: Accepted
- Rationale: JSON contract dễ lint, dễ chạy Prism và vẫn mô tả được frame thực tế trong hệ thống nội bộ.
- Impact: Tạo `FrameSource` với `oneOf` + `discriminator` theo `sourceType`.

---

## Issue #3

- Raised by: Provider
- Endpoint: `POST /vision/detect`
- Concern: Retry do timeout có thể làm AI Vision xử lý trùng cùng một motion event.
- Proposal: Bắt buộc header `Idempotency-Key` cho mỗi frame/motion event.
- Resolution: Accepted
- Rationale: Provider có thể trả lại kết quả cũ khi retry hợp lệ hoặc trả `409` khi key bị dùng với payload khác.
- Impact: Thêm required header `Idempotency-Key` và response `409 Conflict`.

---

## Issue #4

- Raised by: Consumer
- Endpoint: `POST /vision/detect`
- Concern: Camera Stream cần biết giới hạn kích thước frame để tránh gửi payload quá lớn.
- Proposal: Model info công bố `maxImageBytes=5242880`; nếu vượt giới hạn trả `413 Payload Too Large`.
- Resolution: Accepted
- Rationale: Giới hạn rõ giúp Consumer resize hoặc chuyển sang metadata trước khi gọi API.
- Impact: Thêm `maxImageBytes` trong `VisionModelInfo` và response `413`.

---

## Issue #5

- Raised by: Consumer
- Endpoint: `GET /vision/detections/{detectionId}`
- Concern: Khi detect pending, Camera Stream cần polling kết quả bằng id ổn định.
- Proposal: `202` trả `detectionId` và `pollUrl`; endpoint GET trả `DetectionResult`.
- Resolution: Accepted
- Rationale: Tách xử lý realtime khỏi truy vấn trạng thái, giảm timeout giữa hai service.
- Impact: Thêm `DetectionAccepted` và chuẩn hóa `detectionId`.

---

## Issue #6

- Raised by: Provider
- Endpoint: All endpoints
- Concern: Lỗi cần thống nhất để Camera Stream xử lý nhất quán.
- Proposal: Tất cả lỗi 4xx/5xx trả `application/problem+json` theo schema `Problem`.
- Resolution: Accepted
- Rationale: Problem Details truyền được `status`, `detail`, `instance`, `correlationId` và lỗi field.
- Impact: Thêm `components.schemas.Problem` và các response lỗi dùng `$ref`.

---

## Issue #7

- Raised by: Consumer
- Endpoint: `GET /vision/models/info`
- Concern: Camera Stream cần biết model đang chạy để audit kết quả detection.
- Proposal: Provider trả `modelVersion`, danh sách object hỗ trợ và `maxProcessingMs`.
- Resolution: Accepted
- Rationale: Model metadata giúp Consumer kiểm tra compatibility và giải thích thay đổi kết quả theo thời gian.
- Impact: Thêm schema `VisionModelInfo`.

---

# Chốt hợp đồng v1.0

Provider sign-off: Nguyễn Đức Anh — A4 AI Vision — Nhóm 4  
Consumer sign-off: Đại diện A2 Camera Stream  
Witness (GV/TA): FIT4110 TA  
Date: 2026-05-18

---

## Ghi chú warning nếu Spectral còn cảnh báo

| Warning | Lý do chấp nhận tạm thời | Kế hoạch sửa |
|---|---|---|
| Không có | Không áp dụng | Duy trì `npm run lint` trước khi nộp |
