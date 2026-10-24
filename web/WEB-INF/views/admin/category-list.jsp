<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List,model.Category,utils.HtmlUtil" %>

<%
    List<Category> categories =
        (List<Category>) request.getAttribute("categories");

    String keyword = (String) request.getAttribute("keyword");

    if (keyword == null) {
        keyword = "";
    }

    request.setAttribute("pageTitle", "Category Management");
    request.setAttribute("tripRedesign", Boolean.TRUE);
%>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<section class="rd-hero mb-4">
    <div class="rd-hero-top">
        <div>
            <div class="small text-white-50 mb-2">
                LOCALTRIP · PLACE ADMINISTRATION
            </div>

            <h1 class="mb-2">Category Management</h1>

            <p class="text-white mb-0">
                Manage place categories used across the LocalTrip system.
            </p>
        </div>

        <div class="d-flex flex-wrap gap-2">
            <a class="rd-back"
               href="<%= request.getContextPath() %>/admin/categories/create">
                + Add Category
            </a>

            <a class="rd-back"
               href="<%= request.getContextPath() %>/admin">
                ← Admin Dashboard
            </a>
        </div>
    </div>
</section>

<section class="rd-card mb-4">
    <h2 class="h5 mb-3">Search Categories</h2>

    <form method="get"
          action="<%= request.getContextPath() %>/admin/categories">

        <div class="row g-3 align-items-end">
            <div class="col-12 col-lg-8">
                <label for="categoryKeyword"
                       class="form-label fw-semibold">
                    Category code or name
                </label>

                <input type="text"
                       id="categoryKeyword"
                       name="keyword"
                       class="form-control"
                       value="<%= HtmlUtil.escape(keyword) %>"
                       placeholder="Enter category code or name...">
            </div>

            <div class="col-12 col-lg-4">
                <div class="d-flex flex-wrap gap-2">
                    <button type="submit"
                            class="btn btn-primary">
                        Search
                    </button>

                    <a class="btn btn-outline-secondary"
                       href="<%= request.getContextPath() %>/admin/categories">
                        Clear Filters
                    </a>
                </div>
            </div>
        </div>
    </form>
</section>

<section class="rd-card">
    <div class="d-flex justify-content-between
                align-items-center flex-wrap gap-2 mb-4">
        <h2 class="h4 mb-0">Category List</h2>

        <span class="rd-count">
            <%= categories == null ? 0 : categories.size() %> results
        </span>
    </div>

    <% if (categories == null || categories.isEmpty()) { %>

        <div class="border-top pt-4">
            <p class="text-muted mb-0">
                No matching categories found. Try a different keyword or clear filters.
            </p>
        </div>

    <% } else { %>

        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th scope="col">ID</th>
                        <th scope="col">Category Code</th>
                        <th scope="col">Category Name</th>
                        <th scope="col" class="text-center">
                            Place Count
                        </th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>

                <tbody>
                    <% for (Category category : categories) { %>
                        <tr>
                            <td>
                                <%= category.getCategoryId() %>
                            </td>

                            <td>
                                <span class="rd-role">
                                    <%= HtmlUtil.escape(category.getCategoryCode()) %>
                                </span>
                            </td>

                            <td style="min-width:180px;overflow-wrap:anywhere;">
                                <strong>
                                    <%= HtmlUtil.escape(category.getIcon()) %>
                                    <%= HtmlUtil.escape(category.getCategoryName()) %>
                                </strong>
                            </td>

                            <td class="text-center">
                                <%= category.getPlaceCount() %>
                            </td>

                            <td style="min-width:200px;">
                                <div class="d-flex flex-wrap gap-2">
                                    <a class="btn btn-sm btn-outline-primary"
                                       href="<%= request.getContextPath() %>/admin/categories/edit?id=<%= category.getCategoryId() %>">
                                        Edit
                                    </a>

                                    <% if (category.getPlaceCount() == 0) { %>
                                        <form method="post"
                                              action="<%= request.getContextPath() %>/admin/categories/delete"
                                              onsubmit="return confirm('Are you sure you want to delete this category?');">

                                            <input type="hidden"
                                                   name="id"
                                                   value="<%= category.getCategoryId() %>">

                                            <button type="submit"
                                                    class="btn btn-sm btn-outline-danger">
                                                Delete
                                            </button>
                                        </form>
                                    <% } else { %>
                                        <button type="button"
                                                class="btn btn-sm btn-outline-secondary"
                                                disabled>
                                            In Use
                                        </button>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

    <% } %>
</section>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>