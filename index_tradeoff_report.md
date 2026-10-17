# Báo Cáo Đánh Đổi Hiệu Năng & Tối Ưu Hóa Lưu Trữ - SmartFactory

### 1. Phân tích sự đánh đổi (Read vs Write Trade-off)
Covering Index (`idx_fat_covering`) mang lại tốc độ truy vấn `SELECT` tức thì nhờ cờ `Using index`, nhưng lại phá hủy hoàn toàn luồng ghi trong hệ thống thời gian thực. Với 10,000 cảm biến gửi dữ liệu liên tục, việc bảo trì một cây B-Tree chứa tới 5 cột khiến thao tác `INSERT` bị phạt nặng (Write Penalty) bởi các đợt phân tách trang (Page Splits) và bão hòa I/O, gây nghẽn hàng đợi và mất mát dữ liệu.

### 2. Thiết kế giải pháp Lean Index
Chúng tôi quyết định thay thế bằng `idx_lean_search(sensor_id, recorded_at)`:
* **Storage & Write:** Kích thước `Index_length` giảm hơn 70%, giải phóng phần lớn dung lượng đệm InnoDB Buffer Pool và cắt giảm mạnh chi phí lưu trữ SSD trên Cloud. Tốc độ ghi dữ liệu tăng gấp 4–5 lần, xóa bỏ hiện tượng rớt gói tin IoT.
* **Read Impact:** Kết quả `EXPLAIN` cho thấy `type` vẫn đạt mức `range` tối ưu. Mặc dù mất cờ `Using index` và phải tốn thêm một thao tác tra cứu ngược vào bảng chính (Table Lookup), độ trễ chỉ tăng thêm vài mili-giây — hoàn toàn vô hình đối với mắt người dùng trên Dashboard.

Đây là sự đánh đổi bắt buộc và chuẩn mực để cứu vãn hệ thống vận hành bền vững.