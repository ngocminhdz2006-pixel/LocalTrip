package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.AdminAuditLog;


public class AdminAuditLogDAO {

    public boolean log(int actorUserId,
            String action,
            Integer targetUserId,
            String detail) {

        String sql = "INSERT INTO AdminAuditLogs "
                + "(actor_user_id, action, target_user_id, detail) "
                + "VALUES (?, ?, ?, ?)";

        String safeDetail = detail;

        /*
         * Khớp với cột detail NVARCHAR(500), tránh một nội dung
         * quá dài làm mất kết quả thao tác chính.
         */
        if (safeDetail != null && safeDetail.length() > 500) {
            safeDetail = safeDetail.substring(0, 500);
        }

        try ( Connection con = DBContext.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, actorUserId);
            ps.setString(2, action);

            if (targetUserId == null) {
                ps.setNull(3, Types.INTEGER);
            } else {
                ps.setInt(3, targetUserId);
            }

            ps.setString(4, safeDetail);

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            e.printStackTrace();
            /*
             * Audit log là chức năng hỗ trợ. Nếu ghi log thất bại,
             * thao tác tạo/sửa/reset user đã thành công không nên
             * bị báo ngược thành thất bại.
             */
            return false;
        }
    }

    public List<AdminAuditLog> findRecent(int limit) {

        if (limit < 1 || limit > 200) {
            limit = 50;
        }

        String sql
                = "SELECT l.audit_id, "
                + "l.actor_user_id, "
                + "actor.full_name AS actor_name, "
                + "actor.email AS actor_email, "
                + "l.action, "
                + "l.target_user_id, "
                + "target.full_name AS target_name, "
                + "target.email AS target_email, "
                + "l.detail, "
                + "l.created_at "
                + "FROM AdminAuditLogs l "
                + "JOIN Users actor "
                + "ON actor.user_id = l.actor_user_id "
                + "LEFT JOIN Users target "
                + "ON target.user_id = l.target_user_id "
                + "ORDER BY l.created_at DESC, l.audit_id DESC "
                + "OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";

        List<AdminAuditLog> logs
                = new ArrayList<AdminAuditLog>();

        try ( Connection con = DBContext.getConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, limit);

            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AdminAuditLog log = new AdminAuditLog();

                    log.setAuditId(rs.getLong("audit_id"));

                    log.setActorUserId(
                            rs.getInt("actor_user_id")
                    );
                    log.setActorName(
                            rs.getString("actor_name")
                    );
                    log.setActorEmail(
                            rs.getString("actor_email")
                    );

                    log.setAction(rs.getString("action"));

                    int targetUserId
                            = rs.getInt("target_user_id");

                    if (rs.wasNull()) {
                        log.setTargetUserId(null);
                    } else {
                        log.setTargetUserId(
                                Integer.valueOf(targetUserId)
                        );
                    }

                    log.setTargetName(
                            rs.getString("target_name")
                    );
                    log.setTargetEmail(
                            rs.getString("target_email")
                    );

                    log.setDetail(rs.getString("detail"));
                    log.setCreatedAt(
                            rs.getTimestamp("created_at")
                    );

                    logs.add(log);
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "Không thể tải audit log",
                    e
            );
        }

        return logs;
    }
}
