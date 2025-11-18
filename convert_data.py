import os
import csv
import h5py
import time

# --- CẤU HÌNH ---
# Thay đường dẫn này bằng thư mục chứa dataset bạn đã giải nén
ROOT_DIR = r'C:\Users\Administrator\Downloads\MillionSongSubset'
OUTPUT_FILE = 'real_songs_data.csv'

def extract_data_to_csv():
    print("Dang quet toan bo thu muc va trich xuat du lieu...")
    start_time = time.time()
    count = 0
    
    with open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        # Tạo Header cho file CSV
        writer.writerow(['song_id', 'title', 'artist_id', 'artist_name', 'year', 'duration', 'tempo', 'loudness'])

        # Duyệt qua tất cả thư mục con
        for root, dirs, files in os.walk(ROOT_DIR):
            for file in files:
                if file.endswith('.h5'):
                    file_path = os.path.join(root, file)
                    try:
                        with h5py.File(file_path, 'r') as f:
                            # Lấy các trường dữ liệu cần thiết
                            # Lưu ý: HDF5 trả về byte string, cần decode utf-8
                            metadata = f['/metadata/songs'][0]
                            musicbrainz = f['/musicbrainz/songs'][0]
                            analysis = f['/analysis/songs'][0]

                            title = metadata['title'].decode('utf-8')
                            artist_name = metadata['artist_name'].decode('utf-8')
                            artist_id = metadata['artist_id'].decode('utf-8')
                            song_id = metadata['song_id'].decode('utf-8')
                            
                            # Số liệu
                            year = musicbrainz['year']
                            duration = analysis['duration']
                            tempo = analysis['tempo']
                            loudness = analysis['loudness']

                            # Ghi một dòng vào CSV
                            writer.writerow([song_id, title, artist_id, artist_name, year, duration, tempo, loudness])
                            
                            count += 1
                            if count % 1000 == 0:
                                print(f"Da xu ly {count} bai hat...")
                                
                    except Exception as e:
                        print(f"Loi file {file}: {e}")

    print(f"\n--- HOAN THANH ---")
    print(f"Tong so bai hat: {count}")
    print(f"File CSV da tao: {OUTPUT_FILE}")
    print(f"Thoi gian chay: {time.time() - start_time:.2f} giay")

if __name__ == "__main__":
    # Đảm bảo bạn sửa ROOT_DIR trỏ đúng đến thư mục data thật
    if os.path.exists(ROOT_DIR):
        extract_data_to_csv()
    else:
        print(f"Khong tim thay thu muc: {ROOT_DIR}. Hay kiem tra lai duong dan.")