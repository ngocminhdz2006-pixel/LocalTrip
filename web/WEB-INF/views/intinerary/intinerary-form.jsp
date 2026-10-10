<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Thêm vào lịch trình" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>

<fmt:setLocale value="vi_VN" scope="page"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>

<style>
    .rd-activity-form {
        max-width: 860px;
        margin: 0 auto;
    }

    .rd-activity-heading {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        flex-wrap: wrap;
        gap: 16px;
        margin-bottom: 24px;
    }

    .rd-activity-heading h2 {
        margin: 0 0 8px;
        color: var(--ink);
        font-size: 24px;
        font-weight: 700;
    }

    .rd-activity-place {
        padding: 18px 20px;
        margin-bottom: 24px;
        background: var(--mint);
        border: 1px solid var(--line);
        border-radius: 14px;
    }

    .rd-activity-place-label {
        margin-bottom: 6px;
        color: var(--ink2);
        font-size: 13px;
    }

    .rd-activity-place h3 {
        margin: 0 0 8px;
        color: var(--green);
        font-size: 20px;
        font-weight: 700;
    }

    .rd-activity-place p {
        margin: 0;
        color: var(--ink2);
    }

    .rd-activity-form .form-label {
        color: var(--ink);
        font-weight: 600;
    }

    .rd-activity-form .form-control {
        min-height: 46px;
        border-radius: 10px;
    }

    .rd-activity-form textarea.form-control {
        min-height: 110px;
    }

    .rd-activity-form .form-text {
        margin-top: 8px;
        color: var(--ink2);
    }

    .rd-activity-actions {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        padding-top: 20px;
        border-top: 1px solid var(--line);
    }

    @media (max-width: 600px) {
        .rd-activity-heading h2 {
            font-size: 21px;
        }

        .rd-activity-actions .btn {
            width: 100%;
        }
    }
</style>


<div class="row justify-content-center">
    <div class="col-lg-7">

        <div class="rd-activity-form">
            <div>
                <div class="rd-activity-heading">
                    <div>
                        <h2>Thêm hoạt động</h2>
                        <p class="rd-sub">
                            Chọn ngày, thời gian và chi phí cho địa điểm bạn muốn ghé thăm.
                        </p>
                    </div>

                    <a href="${pageContext.request.contextPath}/recommendations?tripId=${trip.id}"
                       class="btn btn-outline-secondary">
                        Quay lại gợi ý
                    </a>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <c:out value="${error}"/>
                    </div>
                </c:if>

                <div class="rd-card">

                    <div class="rd-activity-place">
                        <div class="rd-activity-place-label">
                            Địa điểm đã chọn
                        </div>

                        <h3><c:out value="${place.name}"/></h3>

                        <p>
                            Chi phí tham khảo:
                            <strong>
                                <fmt:formatNumber value="${place.estimatedPrice}"
                                                  maxFractionDigits="0"/> đ
                            </strong>
                        </p>
                    </div>

                    <form method="post"
                          action="${pageContext.request.contextPath}/itinerary/add">

                        <input type="hidden"
                               name="tripId"
                               value="${trip.id}">

                        <input type="hidden"
                               name="placeId"
                               value="${place.id}">

                        <div class="mb-3">
                            <label class="form-label">
                                Ngày tham quan
                            </label>

                            <input type="date"
                                   name="visitDate"
                                   class="form-control"
                                   min="${trip.startDate}"
                                   max="${trip.endDate}"
                                   value="${param.visitDate}"
                                   required>

                            <div class="form-text">
                                Ngày phải nằm trong khoảng từ
                                ${trip.startDate} đến ${trip.endDate}.
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">
                                    Giờ bắt đầu
                                </label>

                                <input type="time"
                                       name="startTime"
                                       class="form-control"
                                       value="${param.startTime}"
                                       required>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label">
                                    Giờ kết thúc
                                </label>

                                <input type="time"
                                       name="endTime"
                                       class="form-control"
                                       value="${param.endTime}"
                                       required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">
                                Chi phí dự kiến
                            </label>

                            <input type="number"
                                   name="estimatedCost"
                                   class="form-control"
                                   min="0"
                                   step="1000"
                                   value="${not empty param.estimatedCost
                                            ? param.estimatedCost
                                            : place.estimatedPrice}"
                                   required>
                        </div>

                        <div class="mb-4">
                            <label class="form-label">
                                Ghi chú
                            </label>

                            <textarea name="note"
                                      class="form-control"
                                      rows="3"
                                      maxlength="500"
                                      placeholder="Ví dụ: Chuẩn bị vé, tập trung trước 15 phút..."><c:out value="${param.note}"/></textarea>
                        </div>

                        <div class="rd-activity-actions">
                            <button type="submit" class="btn btn-brand">
                                Thêm vào lịch trình
                            </button>

                            <a href="${pageContext.request.contextPath}/itinerary?tripId=${trip.id}"
                               class="btn btn-outline-secondary">
                                Hủy và quay lại
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <%@ include file="/WEB-INF/views/common/footer.jsp" %>