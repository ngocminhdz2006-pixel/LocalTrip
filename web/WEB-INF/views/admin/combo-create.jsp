<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib prefix="c"
           uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt"
           uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
    .combo-admin-heading {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        flex-wrap: wrap;
        gap: 16px;
        margin-bottom: 24px;
    }

    .combo-admin-section {
        margin-bottom: 24px;
    }

    .combo-admin-section h3 {
        font-size: 20px;
        margin-bottom: 16px;
    }

    .combo-admin-categories {
        display: flex;
        flex-wrap: wrap;
        gap: 12px 24px;
    }

    .combo-admin-activity {
        padding: 20px;
        margin-bottom: 16px;
        background: #F6F9F7;
        border: 1px solid var(--line);
        border-radius: 14px;
    }

    .combo-admin-activity-heading {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
    }
</style>

<div class="combo-admin-heading">
    <div>
        <h2>
            <c:out value="${editing ? 'Sửa combo bản nháp' : 'Tạo combo bản nháp'}"/>
        </h2>
        <p class="rd-sub">
            Xây dựng lịch mẫu với địa điểm cụ thể.
            Bản nháp chưa xuất hiện trong gợi ý cho người dùng.
        </p>
    </div>

    <a class="btn btn-outline-secondary"
       href="${pageContext.request.contextPath}/admin">
        Về trang quản trị
    </a>
</div>

<c:if test="${not empty error}">
    <div class="alert alert-danger" role="alert">
        <c:out value="${error}"/>
    </div>
</c:if>

