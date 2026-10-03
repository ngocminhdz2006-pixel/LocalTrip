<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Lịch sử đăng nhập</title>

        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 30px;
                background: #f5f6fa;
            }

            h1 {
                margin-bottom: 20px;
            }

            table {
                width: 100%;
                border-collapse: collapse;
                background: white;
            }

            th, td {
                padding: 10px;
                border: 1px solid #ddd;
                text-align: left;
            }

            th {
                background: #343a40;
                color: white;
            }

            .success {
                color: #198754;
                font-weight: bold;
            }

            .failed {
                color: #dc3545;
                font-weight: bold;
            }

            .back-link {
                display: inline-block;
                margin-top: 20px;
            }
        </style>
    </head>

    <body>

        <h1>Lịch sử đăng nhập</h1>
        <form method="get"
              action="${pageContext.request.contextPath}/admin/login-logs"
              style="margin-bottom: 20px;">

            <label for="email">Email:</label>

            <input type="text"
                   id="email"
                   name="email"
                   value="<c:out value="${emailKeyword}"/>"
                   placeholder="Nhập email cần tìm">

            <label for="result">Kết quả:</label>

            <select id="result" name="result">
                <option value=""
                        ${empty selectedResult ? 'selected' : ''}>
                    Tất cả
                </option>

                <option value="success"
                        ${selectedResult == 'success' ? 'selected' : ''}>
                    Thành công
                </option>

                <option value="failed"
                        ${selectedResult == 'failed' ? 'selected' : ''}>
                    Thất bại
                </option>
            </select>

            <button type="submit">
                Lọc
            </button>

            <a href="${pageContext.request.contextPath}/admin/login-logs">
                Xóa bộ lọc
            </a>
        </form>

        <c:choose>
            <c:when test="${empty loginLogs}">
                <p>Chưa có lịch sử đăng nhập.</p>

            </c:when>

            <c:otherwise>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Email</th>
                            <th>User ID</th>
                            <th>Kết quả</th>
                            <th>Lý do</th>
                            <th>Địa chỉ IP</th>
                            <th>Thời gian</th>
                        </tr>
                    </thead>

                    <tbody>
                        <c:forEach items="${loginLogs}" var="log">
                            <tr>
                                <td>
                                    <c:out value="${log.loginLogId}"/>
                                </td>

                                <td>
                                    <c:out value="${log.email}"/>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${log.userId != null}">
                                            <c:out value="${log.userId}"/>
                                        </c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${log.success}">
                                            <span class="success">Thành công</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="failed">Thất bại</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${empty log.failureReason}">
                                            —
                                        </c:when>

                                        <c:when test="${log.failureReason == 'INVALID_CREDENTIALS'}">
                                            Sai email hoặc mật khẩu
                                        </c:when>

                                        <c:when test="${log.failureReason == 'ACCOUNT_DISABLED'}">
                                            Tài khoản đã bị khóa
                                        </c:when>

                                        <c:when test="${log.failureReason == 'MISSING_CREDENTIALS'}">
                                            Chưa nhập đủ thông tin
                                        </c:when>

                                        <c:when test="${log.failureReason == 'SYSTEM_ERROR'}">
                                            Lỗi hệ thống
                                        </c:when>
                                        <c:when test="${log.failureReason == 'RATE_LIMITED'}">
                                            Thử đăng nhập quá nhiều lần
                                        </c:when>

                                        <c:otherwise>
                                            <c:out value="${log.failureReason}"/>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <c:out value="${log.ipAddress}"/>
                                </td>

                                <td>
                                    <c:out value="${log.attemptedAt}"/>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>

        <a class="back-link"
           href="${pageContext.request.contextPath}/admin">
            Quay lại trang Admin
        </a>

    </body>
</html>