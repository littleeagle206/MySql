-- ===============================================================
-- DỰ ÁN: SMARTFACTORY - THIẾT KẾ LEAN INDEX CÂN BẰNG HIỆU NĂNG
-- File: smartfactory_reindex.sql
-- ===============================================================

CREATE DATABASE IF NOT EXISTS smartfactory_db;
USE smartfactory_db;

-- 1. TẠO CẤU TRÚC BẢNG SensorLogs
DROP TABLE IF EXISTS SensorLogs;

CREATE TABLE SensorLogs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sensor_id INT NOT NULL,
    recorded_at DATETIME NOT NULL,
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2),
    status VARCHAR(20) -- 'NORMAL', 'WARNING', 'CRITICAL'
);

-- ===============================================================
-- 2. TẠO "FAT INDEX" (HIỆN TRẠNG CŨ GÂY NGHẼN HỆ THỐNG)
-- ===============================================================
CREATE INDEX idx_fat_covering ON SensorLogs(sensor_id, recorded_at, temperature, humidity, status);

-- Kiểm tra dung lượng khi có Fat Index
SHOW TABLE STATUS LIKE 'SensorLogs';

-- Xem kế hoạch thực thi cũ (Có 'Using index' - Covering Index)
EXPLAIN SELECT temperature, humidity, status 
FROM SensorLogs 
WHERE sensor_id = 105 AND recorded_at >= '2026-06-20';

-- ===============================================================
-- 3. TÁI CẤU TRÚC: DROP FAT INDEX VÀ TẠO LEAN INDEX
-- ===============================================================

-- Gỡ bỏ Index cồng kềnh
ALTER TABLE SensorLogs DROP INDEX idx_fat_covering;

-- Tạo Lean Index chỉ chứa 2 cột phục vụ lọc và sắp xếp
CREATE INDEX idx_lean_search ON SensorLogs(sensor_id, recorded_at);

-- ===============================================================
-- 4. ĐỐI CHIẾU THỰC THI VÀ TÀI NGUYÊN SAU KHI TỐI ƯU
-- ===============================================================

-- Kiểm tra dung lượng sau tối ưu (Index_length giảm mạnh)
SHOW TABLE STATUS LIKE 'SensorLogs';

-- Phân tích kế hoạch thực thi mới:
-- - key nhận diện: idx_lean_search
-- - type vẫn giữ: range (truy vấn rất nhanh)
-- - Extra: Đã biến mất 'Using index' (chuyển sang đọc bảng gốc để lấy số đo)
EXPLAIN SELECT temperature, humidity, status 
FROM SensorLogs 
WHERE sensor_id = 105 AND recorded_at >= '2026-06-20';