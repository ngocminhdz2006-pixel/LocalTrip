<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,model.Place,model.Category,utils.HtmlUtil" %>
<%
    List<Place> places = (List<Place>) request.getAttribute("places");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    String keyword = (String) request.getAttribute("keyword");
    Integer selectedCategory = (Integer) request.getAttribute("selectedCategory");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    request.setAttribute("pageTitle", "Place Management");
%>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <div class="text-muted small">ADMIN / PLACES</div>
        <h2 class="fw-bold mb-1">Place Management</h2>
        <p class="text-muted mb-0">Create, edit, search, and activate/deactivate places across the system.</p>
    </div>
    <a href="<%= request.getContextPath() %>/admin/places/create" class="btn btn-primary">+ Add Place</a>
</div>

<div class="card shadow-sm mb-4">
    <div class="card-body">
        <form method="get" action="<%= request.getContextPath() %>/admin/places" class="row g-3">
            <div class="col-lg-5">
                <label class="form-label">Search</label>
                <input type="text" name="keyword" class="form-control" value="<%= HtmlUtil.escape(keyword == null ? "" : keyword) %>" placeholder="Place name or address...">
            </div>
            <div class="col-lg-3">
                <label class="form-label">Category</label>
                <select name="categoryId" class="form-select">
                    <option value="0">All Categories</option>
                    <% if (categories != null) for (Category c : categories) { %>
                    <option value="<%= c.getCategoryId() %>" <%= selectedCategory != null && selectedCategory == c.getCategoryId() ? "selected" : "" %>>
                        <%= HtmlUtil.escape(c.getCategoryName()) %>
                    </option>
                    <% } %>
                </select>
            </div>
            <div class="col-lg-2">
                <label class="form-label">Status</label>
                <select name="status" class="form-select">
                    <option value="">All</option>
                    <option value="ACTIVE" <%= "ACTIVE".equals(selectedStatus) ? "selected" : "" %>>Active</option>
                    <option value="INACTIVE" <%= "INACTIVE".equals(selectedStatus) ? "selected" : "" %>>Inactive</option>
                </select>
            </div>
            <div class="col-lg-2 d-flex align-items-end gap-2">
                <button class="btn btn-outline-primary flex-fill" type="submit">Filter</button>
                <a class="btn btn-outline-secondary" href="<%= request.getContextPath() %>/admin/places">Clear</a>
            </div>
        </form>
    </div>
</div>

<div class="card shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Place</th>
                        <th>Category</th>
                        <th>Address</th>
                        <th>Est. Cost</th>
                        <th>Rating</th>
                        <th>Status</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                <% if (places == null || places.isEmpty()) { %>
                    <tr><td colspan="8" class="text-center text-muted py-5">No matching places found.</td></tr>
                <% } else { for (Place p : places) { %>
                    <tr>
                        <td>#<%= p.getPlaceId() %></td>
                        <td>
                            <div class="fw-semibold"><%= HtmlUtil.escape(p.getPlaceName()) %></div>
                            <div class="small text-muted"><%= HtmlUtil.escape(p.getPlaceType()) %></div>
                        </td>
                        <td><%= HtmlUtil.escape(p.getCategoryName()) %></td>
                        <td><%= HtmlUtil.escape(p.getAddress()) %></td>
                        <td><%= p.getEstimatedCost() %></td>
                        <td><%= p.getRating() %>/5</td>
                        <td>
                            <% if (p.isActive()) { %>
                                <span class="badge text-bg-success">ACTIVE</span>
                            <% } else { %>
                                <span class="badge text-bg-secondary">INACTIVE</span>
                            <% } %>
                        </td>
                        <td class="text-end text-nowrap">
                            <a href="<%= request.getContextPath() %>/admin/places/edit?id=<%= p.getPlaceId() %>" class="btn btn-sm btn-outline-primary">Edit</a>
                            <form method="post" action="<%= request.getContextPath() %>/admin/places/toggle" class="d-inline">
                                <input type="hidden" name="id" value="<%= p.getPlaceId() %>">
                                <button type="submit" class="btn btn-sm <%= p.isActive() ? "btn-outline-danger" : "btn-outline-success" %>">
                                    <%= p.isActive() ? "Deactivate" : "Activate" %>
                                </button>
                            </form>
                        </td>
                    </tr>
                <% } } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
