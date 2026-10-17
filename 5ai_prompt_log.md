# Nhật Ký Tương Tác AI (AI Prompt Log) - Dự Án SmartFactory

### Phiên 1: Khái niệm Covering Index và Clustered vs Secondary Index
* **Prompt gửi AI:** "Trong cơ chế lưu trữ InnoDB của MySQL, sự khác biệt giữa Clustered Index và Secondary Index là gì? Tại sao Covering Index lại giúp câu lệnh SELECT chạy nhanh mà không cần chạm vào bảng dữ liệu gốc?"
* **AI phản hồi:** Clustered Index lưu trữ toàn bộ dữ liệu vật lý của hàng theo khóa chính (Primary Key). Secondary Index chỉ lưu các cột được đánh chỉ mục kèm con trỏ trỏ về khóa chính. Covering Index xảy ra khi tất cả các cột được yêu cầu trong SELECT đều nằm sẵn trên Secondary Index, giúp bỏ qua bước Bookmark Lookup (đọc bảng chính).
* **Quyết định áp dụng:** Hiểu rõ vì sao lập trình viên cũ dùng Fat Index, từ đó xác định cách bóc tách cột.

---

### Phiên 2: Tính toán dung lượng Byte (Storage Calculation) của Fat Index
* **Prompt gửi AI:** "Hãy tính toán dung lượng byte trên mỗi bản ghi của cây chỉ mục giữa Fat Index (sensor_id INT, recorded_at DATETIME, temperature DECIMAL(5,2), humidity DECIMAL(5,2), status VARCHAR(20)) so với Lean Index (sensor_id INT, recorded_at DATETIME) kèm Primary Key log_id BIGINT."
* **AI phản hồi:** 
  - Lean Index node: `sensor_id` (4B) + `recorded_at` (5B) + `log_id` (8B) ≈ 17 bytes/dòng.
  - Fat Index node: Thêm `temperature` (3B) + `humidity` (3B) + `status` (chuỗi UTF8MB4 trung bình 10–20B + 1B length prefix) ≈ 34–44 bytes/dòng (gấp ~2.5 lần).
* **Quyết định áp dụng:** Khẳng định việc loại bỏ 3 cột đo lường giúp tiết kiệm hơn 60–70% dung lượng cây chỉ mục.

---

### Phiên 3: Tác động của Write Penalty trong hệ thống IoT
* **Prompt gửi AI:** "Tại sao thao tác INSERT trong hệ thống thời gian thực (hàng chục nghìn bản ghi/giây) lại nhạy cảm với kích thước Secondary Index? Cơ chế Page Splits diễn ra như thế nào?"
* **AI phản hồi:** Khi node index quá lớn, mỗi trang dữ liệu (16KB Page) chứa được ít bản ghi hơn. Dữ liệu chèn vào liên tục làm các trang nhanh đầy, gây ra hiện tượng Page Splits và Random Write xuống ổ cứng, làm nghẽn Write I/O.
* **Quyết định áp dụng:** Đưa lập luận kỹ thuật này vào báo cáo giải trình cho Tech Lead và Ban Giám Đốc.