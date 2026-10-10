<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="pageTitle" value="Tổng quan chuyến đi" scope="request"/>
<c:set var="currentTrip" value="${trip}" scope="request"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-hero.jspf" %>
<%@ include file="/WEB-INF/jspf/trip-tabs.jspf" %>
<div class="rd-grid"><div class="rd-column">
<section class="rd-card"><div class="rd-card-heading"><div><h2>Thành viên chuyến đi</h2><p class="rd-sub">Các thành viên cùng lên kế hoạch và chia sẻ chi phí.</p></div><span class="rd-count">${fn:length(members)} người</span></div>
<c:choose><c:when test="${empty members}"><p class="rd-sub">Chưa có thông tin thành viên.</p></c:when><c:otherwise>
<ul class="rd-members"><c:forEach var="member" items="${members}"><li class="rd-member">
<span class="rd-avatar" aria-hidden="true"><c:out value="${fn:substring(member.fullName, 0, 1)}"/></span><div class="rd-member-name"><strong><c:out value="${member.fullName}"/></strong><span><c:out value="${member.email}"/></span></div>
<div class="rd-member-actions"><c:choose><c:when test="${member.role == 'OWNER'}"><span class="rd-role rd-role-lead">Trưởng nhóm</span></c:when><c:otherwise><span class="rd-role">Thành viên</span><c:if test="${trip.role == 'OWNER'}"><form method="post"
                                                          action="${pageContext.request.contextPath}/trip/member/remove"
                                                          onsubmit="return confirm('Xóa thành viên này khỏi chuyến đi?');">
                                                        <input type="hidden"
                                                               name="tripId"
                                                               value="${trip.id}">

                                                        <input type="hidden"
                                                               name="userId"
                                                               value="${member.userId}">

                                                        <button type="submit"
                                                                class="rd-remove" title="Xóa thành viên" aria-label="Xóa thành viên"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><path d="M4 7h16M10 11v6M14 11v6M6 7l1 12a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2l1-12M9 7V4h6v3"/></svg></button>
                                                    </form></c:if></c:otherwise></c:choose></div>
</li></c:forEach></ul></c:otherwise></c:choose></section>
<c:if test="${trip.role == 'OWNER'}"><section class="rd-card rd-add"><h2>Thêm thành viên</h2><p class="rd-sub">Thêm người đã có tài khoản LocalTrip bằng email.</p><form class="rd-add-form" method="post"
                          action="${pageContext.request.contextPath}/trip/member/add">
                        <input type="hidden"
                               name="tripId"
                               value="${trip.id}">

                        <div class="mb-3">
                            <label for="memberEmail" class="form-label">
                                Email thành viên
                            </label>

                            <input id="memberEmail"
                                   type="email"
                                   name="email"
                                   class="rd-input"
                                   maxlength="150"
                                   placeholder="email@localtrip.vn"
                                   autocomplete="email"
                                   required>
                        </div>

                        <button type="submit" class="rd-button rd-primary">
                            Thêm thành viên
                        </button>
                    </form></section></c:if>
</div><div class="rd-column"><c:choose><c:when test="${trip.role == 'OWNER'}">




<%
                        if (session.getAttribute("tripStatusToken") == null) {
                            session.setAttribute(
                                    "tripStatusToken",
                                    java.util.UUID.randomUUID().toString()
                            );
                        }
                    %>
<%
                            if (session.getAttribute("tripDeleteToken") == null) {
                                session.setAttribute(
                                        "tripDeleteToken",
                                        java.util.UUID.randomUUID().toString()
                                );
                            }
                        %>

