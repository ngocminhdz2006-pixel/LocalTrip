<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib prefix="c"
           uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt"
           uri="http://java.sun.com/jsp/jstl/fmt" %>

<fmt:setLocale value="vi_VN" scope="page"/>
<%
    if (session.getAttribute("adminComboStatusToken") == null) {
        session.setAttribute(
                "adminComboStatusToken",
                java.util.UUID.randomUUID().toString()
        );
    }
%>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
    .combo-management-heading {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        flex-wrap: wrap;
        gap: 16px;
        margin-bottom: 24px;
    }

    .combo-management-status {
        display: inline-block;
        padding: 6px 12px;
        border-radius: 999px;
        font-size: 13px;
        font-weight: 600;
        white-space: nowrap;
    }

    .combo-management-status.DRAFT {
        background: #FFF0CE;
        color: #805500;
    }

    .combo-management-status.ACTIVE {
        background: var(--mint);
        color: var(--green);
    }

    .combo-management-status.INACTIVE {
        background: #EEF1EF;
        color: var(--ink2);
    }

    .combo-management-table {
        padding: 0;
        overflow: hidden;
    }

    .combo-management-table .table {
        min-width: 750px;
        margin-bottom: 0;
    }

    .combo-management-table th,
    .combo-management-table td {
        padding: 16px 20px;
        vertical-align: middle;
        border-color: var(--line);
    }

    .combo-management-table th {
        background: #F6F9F7;
        color: var(--ink2);
        white-space: nowrap;
    }

    .combo-detail-summary {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 16px;
        margin-bottom: 24px;
    }

    .combo-detail-summary .rd-card {
        padding: 20px;
    }

    .combo-detail-summary span {
        display: block;
        color: var(--ink2);
        margin-bottom: 8px;
    }

    .combo-detail-summary strong {
        color: var(--green);
        font-size: 20px;
    }

    .combo-detail-description {
        white-space: pre-wrap;
        overflow-wrap: anywhere;
    }

    .combo-detail-tags {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-top: 16px;
    }

    .combo-detail-tag {
        padding: 6px 12px;
        border-radius: 999px;
        background: var(--mint);
        color: var(--green);
    }

    .combo-management-empty {
        padding: 48px 24px;
        text-align: center;
    }

    @media (max-width: 700px) {
        .combo-detail-summary {
            grid-template-columns: 1fr;
        }
    }
</style>

