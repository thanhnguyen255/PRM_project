-- Cập nhật Deadline của các hoạt động mẫu (trong seed.sql) thành 7 ngày tới kể từ hôm nay
-- để chúng hiển thị trong mục "Hoạt động sắp đến"
UPDATE Activities 
SET Deadline = DATEADD(day, 7, GETDATE())
WHERE Deadline IS NULL OR Deadline <= GETDATE();

PRINT 'Đã cập nhật Deadline cho các hoạt động thành công!';
