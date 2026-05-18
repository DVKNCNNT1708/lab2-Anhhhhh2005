# Phân tích yêu cầu — vai Consumer

- Cặp đàm phán: Pair 10 — Access Gate -> Core Business
- Product: Smart Campus Operations Platform
- Consumer service: Access Gate
- Provider service: Core Business
- Người viết: Nhom Access Gate
- Ngày: 2026-05-18

---

## 1. Resource Consumer cần nhận/gửi

| Resource | Consumer dùng để làm gì? | Field bắt buộc với Consumer | Field có thể tùy chọn |
|---|---|---|---|
| `AccessCheckRequest` | Gửi thông tin lượt quẹt/scan sang Core Business | `gateId`, `occurredAt`, `direction`, `subject`, `device` | `note`, `holderId` |
| `AccessDecision` | Quyết định mở/không mở cổng | `allow`, `reasonCode`, `policyId`, `expiresAt`, `correlationId` | `reasonMessage`, `subjectId` |
| `AccessPolicy` | Hiển thị/audit policy áp dụng cho quyết định | `policyId`, `status`, `allowedGateIds`, `allowedDirections` | `validUntil` |
| `Problem` | Xử lý lỗi rõ ràng khi request thất bại | `status`, `detail`, `correlationId` | `errors` |

---

## 2. API Consumer cần gọi

| Method | Path | Lúc nào gọi? | Kỳ vọng response |
|---|---|---|---|
| GET | `/health` | Trước ca vận hành hoặc khi health check định kỳ | `status=ok` hoặc `degraded` |
| POST | `/access/check` | Ngay khi người dùng quẹt thẻ hoặc scan QR | `AccessDecision` có `allow`, `reasonCode`, `expiresAt` |
| GET | `/policies/access/{policyId}` | Khi nhân viên cần giải thích vì sao cổng deny/allow | Chi tiết `AccessPolicy` |
| GET | `/decisions/{decisionId}` | Khi Gate retry hoặc cần đối soát quyết định đã nhận | Một `AccessDecision` |
| GET | `/decisions/recent` | Sau khi Gate mất kết nối và cần đồng bộ lại | Trang danh sách `AccessDecisionPage` |

---

## 3. Error case Consumer cần xử lý

| Status | Consumer hiểu là gì? | Consumer sẽ xử lý thế nào? |
|---:|---|---|
| 400 | Gate gửi thiếu/sai field | Log payload, không retry tự động |
| 401 | Token thiếu hoặc hết hạn | Refresh token hoặc báo cấu hình sai |
| 403 | Gate không có quyền gọi API | Báo lỗi quyền vận hành cho admin |
| 404 | Không tìm thấy decision/policy khi audit | Hiển thị không tồn tại và ghi log |
| 409 | `Idempotency-Key` bị dùng lại với payload khác | Tạo key mới cho giao dịch mới, không mở cổng theo response lỗi |
| 422 | Credential hợp lệ về schema nhưng không thể đánh giá nghiệp vụ | Hiển thị lý do deny hoặc chuyển nhân viên trực |
| 500 | Core Business lỗi | Áp dụng cấu hình fail-open/fail-closed của Gate |

---

## 4. Giả định bổ sung

- Access Gate có thể sinh `Idempotency-Key` ổn định theo gate, timestamp và mã giao dịch local.
- Gate cần response đủ nhanh để người dùng không phải quẹt lại nhiều lần.
- Với QR, Gate chỉ gửi hash token, không gửi token gốc để giảm rủi ro lộ thông tin.
- Gate lưu `decisionId` để đối soát sau khi mất mạng hoặc restart.

---

## 5. Câu hỏi cho Provider

1. SLA timeout chính thức của `/access/check` là bao nhiêu ms?
2. `expiresAt=null` có luôn đồng nghĩa quyết định không được cache không?
3. Danh sách `reasonCode` có được mở rộng trong minor version không?

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
| Provider đổi enum `reasonCode` | Gate hiển thị sai hoặc không xử lý được | Ghi versioning rule và dùng fallback unknown reason |
| Response chậm | Người dùng bị kẹt tại cổng | Chốt timeout, đo latency trong môi trường test |
| Sai định dạng credential | Request bị 400 liên tục | Dùng schema `oneOf` + `discriminator` để validate sớm |
| Mất mạng sau khi Core đã ra quyết định | Gate không biết giao dịch đã được ghi nhận | Dùng `Idempotency-Key` và `/decisions/{decisionId}` để đối soát |