<section class="rd-card"><h2>Quản lý chuyến đi</h2><p class="rd-sub">Cập nhật tên, thời gian, khu vực và ngân sách.</p><div class="rd-actions">
<c:choose><c:when test="${trip.status == 'PLANNING' or trip.status == 'ONGOING'}"><a href="${pageContext.request.contextPath}/trip/edit?tripId=${trip.id}" class="rd-button rd-secondary">Sửa thông tin chuyến đi</a></c:when><c:otherwise><p class="rd-sub">Chuyến đi đã hoàn thành hoặc đã hủy. Thông tin được giữ lại để xem.</p></c:otherwise></c:choose>
<c:if test="${trip.status == 'PLANNING'}"><form method="post"
                                  action="${pageContext.request.contextPath}/trip/status"
                                  onsubmit="return confirm('Xác nhận lịch trình hiện tại và bắt đầu chuyến đi?');">

                                <input type="hidden"
                                       name="tripId"
                                       value="${trip.id}">

                                <input type="hidden"
                                       name="status"
                                       value="ONGOING">

                                <input type="hidden"
                                       name="statusToken"
                                       value="${sessionScope.tripStatusToken}">

                                <button type="submit" class="rd-button rd-primary" ${viewCanStart ? '' : 'disabled aria-disabled="true"'} aria-describedby="start-reason">
                                    Bắt đầu chuyến đi
                                </button>
                            </form><c:if test="${not viewCanStart}"><p class="rd-help" id="start-reason"><c:out value="${viewStartReason}"/></p></c:if></c:if>
<c:if test="${trip.status == 'ONGOING'}"><form method="post"
                                  action="${pageContext.request.contextPath}/trip/status"
                                  onsubmit="return confirm('Đánh dấu chuyến đi đã hoàn thành?');">

                                <input type="hidden"
                                       name="tripId"
                                       value="${trip.id}">

                                <input type="hidden"
                                       name="status"
                                       value="COMPLETED">

                                <input type="hidden"
                                       name="statusToken"
                                       value="${sessionScope.tripStatusToken}">

                                <button type="submit" class="rd-button rd-primary">
                                    Hoàn thành chuyến đi
                                </button>
                            </form></c:if>
</div></section>
<c:if test="${trip.status == 'PLANNING' or trip.status == 'ONGOING'}"><section class="rd-danger"><h3>Hủy hoặc xóa chuyến đi</h3><p>Hủy chuyến đi sẽ giữ lại dữ liệu để xem.</p><form method="post"
                                    action="${pageContext.request.contextPath}/trip/status"
                                    onsubmit="return confirm('Hủy chuyến đi này? Dữ liệu hiện có vẫn được giữ lại.');">

                                  <input type="hidden"
                                         name="tripId"
                                         value="${trip.id}">

                                  <input type="hidden"
                                         name="status"
                                         value="CANCELLED">

                                  <input type="hidden"
                                         name="statusToken"
                                         value="${sessionScope.tripStatusToken}">

                                  <button type="submit"
                                          class="rd-button rd-danger-outline">
                                      Hủy chuyến đi
                                  </button>
                              </form><c:if test="${trip.role == 'OWNER' and trip.status == 'PLANNING'}"><p>Chỉ xóa được chuyến đang lên kế hoạch, chưa có chi phí hoặc tiền đóng quỹ. Lịch trình và sở thích của chuyến đi cũng sẽ bị xóa.</p><form method="post"
                                        action="${pageContext.request.contextPath}/trip/delete"
                                        onsubmit="return confirm('Xóa vĩnh viễn chuyến đi, lịch trình và sở thích của các thành viên?');">

                                      <input type="hidden"
                                             name="tripId"
                                             value="${trip.id}">

                                      <input type="hidden"
                                             name="deleteToken"
                                             value="${sessionScope.tripDeleteToken}">

                                      <button type="submit"
                                              class="rd-button rd-danger-solid">
                                          Xóa chuyến đi
                                      </button>
                                  </form></c:if></section></c:if>
</c:when><c:otherwise><section class="rd-card"><h2>Vai trò của bạn</h2><p class="rd-sub">Bạn tham gia với vai trò thành viên. Bạn có thể khai báo sở thích và xem kế hoạch của chuyến đi. Trưởng nhóm quản lý thông tin, thành viên và lịch trình.</p></section></c:otherwise></c:choose></div></div>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>


