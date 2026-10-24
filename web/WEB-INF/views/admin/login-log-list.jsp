<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login History</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 30px; background: #f5f6fa; color: #212529; }
        h1 { margin-bottom: 6px; }
        .subtitle { color: #6c757d; margin-bottom: 20px; }
        .filter-box { background: white; padding: 16px; border-radius: 8px; margin-bottom: 18px; box-shadow: 0 1px 4px rgba(0,0,0,.08); }
        .filter-box label { margin-right: 6px; font-weight: bold; }
        .filter-box input, .filter-box select { padding: 8px; margin-right: 12px; border: 1px solid #ced4da; border-radius: 4px; }
        button { padding: 8px 14px; border: 0; border-radius: 4px; background: #212529; color: white; cursor: pointer; }
        .clear { margin-left: 8px; color: #495057; }
        .error { background: #f8d7da; color: #842029; padding: 10px; border-radius: 4px; margin-bottom: 12px; }
        table { width: 100%; border-collapse: collapse; background: white; box-shadow: 0 1px 4px rgba(0,0,0,.08); }
        th, td { padding: 10px; border: 1px solid #dee2e6; text-align: left; vertical-align: top; }
        th { background: #343a40; color: white; }
        .success { color: #198754; font-weight: bold; }
        .failed { color: #dc3545; font-weight: bold; }
        .muted { color: #6c757d; }
        .user-agent { max-width: 280px; word-break: break-word; font-size: 12px; color: #495057; }
        .summary { margin: 12px 0; color: #495057; }
        .pagination { margin-top: 18px; display: flex; gap: 6px; align-items: center; }
        .pagination a, .pagination span { padding: 7px 11px; border: 1px solid #ced4da; border-radius: 4px; text-decoration: none; color: #212529; background: white; }
        .pagination .current { background: #212529; color: white; }
        .pagination .disabled { color: #adb5bd; background: #f1f3f5; }
        .back-link { display: inline-block; margin-top: 20px; }
    </style>
</head>
<body>

<h1>Login History</h1>
<div class="subtitle">Monitor successful and failed user authentication attempts.</div>

<c:if test="${not empty filterError}">
    <div class="error"><c:out value="${filterError}"/></div>
</c:if>

<form method="get" action="${pageContext.request.contextPath}/admin/login-logs" class="filter-box">
    <label for="email">Email:</label>
    <input type="text" id="email" name="email" value="<c:out value='${emailKeyword}'/>" placeholder="Enter email...">

    <label for="result">Result:</label>
    <select id="result" name="result">
        <option value="" ${empty selectedResult ? 'selected' : ''}>All</option>
        <option value="success" ${selectedResult == 'success' ? 'selected' : ''}>Success</option>
        <option value="failed" ${selectedResult == 'failed' ? 'selected' : ''}>Failed</option>
    </select>

    <label for="fromDate">From:</label>
    <input type="date" id="fromDate" name="fromDate" value="<c:out value='${fromDate}'/>" >

    <label for="toDate">To:</label>
    <input type="date" id="toDate" name="toDate" value="<c:out value='${toDate}'/>" >

    <button type="submit">Filter</button>
    <a class="clear" href="${pageContext.request.contextPath}/admin/login-logs">Clear</a>
</form>

<div class="summary">
    Total Records: <strong><c:out value="${totalRows}"/></strong>
</div>

<c:choose>
    <c:when test="${empty loginLogs}">
        <p>No matching login logs found.</p>
    </c:when>
    <c:otherwise>
        <table>
            <thead>
            <tr>
                <th>ID</th>
                <th>Email</th>
                <th>User ID</th>
                <th>Result</th>
                <th>Reason</th>
                <th>IP</th>
                <th>User Agent</th>
                <th>Timestamp</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach items="${loginLogs}" var="log">
                <tr>
                    <td><c:out value="${log.loginLogId}"/></td>
                    <td><c:out value="${log.email}"/></td>
                    <td>
                        <c:choose>
                            <c:when test="${log.userId != null}"><c:out value="${log.userId}"/></c:when>
                            <c:otherwise>—</c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${log.success}"><span class="success">Success</span></c:when>
                            <c:otherwise><span class="failed">Failed</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${empty log.failureReason}">—</c:when>
                            <c:when test="${log.failureReason == 'INVALID_CREDENTIALS'}">Invalid email or password</c:when>
                            <c:when test="${log.failureReason == 'ACCOUNT_DISABLED'}">Account is disabled</c:when>
                            <c:when test="${log.failureReason == 'MISSING_CREDENTIALS'}">Missing credentials</c:when>
                            <c:when test="${log.failureReason == 'SYSTEM_ERROR'}">System error</c:when>
                            <c:when test="${log.failureReason == 'RATE_LIMITED'}">Rate limited - too many attempts</c:when>
                            <c:otherwise><c:out value="${log.failureReason}"/></c:otherwise>
                        </c:choose>
                    </td>
                    <td><c:out value="${log.ipAddress}"/></td>
                    <td class="user-agent"><c:out value="${log.userAgent}"/></td>
                    <td><c:out value="${log.attemptedAt}"/></td>
                </tr>
            </c:forEach>
            </tbody>
        </table>

        <c:if test="${totalPages > 1}">
            <div class="pagination">
                <c:url var="baseUrl" value="/admin/login-logs">
                    <c:param name="email" value="${emailKeyword}"/>
                    <c:param name="result" value="${selectedResult}"/>
                    <c:param name="fromDate" value="${fromDate}"/>
                    <c:param name="toDate" value="${toDate}"/>
                </c:url>

                <c:choose>
                    <c:when test="${currentPage > 1}">
                        <a href="${baseUrl}&page=${currentPage - 1}">« Prev</a>
                    </c:when>
                    <c:otherwise><span class="disabled">« Prev</span></c:otherwise>
                </c:choose>

                <c:forEach begin="1" end="${totalPages}" var="p">
                    <c:choose>
                        <c:when test="${p == currentPage}">
                            <span class="current"><c:out value="${p}"/></span>
                        </c:when>
                        <c:otherwise>
                            <a href="${baseUrl}&page=${p}"><c:out value="${p}"/></a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <c:choose>
                    <c:when test="${currentPage < totalPages}">
                        <a href="${baseUrl}&page=${currentPage + 1}">Next »</a>
                    </c:when>
                    <c:otherwise><span class="disabled">Next »</span></c:otherwise>
                </c:choose>
            </div>
        </c:if>
    </c:otherwise>
</c:choose>

<a class="back-link" href="${pageContext.request.contextPath}/admin">← Back to Admin Dashboard</a>

</body>
</html>
