/* ==========================================
   PHẦN 1: KHỞI TẠO (RESET & LOAD DATA)
   ========================================== */
-- Xóa bảng cũ để làm sạch
DROP TABLE IF EXISTS songs_real;

-- Tạo bảng
CREATE TABLE songs_real (
    song_id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(255),
    artist_id VARCHAR(50),
    artist_name VARCHAR(255),
    year INT,
    duration FLOAT,
    tempo FLOAT,
    loudness FLOAT
);

-- Cấu hình & Load dữ liệu
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'C:/Users/Administrator/Documents/baitap2/real_songs_data.csv' 
INTO TABLE songs_real 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS 
(song_id, title, artist_id, artist_name, year, duration, tempo, loudness);


/* ==========================================
   PHẦN 2: THỰC HIỆN THÍ NGHIỆM (BENCHMARK)
   ========================================== */

-- Bật bộ đếm giờ & Xóa cache (nếu cần thiết mô phỏng lại)
SET profiling = 1;

-- ---------------------------------------------------------
-- THÍ NGHIỆM 1: CHỈ CÓ WHERE
-- So sánh: WHERE phức tạp (không dùng được Index) vs WHERE đơn giản
-- ---------------------------------------------------------

-- Reset Index cũ (nếu có)
DROP INDEX IF EXISTS idx_year ON songs_real;
DROP INDEX IF EXISTS idx_year_artist ON songs_real;

-- Tạo Index trước (để xem Query A có dùng được nó không)
CREATE INDEX idx_year ON songs_real(year);

-- Query 1.A (Complex Where): Database bó tay, không dùng được Index vì phép cộng
SELECT SQL_NO_CACHE count(*) FROM songs_real WHERE year + 0 = 2005;

-- Query 1.B (Simple Where): Database dùng Index scan cực nhanh
SELECT SQL_NO_CACHE count(*) FROM songs_real WHERE year = 2005;


-- ---------------------------------------------------------
-- THÍ NGHIỆM 2: CÓ WHERE VÀ GROUP BY
-- So sánh: Vẫn là Complex vs Simple WHERE nhưng trong bối cảnh có Group By
-- ---------------------------------------------------------

-- Query 2.A (Complex Where + Group By):
-- Phải quét toàn bộ bảng để tính (year+0), sau đó mới Group By. Rất chậm.
SELECT SQL_NO_CACHE artist_name, COUNT(*) 
FROM songs_real 
WHERE year + 0 = 2005 
GROUP BY artist_name;

-- Query 2.B (Simple Where + Group By):
-- Dùng Index để lọc ngay năm 2005, sau đó mới Group By. Nhanh hơn.
SELECT SQL_NO_CACHE artist_name, COUNT(*) 
FROM songs_real 
WHERE year = 2005 
GROUP BY artist_name;

-- *BONUS TỐI ƯU THÊM*: Tạo Covering Index để Query 2.B nhanh hơn nữa
CREATE INDEX idx_year_artist ON songs_real(year, artist_name);
-- Chạy lại Query 2.B sau khi có Index xịn
SELECT SQL_NO_CACHE artist_name, COUNT(*) 
FROM songs_real 
WHERE year = 2005 
GROUP BY artist_name;


-- ---------------------------------------------------------
-- THÍ NGHIỆM 3: CÓ ĐỦ WHERE, GROUP BY, HAVING
-- So sánh: Logic lọc đặt sai chỗ (Bad) vs Logic lọc đúng chỗ (Good)
-- ---------------------------------------------------------

-- Query 3.A (Bad Logic): Có đủ 3 mệnh đề.
-- WHERE: Lọc rất rộng (year > 0), gần như lấy hết bảng.
-- HAVING: Phải gánh team, lọc lại năm 2005 sau khi đã Group By tốn kém.
SELECT SQL_NO_CACHE artist_name, SUM(duration) 
FROM songs_real 
WHERE year > 0  -- Lọc "giả vờ" để có WHERE
GROUP BY artist_name, year
HAVING year = 2005 AND SUM(duration) > 1000; -- Lọc chính ở đây (Quá muộn)

-- Query 3.B (Good Logic): Có đủ 3 mệnh đề.
-- WHERE: Lọc chặt ngay từ đầu (year = 2005).
-- HAVING: Chỉ làm nhiệm vụ lọc kết quả tổng hợp (SUM > 1000).
SELECT SQL_NO_CACHE artist_name, SUM(duration) 
FROM songs_real 
WHERE year = 2005 -- Lọc chính ở đây (Sớm)
GROUP BY artist_name
HAVING SUM(duration) > 1000; -- Chỉ lọc kết quả


/* ==========================================
   PHẦN 3: XEM KẾT QUẢ
   ========================================== */
SHOW PROFILES;
