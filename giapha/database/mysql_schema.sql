CREATE DATABASE IF NOT EXISTS gp_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gp_db;
CREATE TABLE app_storage (
    key_name VARCHAR(50) PRIMARY KEY NOT NULL,
    json_value JSON NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
INSERT INTO app_storage (key_name, json_value) VALUES
('gp_family', '{"members":[{"id":"id-A","name":"Ông Tổ","year":1880,"gender":"male"},{"id":"id-B1","name":"Nguyễn B1","year":1905,"gender":"male","parentId":"id-A"}]}'),
('gp_users', '[{"id":"u-admin","name":"admin","role":"admin"}]'),
('gp_activity', '[{"time":"2025-11-18 10:00:00","text":"Khởi tạo hệ thống Database thành công."}]');