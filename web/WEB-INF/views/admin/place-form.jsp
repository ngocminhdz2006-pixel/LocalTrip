<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,model.Place,model.Category,utils.HtmlUtil" %>
<%
    Place item = (Place) request.getAttribute("item");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    boolean editing = item != null && item.getPlaceId() > 0;
    request.setAttribute("pageTitle", editing ? "Edit Place" : "Add Place");
%>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <div class="text-muted small">ADMIN / PLACES</div>
        <h2 class="fw-bold mb-1"><%= editing ? "Edit Place" : "Add Place" %></h2>
        <p class="text-muted mb-0">Enter place details for discovery, search, and itinerary suggestions.</p>
    </div>
    <a href="<%= request.getContextPath() %>/admin/places" class="btn btn-outline-secondary">Back</a>
</div>

<div class="card shadow-sm">
    <div class="card-body p-4">
        <form method="post" action="<%= request.getContextPath() %>/admin/places/<%= editing ? "edit" : "create" %>">
            <% if (editing) { %>
                <input type="hidden" name="placeId" value="<%= item.getPlaceId() %>">
            <% } %>

            <div class="row g-3">
                <div class="col-md-8">
                    <label class="form-label">Place Name *</label>
                    <input type="text" name="placeName" class="form-control" maxlength="200" required value="<%= HtmlUtil.escape(item == null ? "" : item.getPlaceName()) %>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Category *</label>
                    <select name="categoryId" class="form-select" required>
                        <option value="">-- Select Category --</option>
                        <% if (categories != null) for (Category c : categories) { %>
                        <option value="<%= c.getCategoryId() %>" <%= item != null && item.getCategoryId() == c.getCategoryId() ? "selected" : "" %>>
                            <%= HtmlUtil.escape(c.getCategoryName()) %>
                        </option>
                        <% } %>
                    </select>
                </div>
                <div class="col-12">
                    <label class="form-label">Address *</label>
                    <input type="text" name="address" class="form-control" maxlength="300" required value="<%= HtmlUtil.escape(item == null ? "" : item.getAddress()) %>">
                </div>
                <div class="col-12">
                    <label class="form-label">Description</label>
                    <textarea name="description" class="form-control" rows="4" maxlength="1000"><%= HtmlUtil.escape(item == null || item.getDescription() == null ? "" : item.getDescription()) %></textarea>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Estimated Cost</label>
                    <input type="number" name="estimatedCost" class="form-control" min="0" step="0.01" required value="<%= item == null || item.getEstimatedCost() == null ? "0" : item.getEstimatedCost() %>">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Rating</label>
                    <input type="number" name="rating" class="form-control" min="0" max="5" step="0.01" required value="<%= item == null || item.getRating() == null ? "0" : item.getRating() %>">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Opening Time</label>
                    <input type="time" name="openingTime" class="form-control" value="<%= item == null || item.getOpeningTime() == null ? "" : item.getOpeningTime().toString().substring(0,5) %>">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Closing Time</label>
                    <input type="time" name="closingTime" class="form-control" value="<%= item == null || item.getClosingTime() == null ? "" : item.getClosingTime().toString().substring(0,5) %>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Latitude</label>
                    <input type="number" name="latitude" class="form-control" min="-90" max="90" step="0.000001" value="<%= item == null || item.getLatitude() == null ? "" : item.getLatitude() %>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Longitude</label>
                    <input type="number" name="longitude" class="form-control" min="-180" max="180" step="0.000001" value="<%= item == null || item.getLongitude() == null ? "" : item.getLongitude() %>">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Place Type *</label>
                    <select name="placeType" class="form-select" required>
                        <option value="INDOOR" <%= item == null || "INDOOR".equals(item.getPlaceType()) ? "selected" : "" %>>INDOOR</option>
                        <option value="OUTDOOR" <%= item != null && "OUTDOOR".equals(item.getPlaceType()) ? "selected" : "" %>>OUTDOOR</option>
                    </select>
                </div>
            </div>

            <div class="d-flex justify-content-end gap-2 mt-4">
                <a href="<%= request.getContextPath() %>/admin/places" class="btn btn-outline-secondary">Cancel</a>
                <button type="submit" class="btn btn-primary"><%= editing ? "Save Changes" : "Create Place" %></button>
            </div>
        </form>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
