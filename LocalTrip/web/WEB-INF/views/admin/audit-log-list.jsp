<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.AdminAuditLog" %>
<%@ page import="utils.HtmlUtil" %>

<%
    List<AdminAuditLog> logs =
            (List<AdminAuditLog>) request.getAttribute("logs");

    request.setAttribute("pageTitle", "Nhật ký quản trị");
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="d-flex justify-content-between
            align-items-center mb-4">

    <div>
        <h2 class="fw-bold mb-1">Nhật ký quản trị</h2>

        <p class="text-muted mb-0">
            100 thao tác User Management gần nhất
        </p>
    </div>

    <div class="d-flex gap-2">
        <a href="<%= request.getContextPath() %>/admin/users"
           class="btn btn-outline-primary">
            Quản lý Users
        </a>

        <a href="<%= request.getContextPath() %>/admin"
           class="btn btn-outline-secondary">
            Admin Dashboard
        </a>
    </div>
</div>

<div class="card shadow-sm">
    <div class="card-body">

        <% if (logs == null || logs.isEmpty()) { %>

            <div class="alert alert-info mb-0">
                Chưa có thao tác quản trị nào được ghi nhận.
            </div>

        <% } else { %>

            <div class="d-flex justify-content-between mb-3">
                <strong>Lịch sử thao tác</strong>

                <span class="text-muted">
                    <%= logs.size() %> bản ghi
                </span>
            </div>

            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Thời gian</th>
                            <th>Admin thực hiện</th>
                            <th>Hành động</th>
                            <th>User bị tác động</th>
                            <th>Chi tiết</th>
                        </tr>
                    </thead>

                    <tbody>
                        <% for (AdminAuditLog log : logs) { %>
                            <tr>
                                <td class="text-nowrap">
                                    <%= log.getCreatedAt() == null
                                            ? ""
                                            : HtmlUtil.escape(
                                                log.getCreatedAt().toString()
                                              )
                                    %>
                                </td>

                                <td>
                                    <strong>
                                        <%= HtmlUtil.escape(
                                                log.getActorName()
                                           ) %>
                                    </strong>

                                    <div class="small text-muted">
                                        <%= HtmlUtil.escape(
                                                log.getActorEmail()
                                           ) %>
                                    </div>
                                </td>

                                <td>
                                    <% if ("CREATE_USER".equals(
                                            log.getAction())) { %>

                                        <span class="badge text-bg-success">
                                            Tạo user
                                        </span>

                                    <% } else if ("UPDATE_USER".equals(
                                            log.getAction())) { %>

                                        <span class="badge text-bg-primary">
                                            Cập nhật user
                                        </span>

                                    <% } else if ("RESET_PASSWORD".equals(
                                            log.getAction())) { %>

                                        <span class="badge text-bg-warning">
                                            Reset mật khẩu
                                        </span>

                                    <% } else { %>

                                        <span class="badge text-bg-secondary">
                                            <%= HtmlUtil.escape(
                                                    log.getAction()
                                               ) %>
                                        </span>

                                    <% } %>
                                </td>

                                <td>
                                    <% if (log.getTargetUserId() == null) { %>
                                        <span class="text-muted">—</span>
                                    <% } else { %>
                                        <strong>
                                            <%= HtmlUtil.escape(
                                                    log.getTargetName()
                                               ) %>
                                        </strong>

                                        <div class="small text-muted">
                                            <%= HtmlUtil.escape(
                                                    log.getTargetEmail()
                                               ) %>
                                        </div>
                                    <% } %>
                                </td>

                                <td>
                                    <%= HtmlUtil.escape(log.getDetail()) %>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

        <% } %>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>