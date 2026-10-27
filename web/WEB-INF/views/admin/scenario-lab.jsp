<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container py-4">
    <!-- Header & Badge -->
    <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 pb-3 mb-4 border-bottom">
        <div>
            <h1 class="h3 mb-1 text-primary d-flex align-items-center gap-2">
                <span>🧪</span> Scenario Lab
            </h1>
            <p class="text-muted mb-0">
                Isolated trip simulation and fixture testing for development and demo environments.
            </p>
        </div>
        <div class="d-flex align-items-center gap-2">
            <span class="badge bg-success-subtle text-success border border-success px-3 py-2 fs-6">
                ENV: Non-Production
            </span>
            <span class="badge bg-primary-subtle text-primary border border-primary px-3 py-2 fs-6">
                Today: <c:out value="${simToday}" />
            </span>
        </div>
    </div>

    <!-- Result Summary Banner if Scenario was just created -->
    <c:if test="${not empty scenarioResult}">
        <div class="card border-success shadow-sm mb-4">
            <div class="card-header bg-success text-white fw-bold d-flex justify-content-between align-items-center">
                <span>🎉 Scenario <c:out value="${scenarioResult.scenarioCode}" /> Generated Successfully!</span>
                <span class="badge bg-light text-dark font-monospace"><c:out value="${scenarioResult.batchId}" /></span>
            </div>
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-7">
                        <h5 class="card-title text-success mb-2">
                            <a href="${pageContext.request.contextPath}/trip/detail?tripId=${scenarioResult.tripId}" class="text-decoration-underline text-success">
                                <c:out value="${scenarioResult.tripName}" />
                            </a>
                        </h5>
                        <p class="text-muted small mb-2"><c:out value="${scenarioResult.message}" /></p>
                        <ul class="list-unstyled mb-0 small">
                            <li><strong>Trip ID:</strong> <c:out value="${scenarioResult.tripId}" /></li>
                            <li><strong>Dates:</strong> <c:out value="${scenarioResult.startDate}" /> &rarr; <c:out value="${scenarioResult.endDate}" /></li>
                            <li><strong>Status:</strong> <span class="badge bg-secondary"><c:out value="${scenarioResult.status}" /></span></li>
                            <li><strong>Activities:</strong> <c:out value="${scenarioResult.activityCount}" /> item(s)</li>
                        </ul>
                    </div>
                    <div class="col-md-5 border-start-md ps-md-4">
                        <h6 class="fw-bold mb-2">Simulated Accounts (Password: <code>123456</code>)</h6>
                        <div class="p-2 bg-light rounded font-monospace small">
                            <div><strong>Owner:</strong> <c:out value="${scenarioResult.ownerEmail}" /></div>
                            <c:forEach var="mem" items="${scenarioResult.memberEmails}">
                                <div><strong>Member:</strong> <c:out value="${mem}" /></div>
                            </c:forEach>
                        </div>
                        <div class="mt-3 d-flex gap-2">
                            <a href="${pageContext.request.contextPath}/trip/detail?tripId=${scenarioResult.tripId}" class="btn btn-sm btn-outline-success">
                                View Trip &rarr;
                            </a>
                            <a href="${pageContext.request.contextPath}/itinerary?tripId=${scenarioResult.tripId}" class="btn btn-sm btn-outline-primary">
                                View Itinerary &rarr;
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </c:if>

    <!-- SECTION 1: SCENARIO LOADER -->
    <div class="card shadow-sm mb-4">
        <div class="card-header bg-white py-3">
            <h5 class="card-title mb-0 fw-bold d-flex align-items-center gap-2">
                <span>🚀</span> 1. Scenario Loader
            </h5>
            <small class="text-muted">Generate full trips in specific lifecycle states with isolated test users.</small>
        </div>
        <div class="card-body">
            <div class="row g-4">
                <!-- Scenario A -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border">
                        <div class="card-body d-flex flex-column">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h6 class="fw-bold mb-0">Scenario A: Planning, Empty</h6>
                                <span class="badge bg-secondary">PLANNING</span>
                            </div>
                            <p class="text-muted small flex-grow-1">
                                Departure in 7 days. 0 activities. Clean slate ready to add places and companions.
                            </p>
                            <form method="POST" action="${pageContext.request.contextPath}/admin/lab" class="mt-auto">
                                <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                <input type="hidden" name="action" value="load_scenario">
                                <input type="hidden" name="scenario" value="A">
                                <div class="input-group input-group-sm mb-2">
                                    <label class="input-group-text" for="memA">Members</label>
                                    <select class="form-select" id="memA" name="memberCount">
                                        <option value="1">1 (Owner only)</option>
                                        <option value="2">2 members</option>
                                        <option value="3" selected>3 members</option>
                                        <option value="4">4 members</option>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-sm btn-primary w-100">
                                    Create Scenario A
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Scenario B -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border border-info">
                        <div class="card-body d-flex flex-column">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h6 class="fw-bold mb-0 text-info-emphasis">Scenario B: Planning, Ready</h6>
                                <span class="badge bg-info text-dark">PLANNING</span>
                            </div>
                            <p class="text-muted small flex-grow-1">
                                Starts TODAY with full upcoming schedule (6 places). Ready to click <strong>Start Trip</strong>.
                            </p>
                            <form method="POST" action="${pageContext.request.contextPath}/admin/lab" class="mt-auto">
                                <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                <input type="hidden" name="action" value="load_scenario">
                                <input type="hidden" name="scenario" value="B">
                                <div class="input-group input-group-sm mb-2">
                                    <label class="input-group-text" for="memB">Members</label>
                                    <select class="form-select" id="memB" name="memberCount">
                                        <option value="2">2 members</option>
                                        <option value="3">3 members</option>
                                        <option value="4" selected>4 members</option>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-sm btn-info text-dark w-100">
                                    Create Scenario B
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Scenario C -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border border-success">
                        <div class="card-body d-flex flex-column">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h6 class="fw-bold mb-0 text-success">Scenario C: Ongoing, Live</h6>
                                <span class="badge bg-success">ONGOING</span>
                            </div>
                            <p class="text-muted small flex-grow-1">
                                Spans today. Activities across all 4 statuses: completed, 1 IN_PROGRESS, upcoming, cancelled.
                            </p>
                            <form method="POST" action="${pageContext.request.contextPath}/admin/lab" class="mt-auto">
                                <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                <input type="hidden" name="action" value="load_scenario">
                                <input type="hidden" name="scenario" value="C">
                                <div class="input-group input-group-sm mb-2">
                                    <label class="input-group-text" for="memC">Members</label>
                                    <select class="form-select" id="memC" name="memberCount">
                                        <option value="2">2 members</option>
                                        <option value="3" selected>3 members</option>
                                        <option value="4">4 members</option>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-sm btn-success w-100">
                                    Create Scenario C
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Scenario D -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border border-warning">
                        <div class="card-body d-flex flex-column">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h6 class="fw-bold mb-0 text-warning-emphasis">Scenario D: Ongoing, Ended</h6>
                                <span class="badge bg-warning text-dark">ONGOING</span>
                            </div>
                            <p class="text-muted small flex-grow-1">
                                Status is ONGOING but end_date was yesterday. Triggers the persistent <strong>Trip ended</strong> banner.
                            </p>
                            <form method="POST" action="${pageContext.request.contextPath}/admin/lab" class="mt-auto">
                                <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                <input type="hidden" name="action" value="load_scenario">
                                <input type="hidden" name="scenario" value="D">
                                <div class="input-group input-group-sm mb-2">
                                    <label class="input-group-text" for="memD">Members</label>
                                    <select class="form-select" id="memD" name="memberCount">
                                        <option value="2" selected>2 members</option>
                                        <option value="3">3 members</option>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-sm btn-warning text-dark w-100">
                                    Create Scenario D
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Scenario E -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border border-primary">
                        <div class="card-body d-flex flex-column">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h6 class="fw-bold mb-0 text-primary">Scenario E: Completed, Settle</h6>
                                <span class="badge bg-primary">COMPLETED</span>
                            </div>
                            <p class="text-muted small flex-grow-1">
                                Completed trip with group fund, equal & unequal splits, and settlement payments (Pending/Sent/Confirmed).
                            </p>
                            <form method="POST" action="${pageContext.request.contextPath}/admin/lab" class="mt-auto">
                                <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                <input type="hidden" name="action" value="load_scenario">
                                <input type="hidden" name="scenario" value="E">
                                <div class="input-group input-group-sm mb-2">
                                    <label class="input-group-text" for="memE">Members</label>
                                    <select class="form-select" id="memE" name="memberCount">
                                        <option value="3">3 members</option>
                                        <option value="4">4 members</option>
                                        <option value="5" selected>5 members</option>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-sm btn-primary w-100">
                                    Create Scenario E
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Scenario F -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border border-danger">
                        <div class="card-body d-flex flex-column">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h6 class="fw-bold mb-0 text-danger">Scenario F: Cancelled</h6>
                                <span class="badge bg-danger">CANCELLED</span>
                            </div>
                            <p class="text-muted small flex-grow-1">
                                Cancelled before departure due to scheduling conflicts. Activities marked as cancelled.
                            </p>
                            <form method="POST" action="${pageContext.request.contextPath}/admin/lab" class="mt-auto">
                                <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                <input type="hidden" name="action" value="load_scenario">
                                <input type="hidden" name="scenario" value="F">
                                <div class="input-group input-group-sm mb-2">
                                    <label class="input-group-text" for="memF">Members</label>
                                    <select class="form-select" id="memF" name="memberCount">
                                        <option value="2" selected>2 members</option>
                                        <option value="3">3 members</option>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-sm btn-danger w-100">
                                    Create Scenario F
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Active Simulated Batches Table -->
    <div class="card shadow-sm mb-4">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <h5 class="card-title mb-0 fw-bold d-flex align-items-center gap-2">
                <span>📦</span> Active Simulated Batches
            </h5>
            <c:if test="${not empty batches}">
                <form method="POST" action="${pageContext.request.contextPath}/admin/lab" onsubmit="return confirm('Purge ALL simulated data? Real and demo seed data will NOT be touched.');">
                    <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                    <input type="hidden" name="action" value="purge_all">
                    <button type="submit" class="btn btn-sm btn-outline-danger">
                        Purge All Batches
                    </button>
                </form>
            </c:if>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light small">
                        <tr>
                            <th>Batch ID</th>
                            <th>Trip</th>
                            <th>Owner</th>
                            <th>Status</th>
                            <th>Users</th>
                            <th>Created</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty batches}">
                                <tr>
                                    <td colspan="7" class="text-center py-4 text-muted">
                                        No simulated batches found. Use the Scenario Loader above to create one.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="b" items="${batches}">
                                    <tr>
                                        <td><code class="text-secondary"><c:out value="${b.batchId}" /></code></td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/trip/detail?tripId=${b.tripId}" class="fw-bold text-dark text-decoration-underline">
                                                <c:out value="${b.tripName}" />
                                            </a>
                                        </td>
                                        <td class="small"><c:out value="${b.ownerEmail}" /></td>
                                        <td>
                                            <span class="badge ${b.status == 'ONGOING' ? 'bg-success' : b.status == 'PLANNING' ? 'bg-info text-dark' : b.status == 'COMPLETED' ? 'bg-primary' : 'bg-danger'}">
                                                <c:out value="${b.status}" />
                                            </span>
                                        </td>
                                        <td><span class="badge bg-light text-dark border"><c:out value="${b.userCount}" /></span></td>
                                        <td class="small text-muted"><c:out value="${b.createdAt}" /></td>
                                        <td class="text-end">
                                            <form method="POST" action="${pageContext.request.contextPath}/admin/lab" class="d-inline" onsubmit="return confirm('Purge batch ${b.batchId}?');">
                                                <input type="hidden" name="csrfToken" value="${sessionScope.travelCsrf}">
                                                <input type="hidden" name="action" value="purge_batch">
                                                <input type="hidden" name="batchId" value="${b.batchId}">
                                                <button type="submit" class="btn btn-sm btn-outline-danger py-0 px-2">
                                                    Purge
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
