# LocalTrip – Dump, Check-in, Travel Passport và Huy hiệu

## 1. Những gì đã thêm

- **Dump**: bảng tin; tạo bài viết có cảm nhận, tối đa 5 ảnh (JPG/PNG/WEBP, 5 MB/ảnh), gắn địa điểm/chuyến đi, đánh giá 1–5 sao không bắt buộc, chọn `PUBLIC` hoặc `FRIENDS`; thích, bình luận, lưu bài, báo cáo và xóa bài của chính mình.
- **Bạn bè**: tìm tài khoản bằng tên/email; gửi lời mời; chấp nhận/từ chối. Chế độ `FRIENDS` chỉ cho chủ bài và bạn bè đã chấp nhận xem; kiểm tra quyền được thực hiện ở phía server, kể cả khi truy cập URL ảnh.
- **Check-in GPS**: lấy tọa độ từ trình duyệt theo thao tác của người dùng; máy chủ tự tính khoảng cách đến tọa độ lưu trong `Places`; chỉ chấp nhận trong bán kính 200 m; lưu thời gian, tọa độ xác minh, khoảng cách, ghi chú và ảnh tùy chọn; không cho cùng tài khoản tính một địa điểm nhiều lần.
- **Travel Passport**: nhật ký check-in, số địa điểm độc nhất, số lượt check-in, số chuyến đi có check-in, số check-in có ảnh và huy hiệu. Hộ chiếu mặc định riêng tư; chủ tài khoản có thể bật công khai.
- **Huy hiệu**: trao tự động sau check-in hợp lệ; các huy hiệu seed gồm 5 địa điểm, 5 check-in có ảnh tại các địa điểm khác nhau, và 10 địa điểm. Có thể thêm/sửa huy hiệu qua bảng `TravelBadges`.
- **Quản trị**: trang `/admin/dump-reports` để xem báo cáo Dump và đánh dấu đã xem/bỏ qua.

## 2. Cách cập nhật database

1. Sao lưu database `LocalTripDB` trước khi thay đổi.
2. Mở SQL Server Management Studio và chọn database `LocalTripDB`.
3. Mở, kiểm tra và chạy file `sql/11_dump_checkin_passport_badges.sql`.
4. Không chạy file này trên database khác. Script có kiểm tra `OBJECT_ID` để không tạo lại các bảng đã tồn tại.
5. Đảm bảo các địa điểm cần check-in có `Places.latitude` và `Places.longitude`; quản trị viên có thể cập nhật tọa độ trong trang quản lý địa điểm.

## 3. Cách mở tính năng

- Dump: `/dump`
- Tìm/kết bạn: `/dump/friends`
- Check-in: mở `/places`, vào chi tiết địa điểm có tọa độ và nhấn **Check-in tại đây**
- Hộ chiếu và huy hiệu: `/passport`
- Báo cáo Dump (ADMIN): `/admin/dump-reports`

## 4. Lưu trữ ảnh

Ảnh không lưu trực tiếp trong thư mục web công khai. Ứng dụng lưu tại `${catalina.base}/LocalTripUploads/dump`; nếu chạy ngoài Tomcat, thư mục dự phòng là `${java.io.tmpdir}/LocalTripUploads/dump`. Tài khoản chạy Tomcat phải có quyền tạo/đọc/ghi thư mục này. Sao lưu thư mục này cùng database để giữ lại ảnh.

Ảnh Dump được phát qua `/dump/image` sau khi kiểm tra quyền xem bài. Ảnh check-in trong hộ chiếu chỉ được phát cho chủ tài khoản qua `/checkin/image`; nếu người dùng chủ động chia sẻ chính ảnh đó lên một bài Dump công khai, ảnh cũng có thể xem qua quyền truy cập của bài Dump.

## 5. Kiểm thử thủ công nên làm

1. Chạy migration SQL; kiểm tra 12 bảng mới: `Friendships`, `Posts`, `PostImages`, `PostLikes`, `PostComments`, `PostBookmarks`, `PostReports`, `CheckIns`, `CheckInImages`, `TravelPassportSettings`, `TravelBadges`, `UserBadges`.
2. Tạo bài Dump chỉ có ảnh; tạo bài chỉ có cảm nhận; tạo bài có đánh giá; kiểm tra mỗi bài có thể chọn công khai/bạn bè.
3. Đăng nhập tài khoản B chưa kết bạn với A; xác nhận B không thấy bài `FRIENDS` của A và không tải được URL ảnh riêng tư.
4. A gửi lời mời B, B chấp nhận; xác nhận B xem được bài `FRIENDS` của A.
5. Check-in khi ở trong 200 m của tọa độ địa điểm; thử ở xa hơn 200 m; thử địa điểm không có tọa độ; thử check-in cùng địa điểm lần hai.
6. Check-in kèm ảnh và kiểm tra hộ chiếu, tiến độ huy hiệu ảnh; kiểm tra huy hiệu tự trao khi đủ điều kiện.
7. Bật/tắt công khai hộ chiếu và thử mở `/passport?userId=ID` từ tài khoản khác.
8. Báo cáo một bài Dump, đăng nhập ADMIN và kiểm tra `/admin/dump-reports`.

## 6. Ghi chú

- GPS trình duyệt phụ thuộc quyền vị trí và tín hiệu thiết bị; tọa độ client có thể bị giả mạo, vì vậy đây là xác minh gần địa điểm ở mức ứng dụng, không phải bằng chứng chống gian lận tuyệt đối.
- Bán kính hiện đặt là 200 m; có thể điều chỉnh trong `TravelFeatureDAO` sau khi kiểm thử thực tế.
- Huy hiệu `CATEGORY_PLACES` dựa trên tên/mã danh mục có chứa `tham quan`, `sightseeing` hoặc `SIGHT`; hãy thống nhất mã danh mục nếu muốn sử dụng loại huy hiệu này.
- Cần chạy migration SQL trước khi truy cập các trang mới. Mình đã kiểm tra biên dịch các file Java với API Servlet và JDBC driver đi kèm; môi trường này không kết nối được tới SQL Server/Tomcat của bạn nên chưa thể xác nhận chạy end-to-end.
