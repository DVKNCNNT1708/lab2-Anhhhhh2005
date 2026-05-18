# Versioning Policy

API hiện tại: `1.0.0`

Hợp đồng này áp dụng cho Pair 01 — Camera Stream A2 -> AI Vision A4 trong Product A.
Người thực hiện: Nguyễn Đức Anh — MSV 1771020050 — Nhóm 4.

API dùng Semantic Versioning cho `info.version` trong `openapi.yaml`.

## Backward-compatible change

Các thay đổi sau được phép trong minor hoặc patch version:

- Thêm optional field mới vào response.
- Thêm `DetectedObjectType` mới nếu Consumer có fallback xử lý object chưa biết.
- Thêm endpoint mới không làm đổi endpoint hiện tại.
- Cập nhật mô tả, example, `summary`, hoặc tài liệu mà không đổi schema.
- Tăng giới hạn `maxImageBytes` hoặc giảm `maxProcessingMs` theo hướng có lợi cho Consumer.

## Breaking change

Các thay đổi sau phải tăng major version:

- Xóa hoặc đổi tên field đang required.
- Đổi kiểu dữ liệu, format hoặc ý nghĩa của field hiện có.
- Xóa enum value đang dùng trong production.
- Đổi nghĩa của `riskLevel`, `overallConfidence`, hoặc `sourceType`.
- Đổi behavior của `Idempotency-Key`, response `202`, hoặc mã lỗi `409`.
- Thêm required field mới vào `DetectionRequest`.

## Deprecation

Field hoặc endpoint sẽ được đánh dấu deprecated ít nhất một phiên minor trước khi xóa.
Provider phải ghi rõ ngày dự kiến xóa và endpoint thay thế trong mô tả OpenAPI.

## Compatibility rule

Consumer phải bỏ qua optional field chưa biết và xử lý object type chưa biết bằng fallback an toàn.
Provider không được thêm required field vào request trong cùng major version.