<form method="post"
      action="${pageContext.request.contextPath}/admin/combos/${editing ? 'edit' : 'create'}"
      id="comboCreateForm">

    <c:if test="${editing}">
        <input type="hidden"
               name="id"
               value="${form.id}">

        <input type="hidden"
               name="revision"
               value="<c:out value='${editRevision}'/>">
    </c:if>
    <input type="hidden"
           name="csrfToken"
           value="<c:out value='${csrfToken}'/>">

    <section class="rd-card combo-admin-section">
        <h3>Thông tin combo</h3>

        <div class="mb-3">
            <label class="form-label" for="comboName">Tên combo</label>
            <input class="form-control"
                   id="comboName"
                   name="name"
                   maxlength="150"
                   value="<c:out value='${form.name}'/>"
                   required>
        </div>

        <div class="mb-3">
            <label class="form-label"
                   for="comboDescription">Mô tả</label>
            <textarea class="form-control"
                      id="comboDescription"
                      name="description"
                      rows="3"
                      maxlength="1000"><c:out value="${form.description}"/></textarea>
        </div>

        <div class="row">
            <div class="col-md-5 mb-3">
                <label class="form-label"
                       for="comboCity">Tỉnh/thành</label>
                <select class="form-select" id="comboCity" name="cityName" required>
                    <option value="">Chọn tỉnh/thành</option>
                    <c:forEach var="region" items="${comboRegions}">
                        <option value="<c:out value='${region.key}'/>"
                                ${form.cityName == region.key ? 'selected' : ''}>
                            <c:out value="${region.key}"/>
                        </option>
                    </c:forEach>
                    <c:if test="${not empty form.cityName and not comboRegions.containsKey(form.cityName)}">
                        <option value="<c:out value='${form.cityName}'/>" selected>
                            <c:out value="${form.cityName}"/> — không còn địa điểm đang sử dụng
                        </option>
                    </c:if>
                </select>
            </div>

            <div class="col-md-5 mb-3">
                <label class="form-label"
                       for="comboDistrict">Quận/huyện</label>
                <select class="form-select" id="comboDistrict" name="districtName" required
                        data-selected="<c:out value='${form.districtName}'/>">
                    <option value="">Chọn quận/huyện</option>
                </select>
            </div>

            <div class="col-md-2 mb-3">
                <label class="form-label"
                       for="comboDays">Số ngày</label>
                <input class="form-control"
                       type="number"
                       id="comboDays"
                       name="durationDays"
                       min="1"
                       max="14"
                       value="${form.durationDays}"
                       required>
            </div>
        </div>

        <p class="form-text">
            Khu vực được chọn từ dữ liệu địa điểm để khớp với chuyến đi.
            Lịch mẫu sử dụng Ngày 1, Ngày 2… chưa gắn ngày thực tế.
        </p>
    </section>

    <section class="rd-card combo-admin-section">
        <h3>Sở thích phù hợp</h3>

        <div class="combo-admin-categories">
            <c:forEach var="category" items="${categories}">
                <div class="form-check">
                    <input class="form-check-input"
                           type="checkbox"
                           name="categoryIds"
                           id="comboCategory${category.id}"
                           value="${category.id}"
                           <c:if test="${form.categoryIds.contains(category.id)}">
                               checked
                           </c:if>>

                    <label class="form-check-label"
                           for="comboCategory${category.id}">
                        <c:out value="${category.name}"/>
                    </label>
                </div>
            </c:forEach>
        </div>
    </section>

    <section class="rd-card combo-admin-section">
        <h3>Hoạt động trong combo</h3>

        <p class="rd-sub mb-3">
            Chi phí nhập theo mỗi người.
            Hai địa điểm khác nhau cần cách nhau ít nhất 15 phút.
            Đây là khoảng đệm tối thiểu, chưa phải thời gian tuyến đường.
        </p>

        <div id="comboActivities">
            <c:forEach var="activity" items="${form.activities}">
                <div class="combo-admin-activity">
                    <div class="combo-admin-activity-heading">
                        <strong>Hoạt động</strong>
                        <button type="button"
                                class="btn btn-sm btn-outline-danger"
                                data-remove-activity>
                            Bỏ
                        </button>
                    </div>

                    <div class="row">
                        <div class="col-md-2 mb-3">
                            <label class="form-label">Ngày</label>
                            <input class="form-control"
                                   type="number"
                                   name="dayNumber"
                                   min="1" max="14"
                                   value="${activity.dayNumber}"
                                   required>
                        </div>

                        <div class="col-md-3 mb-3">
                            <label class="form-label">Loại hoạt động</label>
                            <select class="form-select"
                                    name="activityType" required>
                                <option value="VISIT"
                                        ${activity.activityType == 'VISIT' ? 'selected' : ''}>
                                    Tham quan
                                </option>
                                <option value="MEAL"
                                        ${activity.activityType == 'MEAL' ? 'selected' : ''}>
                                    Ăn uống
                                </option>
                                <option value="CAFE"
                                        ${activity.activityType == 'CAFE' ? 'selected' : ''}>
                                    Cà phê
                                </option>
                                <option value="REST"
                                        ${activity.activityType == 'REST' ? 'selected' : ''}>
                                    Nghỉ
                                </option>
                            </select>
                        </div>

                        <div class="col-md-7 mb-3">
                            <label class="form-label">Địa điểm</label>
                            <select class="form-select" name="placeId">
                                <option value="">Không chọn — chỉ dành cho nghỉ</option>
                                <c:forEach var="place" items="${places}">
                                    <option value="${place.placeId}"
                                            ${activity.placeId == place.placeId ? 'selected' : ''}>
                                        <c:out value="${place.placeName}"/>
                                        — <c:out value="${place.address}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Tên hoạt động</label>
                        <input class="form-control"
                               name="activityTitle"
                               maxlength="200"
                               value="<c:out value='${activity.title}'/>"
                               required>
                    </div>

                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="form-label">Bắt đầu</label>
                            <input class="form-control"
                                   type="time"
                                   name="startTime"
                                   value="<fmt:formatDate value='${activity.startTime}' pattern='HH:mm'/>"
                                   required>
                        </div>

                        <div class="col-md-4 mb-3">
                            <label class="form-label">Kết thúc</label>
                            <input class="form-control"
                                   type="time"
                                   name="endTime"
                                   value="<fmt:formatDate value='${activity.endTime}' pattern='HH:mm'/>"
                                   required>
                        </div>

                        <div class="col-md-4 mb-3">
                            <label class="form-label">Chi phí/người (đ)</label>
                            <input class="form-control"
                                   type="number"
                                   name="cost"
                                   min="0" step="0.01"
                                   value="${activity.estimatedCostPerPerson}"
                                   required>
                        </div>
                    </div>

                    <label class="form-label">Ghi chú</label>
                    <textarea class="form-control"
                              name="note"
                              rows="2"
                              maxlength="500"><c:out value="${activity.note}"/></textarea>
                </div>
            </c:forEach>
        </div>

        <button type="button"
                class="btn btn-outline-secondary"
                id="addComboActivity">
            + Thêm hoạt động
        </button>
    </section>

    <div class="d-flex flex-wrap gap-2 mb-4">
        <button type="submit" class="btn btn-brand">
            <c:out value="${editing ? 'Lưu thay đổi bản nháp' : 'Lưu bản nháp'}"/>
        </button>

        <a class="btn btn-outline-secondary"
           href="${pageContext.request.contextPath}/admin">
            Hủy và quay lại
        </a>
    </div>
