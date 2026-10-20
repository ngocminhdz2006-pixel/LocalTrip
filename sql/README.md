# Hướng dẫn khởi tạo Database — LocalTrip

Thư mục này chứa toàn bộ các script SQL cần thiết cho hệ sinh thái **LocalTripDB** (Microsoft SQL Server).

---

## 🚀 Cách 1: Thiết lập nhanh nhất (Khuyên dùng)

Chạy **DUY NHẤT** một file:
```sql
LocalTripDB_RESET.sql
```
* **Thao tác:** Mở file này trong SQL Server Management Studio (SSMS) và nhấn **Execute (F5)**.
* **Tác dụng:** File sẽ tự động khởi tạo database `LocalTripDB`, tạo toàn bộ bảng (Users, Trips, ItineraryItems, Places, Categories, Expenses, GroupFund, Passport, CheckIn, Dump...), tạo toàn bộ chỉ mục, ràng buộc khóa ngoại và nạp đầy đủ dữ liệu mẫu (Seed Data) chuẩn.

---

## 🛠️ Cách 2: Chạy theo thứ tự từng Migration (Nâng cấp tuần tự)

Nếu bạn muốn chạy từng file theo thứ tự phát triển:

1. `01_schema.sql` — Tạo cấu trúc các bảng cốt lõi (Users, Trips, Places, Categories, Preferences).
2. `02_seed_data.sql` — Nạp dữ liệu mẫu ban đầu.
3. `03_auth_role_migration.sql` — Phân quyền vai trò USER / ADMIN.
4. `04_auth_recovery.sql` — Bảng token đặt lại mật khẩu (PasswordResetTokens).
5. `05_admin_audit_log.sql` — Nhật ký kiểm toán thao tác quản trị (AdminAuditLogs).
6. `06_group_fund.sql` — Bảng quỹ nhóm và giao dịch quỹ (GroupFundContributions, GroupFundTransactions).
7. `06b_login_history.sql` — Nhật ký đăng nhập tài khoản (LoginLogs).
8. `07_more_places.sql` — Bổ sung các địa điểm ăn uống, vui chơi TP.HCM.
9. `08_place_regions.sql` — Phân chia khu vực địa phương (Quận 1, Thủ Đức...).
10. `09_fund_settlement_diagnostics.sql` — Hỗ trợ chẩn đoán và đồng bộ hóa chia tiền quỹ nhóm.
11. `10_seasonal_combos.sql` — Dữ liệu gói Combo gợi ý 4 mùa.
12. `11_dump_checkin_passport_badges.sql` — Mạng xã hội Dump, GPS Check-in và Huy hiệu Hộ chiếu.
13. `12_admin_combo_templates.sql` — Quản trị template Combo của ADMIN.
14. `13_itinerary_activity_lifecycle.sql` — Vòng đời trạng thái hoạt động lịch trình (UPCOMING, IN_PROGRESS, COMPLETED, CANCELLED).

---

## 📌 Tài khoản mẫu đăng nhập mặc định (Seed Account):
* **Admin:** `admin@localtrip.local` / Mật khẩu: `Admin@123`
* **User (Lan Anh):** `lananh@gmail.com` / Mật khẩu: `User@123`
* **User (Ngọc Minh):** `ngocminh@gmail.com` / Mật khẩu: `User@123`
