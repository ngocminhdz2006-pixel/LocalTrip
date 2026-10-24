<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="utils.HtmlUtil" %>
<%@ page import="java.net.URLEncoder" %>

<%
    List<User> users = (List<User>) request.getAttribute("users");
    String keyword = (String) request.getAttribute("keyword");
    String selectedRole
            = (String) request.getAttribute("selectedRole");
    String selectedStatus
            = (String) request.getAttribute("selectedStatus");
    Integer resultCount
            = (Integer) request.getAttribute("resultCount");
    Integer currentPage
            = (Integer) request.getAttribute("page");
    Integer totalPages
            = (Integer) request.getAttribute("totalPages");

    if (keyword == null) {
        keyword = "";
    }

    if (selectedRole == null) {
        selectedRole = "";
    }

    if (selectedStatus == null) {
        selectedStatus = "";
    }
    if (currentPage == null || currentPage < 1) {
        currentPage = 1;
    }

    if (totalPages == null || totalPages < 1) {
        totalPages = 1;
    }

    String encodedKeyword
            = URLEncoder.encode(keyword, "UTF-8");
    String encodedRole
            = URLEncoder.encode(selectedRole, "UTF-8");
    String encodedStatus
            = URLEncoder.encode(selectedStatus, "UTF-8");
    request.setAttribute("pageTitle", "User Management");
%>
<% request.setAttribute("tripRedesign", Boolean.TRUE);%>
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
    .rd-page .user-management-card {
        background: #fff;
        border: 1px solid var(--line);
        border-radius: 18px;
        box-shadow: none !important;
        overflow: hidden;
    }

    .rd-page .user-management-card > .card-body {
        padding: 26px;
    }

    .rd-page .user-management-card .form-label {
        font-weight: 600;
        color: var(--ink);
    }

    .rd-page .user-management-card .table {
        margin-bottom: 0;
    }

    .rd-page .user-management-card .table th {
        padding: 14px 12px;
        white-space: nowrap;
        color: var(--ink2);
        background: var(--bg);
        font-size: 13px;
    }

    .rd-page .user-management-card .table td {
        padding: 16px 12px;
        border-color: var(--line);
    }

    .rd-page .user-management-card .table td:nth-child(2),
    .rd-page .user-management-card .table td:nth-child(3) {
        min-width: 160px;
        overflow-wrap: anywhere;
    }

    .rd-page .user-management-card .table td:last-child {
        min-width: 210px;
    }

    .rd-page .user-management-card .badge {
        padding: 7px 10px;
        border-radius: 20px;
        font-weight: 500;
        white-space: nowrap;
    }

    .rd-page .user-management-card .text-bg-primary {
        background: var(--mint) !important;
        color: var(--green) !important;
    }

    .rd-page .user-management-card .text-bg-danger {
        background: #fff0d1 !important;
        color: #855700 !important;
    }

    .rd-page .user-management-card .text-bg-success {
        background: #e3f0e8 !important;
        color: #1e5a44 !important;
    }

    .rd-page .user-management-card .text-bg-secondary {
        background: #edf0ee !important;
        color: #526158 !important;
    }

    .rd-page .user-management-card .pagination {
        flex-wrap: wrap;
        gap: 6px;
    }

    .rd-page .user-management-card .page-link {
        border-radius: 9px;
        color: var(--green);
        border-color: var(--line);
    }

    .rd-page .user-management-card .page-item.active .page-link {
        background: var(--green);
        border-color: var(--green);
        color: #fff;
    }

    .rd-page .user-management-card .page-item.disabled .page-link {
        color: #6c757d;
        background: var(--bg);
    }

    @media (max-width: 575px) {
        .rd-page .user-management-card > .card-body {
            padding: 20px 16px;
        }
    }
</style>
<section class="rd-hero mb-4">
    <div class="rd-hero-top">
        <div>
            <div class="small text-white-50 mb-2">
                LOCALTRIP · USER ADMINISTRATION
            </div>

            <h1 class="mb-2">User Management</h1>

            <p class="text-white mb-0">
                Search accounts, update credentials and manage platform permissions.
            </p>
        </div>

        <div class="d-flex flex-wrap gap-2">
            <a href="<%= request.getContextPath()%>/admin/users/create"
               class="rd-back">
                + Add User
            </a>

            <a href="<%= request.getContextPath()%>/admin"
               class="rd-back">
                ← Admin Dashboard
            </a>
        </div>
    </div>
