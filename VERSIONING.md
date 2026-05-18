# Versioning Policy

API hiện tại: `1.0.0`

Hợp đồng này dùng Semantic Versioning cho `info.version` trong `openapi.yaml`.

## Backward-compatible change

Các thay đổi sau được phép trong minor hoặc patch version:

- Thêm optional field mới vào response.
- Thêm enum value mới cho `reasonCode` nếu Consumer có fallback hiển thị lý do không xác định.
- Thêm endpoint mới không làm đổi endpoint hiện tại.
- Làm rõ `description`, `example`, hoặc tài liệu mà không đổi schema.

## Breaking change

Các thay đổi sau phải tăng major version:

- Xóa hoặc đổi tên field đang required.
- Đổi kiểu dữ liệu, format hoặc ý nghĩa của field hiện có.
- Xóa enum value đang dùng trong production.
- Đổi nghĩa của `expiresAt=null`.
- Đổi behavior của `Idempotency-Key` hoặc mã lỗi `409`.

## Deprecation

Field hoặc endpoint sẽ được đánh dấu deprecated ít nhất một phiên minor trước khi xóa.
Provider phải ghi rõ ngày dự kiến xóa và endpoint thay thế trong mô tả OpenAPI.

## Compatibility rule

Consumer phải bỏ qua optional field chưa biết và xử lý `reasonCode` chưa biết bằng fallback deny-safe.
Provider không được thêm required field vào request trong cùng major version.
