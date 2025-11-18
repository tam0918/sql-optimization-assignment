# Báo Cáo Bài Tập: Tối Ưu Hóa Truy Vấn SQL (SQL Optimization)

**Sinh viên:** Lường Văn Tâm

**Mã sinh viên:** 22001349  

**Dataset:** Million Song Dataset (Subset 10k songs)

## 1. Giới thiệu
Bài tập thực hiện thí nghiệm so sánh hiệu năng truy vấn SQL trong 3 trường hợp: WHERE, GROUP BY và HAVING trên tập dữ liệu thực tế gồm 10,000 bài hát.

## 2. Chuẩn bị dữ liệu
- **Nguồn dữ liệu:** Sử dụng Python để trích xuất dữ liệu từ file HDF5 gốc sang định dạng CSV.
- **File xử lý:** `convert_data.py`
- **Dữ liệu đầu ra:** `real_songs_data.csv` (~10,000 dòng).
- **Import:** Sử dụng lệnh `LOAD DATA LOCAL INFILE` để nạp vào MariaDB.

## 3. Kết quả Thí nghiệm (Benchmark)

Dưới đây là bảng so sánh thời gian thực thi (Execution Time) trước và sau khi tối ưu:

| Trường hợp        | Kỹ thuật Tối ưu          | Thời gian (Giây) | Hiệu quả             |
| :---------------- | :----------------------- | :--------------- | :------------------- |
| **TH1: WHERE**    | Không có Index           | 0.00078s         | Chậm (Full Scan)     |
|                   | **Có Index (B-Tree)**    | **0.00071s**     | **Nhanh hơn (~9%)**  |
| **TH2: GROUP BY** | Index đơn                | 0.00380s         | Chậm (Phải Lookup)   |
|                   | **Covering Index**       | **0.00275s**     | **Nhanh hơn (~28%)** |
| **TH3: HAVING**   | Filter Late (HAVING)     | 0.00051s         | Tốn tài nguyên       |
|                   | **Filter Early (WHERE)** | **0.00046s**     | **Nhanh hơn (~10%)** |

### Bằng chứng thực nghiệm (Screenshot)

![[result.png]]

## 4. Kết luận
Qua thí nghiệm trên dataset thực tế, ta thấy việc sử dụng **Index**, **Covering Index** và **lọc dữ liệu sớm (Filter Early)** giúp cải thiện tốc độ truy vấn đáng kể, đặc biệt là trong các thao tác gom nhóm (Group By).

---
*Hướng dẫn chạy:*
1. Cài đặt thư viện python: `pip install h5py`
2. Chạy file `convert_data.py` để tạo CSV.
3. Chạy file `script.sql` trong HeidiSQL/DBeaver để tái lập kết quả.