</form>

<template id="comboActivityTemplate">
    <div class="combo-admin-activity">
        <div class="combo-admin-activity-heading">
            <strong>Hoạt động</strong>
            <button type="button"
                    class="btn btn-sm btn-outline-danger"
                    data-remove-activity>
                Bỏ
            </button>
        </div>

        <div class="row">
            <div class="col-md-2 mb-3">
                <label class="form-label">Ngày</label>
                <input class="form-control"
                       type="number" name="dayNumber"
                       min="1" max="14" value="1" required>
            </div>

            <div class="col-md-3 mb-3">
                <label class="form-label">Loại hoạt động</label>
                <select class="form-select" name="activityType" required>
                    <option value="VISIT">Tham quan</option>
                    <option value="MEAL">Ăn uống</option>
                    <option value="CAFE">Cà phê</option>
                    <option value="REST">Nghỉ</option>
                </select>
            </div>

            <div class="col-md-7 mb-3">
                <label class="form-label">Địa điểm</label>
                <select class="form-select" name="placeId">
                    <option value="">Không chọn — chỉ dành cho nghỉ</option>
                    <c:forEach var="place" items="${places}">
                        <option value="${place.placeId}">
                            <c:out value="${place.placeName}"/>
                            — <c:out value="${place.address}"/>
                        </option>
                    </c:forEach>
                </select>
            </div>
        </div>

        <div class="mb-3">
            <label class="form-label">Tên hoạt động</label>
            <input class="form-control"
                   name="activityTitle" maxlength="200" required>
        </div>

        <div class="row">
            <div class="col-md-4 mb-3">
                <label class="form-label">Bắt đầu</label>
                <input class="form-control"
                       type="time" name="startTime" required>
            </div>

            <div class="col-md-4 mb-3">
                <label class="form-label">Kết thúc</label>
                <input class="form-control"
                       type="time" name="endTime" required>
            </div>

            <div class="col-md-4 mb-3">
                <label class="form-label">Chi phí/người (đ)</label>
                <input class="form-control"
                       type="number" name="cost"
                       min="0" step="0.01" value="0" required>
            </div>
        </div>

        <label class="form-label">Ghi chú</label>
        <textarea class="form-control"
                  name="note" rows="2" maxlength="500"></textarea>
    </div>
</template>

<script>
    (function () {
        const container = document.getElementById('comboActivities');
        const template = document.getElementById('comboActivityTemplate');
        const addButton = document.getElementById('addComboActivity');

        function addActivity() {
            if (container.children.length >= 60) {
                alert('Tối đa 60 hoạt động trong một combo.');
                return;
            }

            container.appendChild(template.content.cloneNode(true));
        }

        addButton.addEventListener('click', addActivity);

        container.addEventListener('click', function (event) {
            const button = event.target.closest('[data-remove-activity]');
            if (button) {
                button.closest('.combo-admin-activity').remove();
            }
        });

        document.getElementById('comboCreateForm')
                .addEventListener('submit', function (event) {
                    if (!container.children.length) {
                        event.preventDefault();
                        alert('Hãy thêm ít nhất một hoạt động.');
                    }
                });

        if (!container.children.length) {
            addActivity();
        }
    })();
</script>

<template id="comboRegionOptions">
    <c:forEach var="region" items="${comboRegions}">
        <c:forEach var="district" items="${region.value}">
            <option data-city="<c:out value='${region.key}'/>"
                    value="<c:out value='${district}'/>"><c:out value="${district}"/></option>
        </c:forEach>
    </c:forEach>
</template>

<script>
(function () {
    const city = document.getElementById('comboCity');
    const district = document.getElementById('comboDistrict');
    const options = Array.from(document.getElementById('comboRegionOptions').content.querySelectorAll('option'));
    function updateDistricts(saved) {
        district.replaceChildren(new Option('Chọn quận/huyện', ''));
        options.filter(option => option.dataset.city === city.value).forEach(option => {
            district.appendChild(new Option(option.textContent, option.value));
        });
        if (saved && !Array.from(district.options).some(option => option.value === saved)) {
            district.appendChild(new Option(saved + ' — kiểm tra lại dữ liệu địa điểm', saved));
        }
        district.value = saved || '';
    }
    city.addEventListener('change', () => updateDistricts(''));
    updateDistricts(district.dataset.selected);
})();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>