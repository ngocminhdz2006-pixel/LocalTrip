<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.AdminAuditLog" %>
<%@ page import="utils.HtmlUtil" %>

<%
    List<AdminAuditLog> logs = (List<AdminAuditLog>) request.getAttribute("logs");
    List<String> actions = (List<String>) request.getAttribute("actions");
    String keyword = (String) request.getAttribute("keyword");
    String selectedAction = (String) request.getAttribute("selectedAction");
    Integer resultCount = (Integer) request.getAttribute("resultCount");
    Integer pageNumber = (Integer) request.getAttribute("page");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    String errorMessage = (String) request.getAttribute("errorMessage");
    request.setAttribute("pageTitle", "Admin Audit Logs");
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h2 class="fw-bold mb-1">Admin Audit Logs</h2>
        <p class="text-muted mb-0">
            Track critical actions executed by administrators across the platform.
        </p>
    </div>
    <a href="<%= request.getContextPath() %>/admin" class="btn btn-outline-secondary">
        ← Admin Dashboard
    </a>
</div>

<% if (errorMessage != null) { %>
<div class="alert alert-warning"><%= HtmlUtil.escape(errorMessage) %></div>
<% } %>

<div class="card shadow-sm mb-4">
    <div class="card-body">
        <form method="get" action="<%= request.getContextPath() %>/admin/audit-logs" class="row g-3 align-items-end">
            <div class="col-md-6">
                <label class="form-label">Search</label>
                <input type="text" name="keyword" class="form-control"
                       value="<%= HtmlUtil.escape(keyword) %>"
                       placeholder="Admin, email, user, action details...">
            </div>
            <div class="col-md-4">
                <label class="form-label">Action Type</label>
                <select name="action" class="form-select">
                    <option value="">All Actions</option>
                    <% if (actions != null) { for (String action : actions) { %>
                        <option value="<%= HtmlUtil.escape(action) %>"
                            <%= action.equals(selectedAction) ? "selected" : "" %>>
                            <%= actionLabel(action) %>
                        </option>
                    <% }} %>
                </select>
            </div>
            <div class="col-md-2 d-flex gap-2">
                <button class="btn btn-primary flex-grow-1" type="submit">Filter</button>
                <a class="btn btn-outline-secondary" href="<%= request.getContextPath() %>/admin/audit-logs">Clear</a>
            </div>
        </form>
    </div>
</div>

<div class="card shadow-sm">
    <div class="card-body">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <strong>Audit Log Records</strong>
                <span class="text-muted ms-2"><%= resultCount == null ? 0 : resultCount %> records</span>
            </div>
            <span class="small text-muted">Page <%= pageNumber == null ? 1 : pageNumber %> / <%= totalPages == null ? 1 : totalPages %></span>
        </div>

        <% if (logs == null || logs.isEmpty()) { %>
            <div class="alert alert-info mb-0">No matching audit logs found.</div>
        <% } else { %>
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Timestamp</th>
                            <th>Admin Actor</th>
                            <th>Action</th>
                            <th>Target</th>
                            <th>Details</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (AdminAuditLog log : logs) { %>
                        <tr>
                            <td class="text-nowrap small">
                                <%= log.getCreatedAt() == null ? "" : HtmlUtil.escape(log.getCreatedAt().toString()) %>
                            </td>
                            <td>
                                <strong><%= HtmlUtil.escape(log.getActorName()) %></strong>
                                <div class="small text-muted"><%= HtmlUtil.escape(log.getActorEmail()) %></div>
                            </td>
                            <td><span class="badge <%= actionBadge(log.getAction()) %>"><%= actionLabel(log.getAction()) %></span></td>
                            <td>
                                <% if (log.getTargetUserId() != null) { %>
                                    <strong><%= HtmlUtil.escape(log.getTargetName()) %></strong>
                                    <div class="small text-muted"><%= HtmlUtil.escape(log.getTargetEmail()) %></div>
                                <% } else { %>
                                    <span class="text-muted">See details</span>
                                <% } %>
                            </td>
                            <td><%= HtmlUtil.escape(log.getDetail()) %></td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <% if (totalPages != null && totalPages > 1) { %>
            <nav class="mt-3" aria-label="Audit log pagination">
                <ul class="pagination justify-content-center mb-0">
                    <% for (int p = 1; p <= totalPages; p++) { %>
                        <li class="page-item <%= p == pageNumber ? "active" : "" %>">
                            <a class="page-link"
                               href="<%= request.getContextPath() %>/admin/audit-logs?keyword=<%= java.net.URLEncoder.encode(keyword == null ? "" : keyword, "UTF-8") %>&action=<%= java.net.URLEncoder.encode(selectedAction == null ? "" : selectedAction, "UTF-8") %>&page=<%= p %>">
                                <%= p %>
                            </a>
                        </li>
                    <% } %>
                </ul>
            </nav>
            <% } %>
        <% } %>
    </div>
</div>

<%!
    private String actionLabel(String action) {
        if (action == null) return "Unknown";
        if ("CREATE_USER".equals(action)) return "Create User";
        if ("UPDATE_USER".equals(action)) return "Update User";
        if ("RESET_PASSWORD".equals(action)) return "Reset Password";
        if ("CREATE_PLACE".equals(action)) return "Create Place";
        if ("UPDATE_PLACE".equals(action)) return "Update Place";
        if ("ACTIVATE_PLACE".equals(action)) return "Activate Place";
        if ("DEACTIVATE_PLACE".equals(action)) return "Deactivate Place";
        if ("CREATE_CATEGORY".equals(action)) return "Create Category";
        if ("UPDATE_CATEGORY".equals(action)) return "Update Category";
        if ("DELETE_CATEGORY".equals(action)) return "Delete Category";
        return action;
    }

    private String actionBadge(String action) {
        if (action == null) return "text-bg-secondary";
        if (action.startsWith("CREATE_")) return "text-bg-success";
        if (action.startsWith("UPDATE_")) return "text-bg-primary";
        if (action.startsWith("DELETE_") || action.startsWith("DEACTIVATE_")) return "text-bg-danger";
        if (action.startsWith("RESET_") || action.startsWith("ACTIVATE_")) return "text-bg-warning";
        return "text-bg-secondary";
    }
%>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
