COMBO DIA DIEM - PHAN MO RONG

Tinh nang:
- Truy cap /combo?tripId=ID trong workspace cua chuyen di.
- Chon mot trong 3 phong cach: explore (Kham pha), healing (Chua lanh), vibrant (Soi dong).
- Chon ngay trong khoang start_date den end_date cua chuyen di.
- He thong xep hang dia diem dang hoat dong dua tren ten, danh muc, mo ta, loai trong/ngoai troi va rating.
- Nut "Them combo vao lich trinh" them toi da 3 dia diem vao ItineraryItems, theo cac khung 08:00-10:00, 11:00-13:00, 15:00-17:00.
- Bo qua dia diem da co trong ngay va khung gio bi trung. Khong can tao bang SQL moi.

File them:
- src/java/controller/ComboServlet.java
- web/WEB-INF/views/combo/combo.jsp

File cap nhat:
- web/WEB-INF/views/common/header.jsp (them link Combo dia diem)

Luu y:
- Chat luong goi y phu thuoc vao viec admin da dien day du ten, danh muc, mo ta, place_type va rating cua Places.
- Tinh nang khong tu dong goi y dia diem ngoai database va khong sua schema.


## Combo theo mùa (bản cập nhật)
- Giao diện Combo có 4 chủ đề: Mùa xuân, Mùa hạ, Mùa thu, Mùa đông.
- Chạy `sql/10_seasonal_combos.sql` trên SQL Server sau khi database `LocalTripDB` đã được tạo và seed cơ bản. Script bổ sung `Places.seasonal_tags` và địa điểm thực tế tại TP.HCM; có thể chạy lại an toàn theo tên địa điểm.
- Cột `seasonal_tags` giúp thuật toán ưu tiên địa điểm được gắn mùa tương ứng. Các địa điểm cũ chưa được gắn mùa mặc định `ALL` vẫn có thể xuất hiện nếu thiếu lựa chọn.
- Các mùa là chủ đề trải nghiệm; TP.HCM có hai mùa thời tiết chính là mùa mưa và mùa khô. Địa điểm và giờ hoạt động cần kiểm tra lại trước chuyến đi.
