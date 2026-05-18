# Phân tích yêu cầu — vai Provider

- Cặp đàm phán: Pair 10 — Access Gate -> Core Business
- Product: Smart Campus Operations Platform
- Provider service: Core Business
- Consumer service: Access Gate
- Người viết: Nhom Core Business
- Ngày: 2026-05-18

---

## 1. Resource chính

| Resource | Mô tả | Thuộc tính bắt buộc | Thuộc tính tùy chọn |
|---|---|---|---|
| `AccessCheckRequest` | Yêu cầu kiểm tra policy cho một lượt quẹt/scan tại cổng | `gateId`, `campusId`, `occurredAt`, `direction`, `subject`, `device` | `note` |
| `AccessDecision` | Kết quả cho phép hoặc từ chối mở cổng | `decisionId`, `allow`, `reasonCode`, `policyId`, `gateId`, `evaluatedAt`, `correlationId` | `expiresAt`, `subjectId` |
| `AccessPolicy` | Chính sách được dùng để ra quyết định | `policyId`, `name`, `status`, `priority`, `allowedDirections`, `allowedGateIds` | `validUntil` |
| `Problem` | Response lỗi theo Problem Details | `type`, `title`, `status`, `detail`, `instance`, `correlationId` | `errors` |

---

## 2. Action/API dự kiến

| Method | Path | Mục đích | Consumer gọi khi nào? |
|---|---|---|---|
| GET | `/health` | Kiểm tra Core Business sẵn sàng nhận request | Gate kiểm tra định kỳ hoặc trước ca vận hành |
| POST | `/access/check` | Ra quyết định allow/deny realtime | Mỗi lần thẻ/QR được quẹt tại cổng |
| GET | `/policies/access/{policyId}` | Lấy chi tiết policy đã áp dụng | Khi cần audit hoặc giải thích quyết định |
| GET | `/decisions/{decisionId}` | Lấy lại một quyết định đã phát sinh | Khi retry, reconciliation hoặc điều tra sự cố |
| GET | `/decisions/recent` | Liệt kê quyết định gần đây | Gate đồng bộ trạng thái sau mất kết nối ngắn |

---

## 3. Error case

| Status | Tình huống | Response body dự kiến |
|---:|---|---|
| 400 | Payload sai JSON/schema hoặc thiếu field bắt buộc | `Problem` |
| 401 | Thiếu hoặc sai Bearer token | `Problem` |
| 403 | Token hợp lệ nhưng service không có quyền gọi policy API | `Problem` |
| 404 | Không tìm thấy `policyId` hoặc `decisionId` | `Problem` |
| 409 | Trùng `Idempotency-Key` nhưng payload khác | `Problem` |
| 422 | Thẻ/QR đúng schema nhưng vi phạm rule nghiệp vụ không thể đánh giá | `Problem` |
| 500 | Core Business lỗi nội bộ hoặc policy engine không phản hồi | `Problem` |

---

## 4. Giả định bổ sung

- Core Business trả kết quả trong mục tiêu 500 ms cho `/access/check`.
- Access Gate bắt buộc gửi `Idempotency-Key` cho mỗi lượt quẹt/scan để retry không tạo quyết định trùng.
- Nếu Core Business không phản hồi, hành vi fail-open/fail-closed là cấu hình vận hành của Gate, không nằm trong response API.
- `expiresAt` có thể là `null` khi quyết định deny không được cache.

---

## 5. Câu hỏi cho Consumer

1. Gate cần cache quyết định allow trong bao lâu để tránh kẹt cổng khi mạng chập chờn?
2. Gate có gửi được `holderId` trong mọi trường hợp không, hay chỉ có `cardId`/`qrTokenHash`?
3. Gate muốn nhận reason code cố định bằng enum hay message tự do là đủ?

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
| Timeout khi kiểm tra policy | Gate không biết nên mở hay đóng | Chốt timeout 500 ms và Gate tự cấu hình fail-open/fail-closed |
| Retry tạo quyết định trùng | Audit sai số lượt ra/vào | Bắt buộc `Idempotency-Key` |
| Khác cách hiểu `allow=false` | Gate xử lý sai tình huống deny | Chuẩn hóa `reasonCode` enum |
| QR/thẻ có payload khác nhau | Provider parse sai subject | Dùng `oneOf` + `discriminator` theo `credentialType` |
