<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="model.Category,utils.HtmlUtil" %>

<%
    Category item = (Category) request.getAttribute("item");
    boolean editing = item != null;

    String formTitle = editing ? "Edit Category" : "Add Category";

    String codeValue = request.getParameter("categoryCode");
    String nameValue = request.getParameter("categoryName");

    if (codeValue == null) {
        codeValue = editing ? item.getCategoryCode() : "";
    }

    if (nameValue == null) {
        nameValue = editing ? item.getCategoryName() : "";
    }

    request.setAttribute("pageTitle", formTitle);
    request.setAttribute("tripRedesign", Boolean.TRUE);
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-hero mb-4">
    <div class="rd-hero-top">
        <div>
            <div class="small text-white-50 mb-2">
                LOCALTRIP · PLACE ADMINISTRATION
            </div>

            <h1 class="mb-2"><%= formTitle %></h1>

            <p class="text-white mb-0">
                Manage categories to classify places across LocalTrip.
            </p>
        </div>

        <a class="rd-back"
           href="<%= request.getContextPath() %>/admin/categories">
            ← Category List
        </a>
    </div>
</section>

<div class="row justify-content-center">
    <div class="col-12 col-lg-8">
        <section class="rd-card">
            <h2 class="h4 mb-2">Category Information</h2>

            <p class="text-muted mb-4">
                Enter unique code and display name for this category.
            </p>

            <form method="post"
                  action="<%= request.getContextPath() %>/admin/categories/<%= editing ? "edit" : "create" %>">

                <% if (editing) { %>
                    <input type="hidden"
                           name="categoryId"
                           value="<%= item.getCategoryId() %>">
                <% } %>

                <div class="mb-4">
                    <label for="categoryCode"
                           class="form-label fw-semibold">
                        Category Code
                    </label>

                    <input type="text"
                           id="categoryCode"
                           name="categoryCode"
                           class="form-control"
                           maxlength="50"
                           value="<%= HtmlUtil.escape(codeValue) %>"
                           placeholder="e.g. FOOD, NATURE, SHOPPING"
                           aria-describedby="categoryCodeHelp"
                           required>

                    <div id="categoryCodeHelp" class="form-text">
                        Letters, numbers, hyphens or underscores only.
                    </div>
                </div>

                <div class="mb-4">
                    <label for="categoryName"
                           class="form-label fw-semibold">
                        Category Name
                    </label>

                    <input type="text"
                           id="categoryName"
                           name="categoryName"
                           class="form-control"
                           maxlength="100"
                           value="<%= HtmlUtil.escape(nameValue) %>"
                           placeholder="e.g. Dining & Street Food"
                           required>
                </div>

                <div class="border-top pt-4 d-flex flex-wrap gap-2">
                    <button type="submit"
                            class="btn btn-primary px-4">
                        <%= editing ? "Save Changes" : "Create Category" %>
                    </button>

                    <a class="btn btn-outline-secondary px-4"
                       href="<%= request.getContextPath() %>/admin/categories">
                        Cancel
                    </a>
                </div>
            </form>
        </section>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>