# Hướng dẫn Khởi tạo & Kích hoạt Database — LocalTrip

Thư mục này chứa toàn bộ các tập lệnh SQL Server cho hệ sinh thái **LocalTripDB** (Microsoft SQL Server 2017+ / 2019 / 2022).

---

## 🎯 BẠN NÊN CHẠY SCRIPT NÀO?

Hệ thống cung cấp **2 lựa chọn linh hoạt** tùy vào trạng thái database hiện tại của bạn:

### 🌟 LỰA CHỌN 1: Cài mới / Reset sạch sẽ toàn bộ từ đầu (KHUYÊN DÙNG)
> **Phù hợp khi:** Bạn muốn đưa dự án về trạng thái chuẩn nhất, xóa sạch dữ liệu rác cũ và nạp đầy đủ 100% tính năng mới (Combo mẫu, Sở thích Profile, Vibe Match %, Check-in GPS, Huy hiệu Hộ chiếu, 47 địa điểm du lịch TP.HCM).

👉 Mở và chạy **DUY NHẤT 1 FILE**:
```sql
sql/LocalTripDB_RESET.sql
```
* **Cách chạy:** 
  1. Mở **SQL Server Management Studio (SSMS)** (hoặc VS Code mssql).
  2. Mở file `sql/LocalTripDB_RESET.sql`.
  3. Nhấn **Execute (F5)**.
* **Kết quả:** File sẽ tự động DROP và khởi tạo lại `LocalTripDB`, tạo trọn vẹn 31 bảng hệ thống, tạo mọi khóa ngoại, chỉ mục, và nạp sẵn toàn bộ seed data chuẩn nhất.

---

### 🔄 LỰA CHỌN 2: Giữ nguyên dữ liệu hiện tại (Chỉ chạy Migration nâng cấp V2)
> **Phù hợp khi:** Database `LocalTripDB` của bạn đã có sẵn các chuyến đi hoặc bài viết và bạn **không muốn xóa dữ liệu cũ**.

👉 Mở và chạy file:
```sql
sql/upgrade_v2_product.sql
```
* **Nội dung cập nhật:**
  1. Tạo bảng `UserPreferences` (Lưu sở thích du lịch tại Profile cá nhân).
  2. Thêm cột `applied_combo_id` vào bảng `Trips`.
  3. Tạo bảng `ComboReviews` (Đánh giá Combo sau khi chuyến đi hoàn thành).
  4. Tự động chuẩn hóa Quận/Huyện (`district_name`) cho 47 địa điểm du lịch.
  5. Tự động nạp mẫu sở thích cho các tài khoản test (`minh@localtrip.vn`, `lananh@localtrip.vn`, `thanh@localtrip.vn`) để hiển thị huy hiệu `Vibe Match %` ngay lập tức.
  6. Tự động nạp 1 gói Combo chuẩn tại Quận 1 (`1-Day Iconic Saigon: Cafe & Heritage`) kèm lịch trình mẫu 6 hoạt động và đánh giá 5 sao.

*(Ghi chú: Nếu database của bạn đã rất lâu chưa chạy các bản cập nhật mạng xã hội Dump & Combo Template, hãy chạy theo thứ tự: `11_dump_checkin_passport_badges.sql` ➡️ `12_admin_combo_templates.sql` ➡️ `13_itinerary_activity_lifecycle.sql` ➡️ `upgrade_v2_product.sql`).*

---

## 🔑 DANH SÁCH TÀI KHOẢN MẪU (TEST ACCOUNTS)

Mọi tài khoản mẫu đều dùng chung mật khẩu: **`123456`**

| Vai trò (Role) | Họ và tên | Email đăng nhập | Mật khẩu | Đặc điểm |
| :--- | :--- | :--- | :--- | :--- |
| **ADMIN** | Nguyễn Ngọc Minh | `minh@localtrip.vn` | `123456` | Toàn quyền Quản trị, duyệt bài, tạo Combo Template |
| **USER** | Nguyễn Lan Anh | `lananh@localtrip.vn` | `123456` | Có sở thích Ẩm thực & Cafe, đã kết bạn với Minh |
| **USER** | Thanh | `thanh@localtrip.vn` | `123456` | Chủ chuyến đi mẫu `LocalTrip Demo - TP.HCM` |
| **USER** | Hoàng Nam | `hoangnam@localtrip.vn` | `123456` | Yêu thích Giải trí & Tham quan |

---

## ⚙️ CẤU HÌNH KẾT NỐI DATABASE (`DBContext.java`)

Theo mặc định, ứng dụng kết nối tới:
- **Server:** `localhost:1433`
- **Database:** `LocalTripDB`
- **User:** `sa`
- **Password:** `12345`

### Tùy biến qua biến môi trường (Environment Variables)
Nếu bạn deploy Cloud (Azure / AWS / Render) hoặc máy bạn dùng mật khẩu `sa` khác, bạn có thể thiết lập các biến môi trường sau mà không cần sửa code Java:
- `DB_SERVER` hoặc `DB_HOST`: Tên server / IP (Mặc định: `localhost`)
- `DB_PORT`: Cổng SQL Server (Mặc định: `1433`)
- `DB_NAME`: Tên database (Mặc định: `LocalTripDB`)
- `DB_USER`: Tên đăng nhập (Mặc định: `sa`)
- `DB_PASSWORD`: Mật khẩu (Mặc định: `12345`)
