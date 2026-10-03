package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.LoginLog;

public class LoginLogDAO {

    private static final String INSERT_SQL
            = "INSERT INTO LoginLogs "
            + "(user_id, email, success, failure_reason, ip_address, user_agent) "
            + "VALUES (?, ?, ?, ?, ?, ?)";

    public boolean log(Integer userId,
            String email,
            boolean success,
            String failureReason,
            String ipAddress,
            String userAgent) {

        try ( Connection connection = DBContext.getConnection();  PreparedStatement statement
                = connection.prepareStatement(INSERT_SQL)) {

            if (userId == null) {
                statement.setNull(1, Types.INTEGER);
            } else {
                statement.setInt(1, userId);
            }

            statement.setString(2, email);
            statement.setBoolean(3, success);
            statement.setString(4, failureReason);
            statement.setString(5, ipAddress);

            if (userAgent != null && userAgent.length() > 500) {
                userAgent = userAgent.substring(0, 500);
            }

            statement.setString(6, userAgent);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<LoginLog> findRecent(int limit) {
        List<LoginLog> logs = new ArrayList<>();

        String sql = "SELECT TOP (?) "
                + "login_log_id, user_id, email, success, "
                + "failure_reason, ip_address, user_agent, attempted_at "
                + "FROM LoginLogs "
                + "ORDER BY attempted_at DESC, login_log_id DESC";

        try ( Connection connection = DBContext.getConnection();  PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, limit);

            try ( ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    LoginLog log = new LoginLog();

                    log.setLoginLogId(resultSet.getLong("login_log_id"));

                    int userId = resultSet.getInt("user_id");
                    if (resultSet.wasNull()) {
                        log.setUserId(null);
                    } else {
                        log.setUserId(userId);
                    }

                    log.setEmail(resultSet.getString("email"));
                    log.setSuccess(resultSet.getBoolean("success"));
                    log.setFailureReason(
                            resultSet.getString("failure_reason")
                    );
                    log.setIpAddress(resultSet.getString("ip_address"));
                    log.setUserAgent(resultSet.getString("user_agent"));
                    log.setAttemptedAt(
                            resultSet.getTimestamp("attempted_at")
                    );

                    logs.add(log);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return logs;
    }

    public List<LoginLog> searchRecent(String emailKeyword,
            String result,
            int limit) {

        List<LoginLog> logs = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT TOP (?) "
                + "login_log_id, user_id, email, success, "
                + "failure_reason, ip_address, user_agent, attempted_at "
                + "FROM LoginLogs WHERE 1 = 1 "
        );

        boolean hasEmail
                = emailKeyword != null && !emailKeyword.trim().isEmpty();

        boolean filterSuccess = "success".equalsIgnoreCase(result);
        boolean filterFailed = "failed".equalsIgnoreCase(result);

        if (hasEmail) {
            sql.append("AND email LIKE ? ");
        }

        if (filterSuccess || filterFailed) {
            sql.append("AND success = ? ");
        }

        sql.append("ORDER BY attempted_at DESC, login_log_id DESC");

        try ( Connection connection = DBContext.getConnection();  PreparedStatement statement
                = connection.prepareStatement(sql.toString())) {

            int parameterIndex = 1;

            statement.setInt(parameterIndex++, limit);

            if (hasEmail) {
                statement.setString(
                        parameterIndex++,
                        "%" + emailKeyword.trim() + "%"
                );
            }

            if (filterSuccess) {
                statement.setBoolean(parameterIndex++, true);
            } else if (filterFailed) {
                statement.setBoolean(parameterIndex++, false);
            }

            try ( ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    LoginLog log = new LoginLog();

                    log.setLoginLogId(
                            resultSet.getLong("login_log_id")
                    );

                    int userId = resultSet.getInt("user_id");

                    if (resultSet.wasNull()) {
                        log.setUserId(null);
                    } else {
                        log.setUserId(userId);
                    }

                    log.setEmail(resultSet.getString("email"));
                    log.setSuccess(resultSet.getBoolean("success"));
                    log.setFailureReason(
                            resultSet.getString("failure_reason")
                    );
                    log.setIpAddress(
                            resultSet.getString("ip_address")
                    );
                    log.setUserAgent(
                            resultSet.getString("user_agent")
                    );
                    log.setAttemptedAt(
                            resultSet.getTimestamp("attempted_at")
                    );

                    logs.add(log);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return logs;
    }

    public int countRecentFailures(String email, int minutes) {

        String sql = "SELECT COUNT(*) "
                + "FROM LoginLogs "
                + "WHERE email = ? "
                + "AND success = 0 "
                + "AND failure_reason = 'INVALID_CREDENTIALS' "
                + "AND attempted_at >= "
                + "DATEADD(MINUTE, ?, SYSDATETIME()) "
                + "AND attempted_at > ISNULL(("
                + "SELECT MAX(attempted_at) "
                + "FROM LoginLogs "
                + "WHERE email = ? AND success = 1"
                + "), CAST('1900-01-01' AS DATETIME2))";

        try ( Connection connection = DBContext.getConnection();  PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setString(1, email);
            statement.setInt(2, -Math.max(1, minutes));
            statement.setString(3, email);

            try ( ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getInt(1);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }
}