<c:choose>
    <c:when test="${empty selectedCombo}">
        <div class="combo-management-heading">
            <div>
                <h2>Quản lý combo</h2>
                <p class="rd-sub">
                    Kiểm tra lịch mẫu trước khi đưa vào gợi ý cho người dùng.
                </p>
            </div>

            <a class="btn btn-brand"
               href="${pageContext.request.contextPath}/admin/combos/create">
                + Tạo combo
            </a>
        </div>

        <c:choose>
            <c:when test="${empty combos}">
                <div class="rd-card combo-management-empty">
                    <h3>Chưa có combo mẫu</h3>
                    <p class="rd-sub mb-3">
                        Tạo bản nháp đầu tiên với địa điểm
                        và hoạt động theo từng ngày.
                    </p>

                    <a class="btn btn-brand"
                       href="${pageContext.request.contextPath}/admin/combos/create">
                        Tạo combo đầu tiên
                    </a>
                </div>
            </c:when>

            <c:otherwise>
                <div class="rd-card combo-management-table">
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead>
                                <tr>
                                    <th>Combo</th>
                                    <th>Khu vực</th>
                                    <th>Số ngày</th>
                                    <th>Chi phí/người</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>

                            <tbody>
                                <c:forEach var="combo" items="${combos}">
                                    <tr>
                                        <td>
                                            <strong>
                                                <c:out value="${combo.name}"/>
                                            </strong>
                                            <div class="small text-muted">
                                                Mã #${combo.id}
                                            </div>
                                        </td>

                                        <td>
                                            <c:out value="${combo.districtName}"/>,
                                            <c:out value="${combo.cityName}"/>
                                        </td>

                                        <td>${combo.durationDays} ngày</td>

                                        <td class="text-nowrap">
                                            <fmt:formatNumber
                                                value="${combo.estimatedCostPerPerson}"
                                                maxFractionDigits="0"/> đ
                                        </td>

                                        <td>
                                            <span class="combo-management-status ${combo.status}">
                                                <c:choose>
                                                    <c:when test="${combo.status == 'ACTIVE'}">
                                                        Đang sử dụng
                                                    </c:when>
                                                    <c:when test="${combo.status == 'INACTIVE'}">
                                                        Ngừng sử dụng
                                                    </c:when>
                                                    <c:otherwise>
                                                        Bản nháp
                                                    </c:otherwise>
                                                </c:choose>
                                            </span>
                                        </td>

                                        <td>
                                            <a class="btn btn-sm btn-outline-secondary"
                                               href="${pageContext.request.contextPath}/admin/combos/detail?id=${combo.id}">
                                                Xem chi tiết
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </c:when>

    <c:otherwise>
        <div class="combo-management-heading">
            <div>
                <h2><c:out value="${selectedCombo.name}"/></h2>
                <p class="rd-sub">
                    Combo mẫu #${selectedCombo.id}
                </p>
            </div>

            <a class="btn btn-outline-secondary"
               href="${pageContext.request.contextPath}/admin/combos">
                Quay lại danh sách
            </a>
        </div>

        <div class="combo-detail-summary">
            <div class="rd-card">
                <span>Khu vực</span>
                <strong>
                    <c:out value="${selectedCombo.districtName}"/>,
                    <c:out value="${selectedCombo.cityName}"/>
                </strong>
            </div>

            <div class="rd-card">
                <span>Thời lượng</span>
                <strong>${selectedCombo.durationDays} ngày</strong>
            </div>

            <div class="rd-card">
                <span>Chi phí dự kiến mỗi người</span>
                <strong>
                    <fmt:formatNumber
                        value="${selectedCombo.estimatedCostPerPerson}"
                        maxFractionDigits="0"/> đ
                </strong>
            </div>
        </div>
        <section class="rd-card mb-4">
            <h3 class="h5 mb-2">Trạng thái sử dụng</h3>
            <c:if test="${selectedCombo.status == 'DRAFT'
                          or selectedCombo.status == 'INACTIVE'}">
                  <div class="my-3">
                      <a class="btn btn-outline-secondary"
                         href="${pageContext.request.contextPath}/admin/combos/edit?id=${selectedCombo.id}">
                          Sửa combo
                      </a>
                  </div>
            </c:if>
            <c:choose>
                <c:when test="${selectedCombo.status == 'ACTIVE'}">
                    <p class="rd-sub mb-3">
                        Ngừng sử dụng sẽ loại combo khỏi các gợi ý mới.
                        Lịch chuyến đã được lưu từ combo vẫn được giữ nguyên.
                    </p>

                    <form method="post"
                          action="${pageContext.request.contextPath}/admin/combos/status"
                          onsubmit="return confirm('Ngừng sử dụng combo này?');">

                        <input type="hidden"
                               name="csrfToken"
                               value="<c:out value='${sessionScope.adminComboStatusToken}'/>">

                        <input type="hidden"
                               name="id"
                               value="${selectedCombo.id}">

                        <input type="hidden"
                               name="expectedStatus"
                               value="${selectedCombo.status}">

                        <input type="hidden"
                               name="newStatus"
                               value="INACTIVE">

                        <button class="btn btn-outline-danger" type="submit">
                            Ngừng sử dụng
                        </button>
                    </form>
                </c:when>

                <c:otherwise>
                    <p class="rd-sub mb-3">
                        Hệ thống kiểm tra hoạt động từng ngày, bữa ăn,
                        thời gian nghỉ, địa điểm và giờ trước khi kích hoạt.
                    </p>

                    <form method="post"
                          action="${pageContext.request.contextPath}/admin/combos/status"
                          onsubmit="return confirm('Kiểm tra và kích hoạt combo này?');">

                        <input type="hidden"
                               name="csrfToken"
                               value="<c:out value='${sessionScope.adminComboStatusToken}'/>">

                        <input type="hidden"
                               name="id"
                               value="${selectedCombo.id}">

                        <input type="hidden"
                               name="expectedStatus"
                               value="${selectedCombo.status}">

                        <input type="hidden"
                               name="newStatus"
                               value="ACTIVE">

                        <button class="btn btn-brand" type="submit">
                            Kiểm tra và kích hoạt
                        </button>
                    </form>
                </c:otherwise>
            </c:choose>
        </section>
        <section class="rd-card mb-4">
            <div class="d-flex flex-wrap align-items-center gap-3 mb-3">
                <h3 class="h5 mb-0">Thông tin combo</h3>

                <span class="combo-management-status ${selectedCombo.status}">
                    <c:choose>
                        <c:when test="${selectedCombo.status == 'ACTIVE'}">
                            Đang sử dụng
                        </c:when>
                        <c:when test="${selectedCombo.status == 'INACTIVE'}">
                            Ngừng sử dụng
                        </c:when>
                        <c:otherwise>
                            Bản nháp
                        </c:otherwise>
                    </c:choose>
                </span>
            </div>

            <c:choose>
                <c:when test="${not empty selectedCombo.description}">
                    <p class="combo-detail-description"><c:out value="${selectedCombo.description}"/></p>
                </c:when>
                <c:otherwise>
                    <p class="rd-sub">Chưa có mô tả.</p>
                </c:otherwise>
            </c:choose>

            <div class="combo-detail-tags">
                <c:forEach var="categoryId"
                           items="${selectedCombo.categoryIds}">
                    <span class="combo-detail-tag">
                        <c:out value="${categoryNames[categoryId]}"/>
                    </span>
                </c:forEach>
            </div>
        </section>

        <div class="rd-card mb-3">
            <h3 class="h5 mb-2">Hoạt động theo ngày</h3>
            <p class="rd-sub">
                Ngày 1, Ngày 2… là ngày tương đối của lịch mẫu.
                Chi phí bên dưới tính cho mỗi người.
            </p>
        </div>

        <c:choose>
            <c:when test="${empty selectedCombo.activities}">
                <div class="rd-card combo-management-empty">
                    Combo chưa có hoạt động.
                </div>
            </c:when>

            <c:otherwise>
                <div class="rd-card combo-management-table">
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Ngày</th>
                                    <th>Giờ</th>
                                    <th>Hoạt động</th>
                                    <th>Địa điểm</th>
                                    <th>Chi phí/người</th>
                                    <th>Ghi chú</th>
                                </tr>
                            </thead>

                            <tbody>
                                <c:forEach var="activity"
                                           items="${selectedCombo.activities}">
                                    <tr>
                                        <td class="text-nowrap">
                                            Ngày ${activity.dayNumber}
                                        </td>

                                        <td class="text-nowrap">
                                            <fmt:formatDate
                                                value="${activity.startTime}"
                                                pattern="HH:mm"/>
                                            –
                                            <fmt:formatDate
                                                value="${activity.endTime}"
                                                pattern="HH:mm"/>
                                        </td>

                                        <td>
                                            <strong>
                                                <c:out value="${activity.title}"/>
                                            </strong>

                                            <div class="small text-muted">
                                                <c:choose>
                                                    <c:when test="${activity.activityType == 'MEAL'}">
                                                        Ăn uống
                                                    </c:when>
                                                    <c:when test="${activity.activityType == 'CAFE'}">
                                                        Cà phê
                                                    </c:when>
                                                    <c:when test="${activity.activityType == 'REST'}">
                                                        Nghỉ
                                                    </c:when>
                                                    <c:otherwise>
                                                        Tham quan
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty activity.placeId}">
                                                    <c:out value="${activity.placeName}"/>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">
                                                        Không gắn địa điểm
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td class="text-nowrap">
                                            <fmt:formatNumber
                                                value="${activity.estimatedCostPerPerson}"
                                                maxFractionDigits="0"/> đ
                                        </td>

                                        <td>
                                            <c:out value="${activity.note}"/>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>