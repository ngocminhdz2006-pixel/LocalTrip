# Checklist kiểm thử nền tảng: Quỹ nhóm và Settlement

> Thực hiện trên database test hoặc một Trip thử nghiệm. Không dùng script reset database. SQL chẩn đoán `sql/09_fund_settlement_diagnostics.sql` chỉ đọc dữ liệu.

## 1. Số dư quỹ

- [ ] Quỹ mới chưa có giao dịch: tổng đóng góp = 0, tổng chi từ quỹ = 0, số dư = 0.
- [ ] Owner ghi nhận đóng góp 100.000đ: tổng đóng góp tăng 100.000đ, số dư tăng đúng 100.000đ.
- [ ] Thêm Expense 30.000đ có `from_group_fund = 1`: tổng chi tăng 30.000đ, số dư giảm 30.000đ.
- [ ] Thêm Expense 20.000đ có `from_group_fund = 0`: số dư quỹ không đổi.
- [ ] Tổng chi vượt tổng đóng góp: số dư hiển thị số âm, không tự ép về 0.

## 2. Lịch sử giao dịch

- [ ] Đóng góp hiển thị số tiền dương, tên thành viên, ghi chú và thời gian.
- [ ] Chi từ quỹ hiển thị số tiền âm và mô tả Expense.
- [ ] Sửa Expense từ chi cá nhân sang chi quỹ: số dư quỹ cập nhật theo dữ liệu Expense hiện tại.
- [ ] Sửa Expense từ chi quỹ sang chi cá nhân: khoản chi được cộng trở lại vào số dư quỹ.
- [ ] Xóa Expense chi từ quỹ: số dư quỹ tăng lại đúng số tiền đã xóa.

## 3. Settlement

- [ ] Khoản chi cá nhân (`from_group_fund = 0`) tính vào Paid/Owed.
- [ ] Khoản chi từ quỹ (`from_group_fund = 1`) không bị tính trùng vào Settlement cá nhân.
- [ ] Tổng các balance xấp xỉ 0 (sai số tối đa do làm tròn tiền nếu có).
- [ ] Suggested Transfers không có số tiền <= 0 và khi tất toán thì mọi balance về 0.
- [ ] Owner vẫn xuất hiện trong Settlement, kể cả khi dữ liệu cũ thiếu dòng owner trong `TripMembers`.

## 4. Quyền truy cập

- [ ] Người chưa đăng nhập mở quỹ/Settlement bị chuyển tới Login.
- [ ] USER không thuộc Trip nhận 404/không được xem dữ liệu Trip.
- [ ] Member thuộc Trip xem quỹ, lịch sử và Settlement được nhưng POST đóng góp bị từ chối (403).
- [ ] Owner thuộc Trip được ghi nhận đóng góp.
- [ ] Gửi `memberId` của người ngoài Trip không tạo giao dịch.
- [ ] ADMIN không được dùng chức năng nghiệp vụ Trip chỉ dành cho USER; chức năng quản trị vẫn hoạt động riêng.

## 5. Thêm/Sửa/Xóa Expense

- [ ] Số tiền <= 0, mô tả rỗng, payer không thuộc Trip hoặc participant không thuộc Trip bị từ chối.
- [ ] Tạo Expense hợp lệ lưu cả Expense và danh sách phân bổ trong cùng transaction.
- [ ] Chỉ người tạo Expense hoặc Owner được sửa/xóa; Member khác nhận 403.
- [ ] Sửa/xóa Expense cập nhật lại các dòng phân bổ; không để dữ liệu mồ côi trong `ExpenseParticipants`.
- [ ] Trip đã COMPLETED/CANCELLED không cho tạo/sửa/xóa Expense.
- [ ] ID thiếu, không phải số, hoặc ID của Trip khác không làm thay đổi dữ liệu.

## Kết quả kiểm thử

Ghi lại cho từng mục: **PASS / FAIL / NOT RUN**, kèm Trip ID thử nghiệm và lỗi Tomcat/SQL nếu có. Không đánh dấu PASS chỉ vì trang mở được; cần kiểm tra số liệu trước và sau thao tác.
