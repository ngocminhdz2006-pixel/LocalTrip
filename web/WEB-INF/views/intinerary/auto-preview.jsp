<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Xem trước lịch trình mới" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<fmt:setLocale value="vi_VN" scope="page"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<style>
    .rd-preview-heading {
        margin-bottom: 24px;
    }

    .rd-preview-heading h2 {
        margin: 0 0 8px;
        color: var(--ink);
        font-size: 24px;
        font-weight: 700;
    }

    .rd-preview-notice {
        padding: 20px;
        margin-bottom: 24px;
        background: var(--mint);
        border: 1px solid var(--line);
        border-radius: 14px;
        color: var(--ink2);
        line-height: 1.7;
    }

    .rd-preview-notice strong {
        color: var(--green);
    }

    .rd-preview-stats {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 16px;
        margin-bottom: 24px;
    }

    .rd-preview-stat {
        padding: 22px;
        background: #fff;
        border: 1px solid var(--line);
        border-radius: 18px;
    }

    .rd-preview-stat span {
        display: block;
        margin-bottom: 10px;
        color: var(--ink2);
        font-size: 14px;
    }

    .rd-preview-stat strong {
        color: var(--green);
        font-size: 26px;
        font-weight: 700;
    }

    .rd-preview-table {
        margin-bottom: 24px;
    }

    .rd-preview-table h2 {
        font-size: 20px;
    }

    .rd-preview-table .table {
        margin-bottom: 0;
    }

    .rd-preview-old summary {
        color: var(--ink);
        font-weight: 600;
        cursor: pointer;
    }

    .rd-preview-confirm {
        margin-bottom: 24px;
    }

    .rd-preview-confirm h2 {
        font-size: 20px;
    }

    .rd-preview-actions {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        margin-top: 20px;
    }

    @media (max-width: 700px) {
        .rd-preview-stats {
            grid-template-columns: 1fr;
        }

        .rd-preview-heading h2 {
            font-size: 21px;
        }

        .rd-preview-actions .btn {
            width: 100%;
        }
    }
</style>
<div class="rd-preview-heading">
    <h2>Xem trước lịch trình mới</h2>
    <p class="rd-sub">
        Kiểm tra lịch được đề xuất theo sở thích hiện tại của nhóm
        trước khi xác nhận.
    </p>
</div>

<div class="rd-preview-notice">
    <strong>Lịch đang lưu chưa thay đổi.</strong><br>

    Khi xác nhận, các hoạt động từ
    <strong>
        <fmt:formatDate value="${draft.fromDate}"
                        pattern="dd/MM/yyyy"/>
    </strong>
    trở đi sẽ được thay thế bằng lịch mới.

    Các ngày đã qua được giữ lại.
    Bản xem trước có hiệu lực trong 30 phút.
</div>
<div class="rd-preview-stats">
    <div class="rd-preview-stat">
        <span>Hoạt động đang lưu trong phần sẽ thay thế</span>
        <strong>
            <c:out value="${oldItems.size()}"/>
        </strong>
    </div>

    <div class="rd-preview-stat">
        <span>Hoạt động trong lịch mới</span>
        <strong>
            <c:out value="${draft.items.size()}"/>
        </strong>
    </div>

    <div class="rd-preview-stat">
        <span>Chi phí dự kiến của lịch mới</span>
        <strong>
            <fmt:formatNumber value="${draftTotal}"
                              maxFractionDigits="0"/> đ
        </strong>
    </div>
</div>
<div class="rd-card rd-preview-table">
    <div class="rd-card-heading">
        <div>
            <h2>Lịch trình mới</h2>
            <p class="rd-sub">
                Kiểm tra ngày, giờ và địa điểm trước khi xác nhận.
                Ngày không có hoạt động sẽ không có lịch sau khi thay thế.
            </p>
        </div>
    </div>
    <div class="table-responsive"><table class="table">
            <thead><tr><th>Ngày</th><th>Giờ</th><th>Địa điểm</th><th>Hoạt động</th><th>Chi phí</th></tr></thead>
            <tbody><c:forEach var="item" items="${draft.items}"><tr>
                        <td><fmt:formatDate value="${item.visitDate}" pattern="dd/MM/yyyy"/></td>
                        <td><fmt:formatDate value="${item.startTime}" pattern="HH:mm"/> – <fmt:formatDate value="${item.endTime}" pattern="HH:mm"/></td>
                        <td><c:out value="${item.placeName}"/></td><td><c:out value="${item.note}"/></td>
                        <td><fmt:formatNumber value="${item.estimatedCost}" maxFractionDigits="0"/> đ</td>
                    </tr></c:forEach></tbody>
            </table></div>
    </div>
    <details class="rd-card rd-preview-old mb-4"><summary>Xem lịch đang lưu trong phần sẽ thay thế</summary>
        <div class="table-responsive mt-3"><table class="table"><thead><tr><th>Ngày</th><th>Giờ</th><th>Địa điểm</th></tr></thead><tbody>
                <c:forEach var="item" items="${oldItems}"><tr><td><fmt:formatDate value="${item.visitDate}" pattern="dd/MM/yyyy"/></td><td><fmt:formatDate value="${item.startTime}" pattern="HH:mm"/> – <fmt:formatDate value="${item.endTime}" pattern="HH:mm"/></td><td><c:out value="${item.placeName}"/></td></tr></c:forEach>
                </tbody></table></div>
    </details>
    <div class="rd-card rd-preview-confirm">
        <div class="rd-card-heading">
            <div>
                <h2>Xác nhận lịch trình</h2>
                <p class="rd-sub">
                    Xác nhận để thay thế phần lịch cũ đã nêu ở trên,
                    hoặc tạo lại theo sở thích mới nhất của nhóm.
                </p>
            </div>
        </div>

        <form method="post"
              action="${pageContext.request.contextPath}/itinerary/auto"
        class="rd-preview-actions">

        <input type="hidden"
               name="tripId"
               value="${trip.id}">

        <input type="hidden"
               name="autoToken"
               value="<c:out value='${sessionScope.autoItineraryToken}'/>">

        <input type="hidden"
               name="draftToken"
               value="<c:out value='${draft.token}'/>">

        <button type="submit"
                name="action"
                value="confirm"
                class="btn btn-brand"
                onclick="return confirm('Thay thế phần lịch từ ngày đã ghi bằng bản xem trước này?');">
            Xác nhận thay thế lịch cũ
        </button>

        <button type="submit"
                name="action"
                value="generate"
                class="btn btn-outline-primary">
            Tạo lại theo sở thích mới nhất
        </button>

        <button type="submit"
                name="action"
                value="cancel"
                class="btn btn-outline-secondary">
            Hủy bản xem trước
        </button>
    </form>
</div>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