</section>
<div class="card shadow-sm mb-4 user-management-card">
    <div class="card-body">
        <form method="get"
              action="<%= request.getContextPath()%>/admin/users">

            <div class="row g-3 align-items-end">
                <div class="col-lg-5">
                    <label class="form-label">
                        Search by full name or email
                    </label>

                    <input type="text"
                           name="keyword"
                           class="form-control"
                           value="<%= HtmlUtil.escape(keyword)%>"
                           placeholder="e.g. Lan Anh or @localtrip.vn">
                </div>

                <div class="col-lg-2">
                    <label class="form-label">Role</label>

                    <select name="role" class="form-select">
                        <option value="">All</option>

                        <option value="ADMIN"
                                <%= "ADMIN".equals(selectedRole)
                                        ? "selected" : ""%>>
                            ADMIN
                        </option>

                        <option value="USER"
                                <%= "USER".equals(selectedRole)
                                        ? "selected" : ""%>>
                            USER
                        </option>
                    </select>
                </div>

                <div class="col-lg-2">
                    <label class="form-label">Status</label>

                    <select name="status" class="form-select">
                        <option value="">All</option>

                        <option value="ACTIVE"
                                <%= "ACTIVE".equals(selectedStatus)
                                        ? "selected" : ""%>>
                            Active
                        </option>

                        <option value="LOCKED"
                                <%= "LOCKED".equals(selectedStatus)
                                        ? "selected" : ""%>>
                            Locked
                        </option>
                    </select>
                </div>

                <div class="col-lg-3">
                    <button type="submit"
                            class="btn btn-primary">
                        Search
                    </button>

                    <a href="<%= request.getContextPath()%>/admin/users"
                       class="btn btn-outline-secondary">
                        Clear
                    </a>
                </div>
            </div>
        </form>
    </div>
</div>
<div class="card shadow-sm user-management-card">
    <div class="card-body">
        <div class="d-flex justify-content-between mb-3">
            <strong>User List</strong>

            <span class="text-muted">
                <%= resultCount == null ? 0 : resultCount%> results
            </span>
        </div>
        <% if (users == null || users.isEmpty()) { %>

        <div class="alert alert-info mb-0">
            No users match the search criteria.
        </div>

        <% } else { %>

        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Created At</th>
                        <th>Actions</th>
                    </tr>
                </thead>

                <tbody>
                    <% for (User user : users) {%>
                    <tr>
                        <td><%= user.getUserId()%></td>

                        <td>
                            <%= HtmlUtil.escape(user.getFullName())%>
                        </td>

                        <td>
                            <%= HtmlUtil.escape(user.getEmail())%>
                        </td>

                        <td>
                            <% if ("ADMIN".equals(user.getRole())) { %>
                            <span class="badge text-bg-danger">
                                ADMIN
                            </span>
                            <% } else { %>
                            <span class="badge text-bg-primary">
                                USER
                            </span>
                            <% } %>
                        </td>

                        <td>
                            <% if (user.isActive()) { %>
                            <span class="badge text-bg-success">
                                Active
                            </span>
                            <% } else { %>
                            <span class="badge text-bg-secondary">
                                Locked
                            </span>
                            <% }%>
                        </td>

                        <td>
                            <%= user.getCreatedAt() == null
                                    ? ""
                                    : HtmlUtil.escape(
                                            user.getCreatedAt().toString()
                                    )%>
                        </td>
                        <td>
                            <div class="d-flex flex-wrap gap-2">
                                <a href="<%= request.getContextPath()%>/admin/users/edit?id=<%= user.getUserId()%>"
                                   class="btn btn-sm btn-outline-primary">
                                    Edit
                                </a>

                                <a href="<%= request.getContextPath()%>/admin/users/reset-password?id=<%= user.getUserId()%>"
                                   class="btn btn-sm btn-outline-warning">
                                    Reset Password
                                </a>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% if (totalPages > 1) {%>
        <nav class="mt-4"
             aria-label="User list pagination">

            <ul class="pagination justify-content-center mb-0">

                <li class="page-item
                    <%= currentPage <= 1 ? "disabled" : ""%>">

                    <% if (currentPage <= 1) { %>
                    <span class="page-link">Previous</span>
                    <% } else {%>
                    <a class="page-link"
                       href="<%= request.getContextPath()%>/admin/users?keyword=<%= encodedKeyword%>&role=<%= encodedRole%>&status=<%= encodedStatus%>&page=<%= currentPage - 1%>">
                        Previous
                    </a>
                    <% } %>
                </li>

                <% for (int pageNumber = 1;
                            pageNumber <= totalPages;
                            pageNumber++) {%>

                <li class="page-item
                    <%= pageNumber == currentPage
                            ? "active" : ""%>">

                    <a class="page-link"
                       href="<%= request.getContextPath()%>/admin/users?keyword=<%= encodedKeyword%>&role=<%= encodedRole%>&status=<%= encodedStatus%>&page=<%= pageNumber%>">
                        <%= pageNumber%>
                    </a>
                </li>
                <% }%>

                <li class="page-item
                    <%= currentPage >= totalPages
                            ? "disabled" : ""%>">

                    <% if (currentPage >= totalPages) { %>
                    <span class="page-link">Next</span>
                    <% } else {%>
                    <a class="page-link"
                       href="<%= request.getContextPath()%>/admin/users?keyword=<%= encodedKeyword%>&role=<%= encodedRole%>&status=<%= encodedStatus%>&page=<%= currentPage + 1%>">
                        Trang sau
                    </a>
                    <% }%>
                </li>

            </ul>
        </nav>

        <div class="text-center text-muted small mt-2">
            Page <%= currentPage%> / <%= totalPages%>
        </div>
        <% } %>
        <% }%>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>