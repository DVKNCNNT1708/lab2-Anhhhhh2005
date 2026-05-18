# Biên bản đàm phán hợp đồng API

- Cặp đàm phán: Pair 10 — Access Gate -> Core Business
- Product: Smart Campus Operations Platform
- Provider: Core Business
- Consumer: Access Gate
- Phiên: v1.0
- Ngày: 2026-05-18

---

## Issue #1

- Raised by: Consumer
- Endpoint: `POST /access/check`
- Concern: Gate cần quyết định rất nhanh để không gây kẹt cổng.
- Proposal: Provider cam kết response trong mục tiêu 500 ms và response chỉ chứa dữ liệu cần thiết cho hành động mở/không mở.
- Resolution: Accepted
- Rationale: Contract phải tối ưu cho luồng realtime, còn dữ liệu audit chi tiết có thể lấy qua endpoint khác.
- Impact: `AccessDecision` gồm `allow`, `reasonCode`, `policyId`, `expiresAt`, `correlationId`.

---

## Issue #2

- Raised by: Provider
- Endpoint: `POST /access/check`
- Concern: Gate retry khi mạng chập chờn có thể tạo nhiều quyết định cho cùng một lượt quẹt.
- Proposal: Bắt buộc header `Idempotency-Key` cho mỗi giao dịch local tại cổng.
- Resolution: Accepted
- Rationale: Provider có thể phát hiện retry hợp lệ và trả lại quyết định cũ, hoặc trả 409 nếu key bị dùng với payload khác.
- Impact: Thêm required header `Idempotency-Key`, thêm response `409 Conflict`.

---

## Issue #3

- Raised by: Provider
- Endpoint: `POST /access/check`
- Concern: Thẻ vật lý và QR có cấu trúc dữ liệu khác nhau.
- Proposal: Dùng `oneOf` + `discriminator` theo `credentialType`.
- Resolution: Accepted
- Rationale: Schema rõ hơn, Consumer validate được trước khi gọi API, Provider tránh parse thủ công.
- Impact: Tạo `AccessSubject`, `CardCredentialSubject`, `QrCredentialSubject`.

---

## Issue #4

- Raised by: Consumer
- Endpoint: `POST /access/check`
- Concern: Gate cần biết quyết định có được cache tạm hay không.
- Proposal: Dùng `expiresAt`; giá trị `null` nghĩa là không cache quyết định.
- Resolution: Accepted
- Rationale: OpenAPI 3.1 hỗ trợ union type với `null`; tránh dùng `nullable: true`.
- Impact: `expiresAt` khai báo `type: [string, 'null']`.

---

## Issue #5

- Raised by: Consumer
- Endpoint: `GET /policies/access/{policyId}`
- Concern: Nhân viên trực cần giải thích vì sao một lượt quẹt bị từ chối.
- Proposal: Cho phép Gate lấy chi tiết policy bằng `policyId` trả về trong decision.
- Resolution: Accepted
- Rationale: Tách luồng realtime khỏi luồng audit, không làm nặng `/access/check`.
- Impact: Thêm endpoint `GET /policies/access/{policyId}`.

---

## Issue #6

- Raised by: Provider
- Endpoint: All endpoints
- Concern: Lỗi cần thống nhất để Consumer xử lý nhất quán.
- Proposal: Tất cả lỗi 4xx/5xx trả `application/problem+json` theo schema `Problem`.
- Resolution: Accepted
- Rationale: Problem Details giúp truyền `status`, `detail`, `instance`, `correlationId` nhất quán.
- Impact: Thêm `components.schemas.Problem` và response dùng `$ref`.

---

## Issue #7

- Raised by: Consumer
- Endpoint: `GET /decisions/recent`
- Concern: Sau khi mất kết nối, Gate cần đối soát các quyết định gần đây.
- Proposal: Thêm endpoint danh sách có cursor pagination và filter `gateId`.
- Resolution: Modified
- Rationale: Provider đồng ý cung cấp danh sách gần đây nhưng giới hạn `limit <= 100` để bảo vệ hệ thống.
- Impact: Thêm `AccessDecisionPage`, `cursor`, `limit`, `gateId`.

---

# Chốt hợp đồng v1.0

Provider sign-off: Core Business representative  
Consumer sign-off: Access Gate representative  
Witness (GV/TA): FIT4110 TA  
Date: 2026-05-18

---

## Ghi chú warning nếu Spectral còn cảnh báo

| Warning | Lý do chấp nhận tạm thời | Kế hoạch sửa |
|---|---|---|
| Không có | Không áp dụng | Duy trì `npm run lint` trước khi nộp |
