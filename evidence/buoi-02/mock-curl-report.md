# Prism Mock Curl Report

Ngày chạy: 2026-05-18

Prism mock server đã chạy tại `http://127.0.0.1:4010`.

Các request đã kiểm tra bằng `bash scripts/test_mock_with_curl.sh`:

| # | Request | Kết quả |
|---:|---|---|
| 1 | `GET /health` | `200 OK` |
| 2 | `POST /access/check` | `200 OK` |
| 3 | `GET /policies/access/pol_access_student_main_gate` | `200 OK` |
| 4 | `GET /decisions/dec_01HY5WR0W4F8M9CBR1Q2D3Z4AA` | `200 OK` |
| 5 | `GET /decisions/recent?gateId=GATE-A-01&limit=20` | `200 OK` |

Ghi chú: File này là bằng chứng dạng text bổ sung. Nếu rubric yêu cầu đúng ảnh, cần chụp lại Terminal/PowerShell và lưu PNG trong `evidence/buoi-02/mock-screenshots/`.
