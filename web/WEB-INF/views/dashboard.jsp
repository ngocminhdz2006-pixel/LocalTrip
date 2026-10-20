<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Trip" %>
<%@ page import="utils.HtmlUtil" %>
<%
    model.User currentUser = (model.User) session.getAttribute("user");
    Integer tripCount = (Integer) request.getAttribute("tripCount");
    Integer ownerCount = (Integer) request.getAttribute("ownerCount");
    Integer memberCount = (Integer) request.getAttribute("memberCount");
    List<Trip> trips = (List<Trip>) request.getAttribute("trips");
    String dashboardError = (String) request.getAttribute("dashboardError");
%>
<% request.setAttribute("pageTitle", "Overview"); %>
<% request.setAttribute("tripRedesign", Boolean.TRUE);%>
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<section class="rd-hero mb-4">
    <div class="rd-hero-top">
        <div>
            <div class="small text-white-50 mb-2">
                LOCALTRIP · TRAVEL NOTEBOOK
            </div>

            <h1 class="mb-3">
                Trips are better together.
            </h1>

            <p class="text-white mb-0">
                Welcome back,
                <strong><%= HtmlUtil.escape(currentUser.getFullName())%></strong>.
                <br>
                Plan memorable journeys, discover exciting places, and split expenses seamlessly with friends.
            </p>
        </div>

        <a class="rd-back"
           href="<%= request.getContextPath()%>/trip/create">
            + Create trip
        </a>
    </div>
</section>

<% if (dashboardError != null) {%>
<div class="alert alert-warning" role="alert">
    <%= HtmlUtil.escape(dashboardError)%>
</div>
<% }%>

<div class="row g-3 mb-4">
    <div class="col-12 col-md-4">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Total Trips
            </div>

            <strong class="h2 d-block mb-0">
                <%= tripCount == null ? 0 : tripCount%>
            </strong>
        </section>
    </div>

    <div class="col-12 col-md-4">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Trips You Lead
            </div>

            <strong class="h2 d-block mb-0">
                <%= ownerCount == null ? 0 : ownerCount%>
            </strong>
        </section>
    </div>

    <div class="col-12 col-md-4">
        <section class="rd-card h-100">
            <div class="small text-muted mb-2">
                Trips You Joined
            </div>

            <strong class="h2 d-block mb-0">
                <%= memberCount == null ? 0 : memberCount%>
            </strong>
        </section>
    </div>
</div>

<div class="row g-4">
    <div class="col-12 col-lg-8">
        <section class="rd-card">
            <div class="d-flex justify-content-between
                 align-items-center flex-wrap gap-2 mb-4">
                <h2 class="h4 mb-0">Recent Trips</h2>

                <a class="small text-decoration-none"
                   href="<%= request.getContextPath()%>/trips">
                    View all →
                </a>
            </div>

            <% if (trips == null || trips.isEmpty()) {%>
            <div class="border-top pt-4 text-center">
                <h3 class="h5 mb-2">
                    Begin Your First Journey
                </h3>

                <p class="text-muted mb-4">
                    Create a trip to choose spots with friends,
                    build an itinerary, and track group expenses.
                </p>

                <a class="btn btn-primary"
                   href="<%= request.getContextPath()%>/trip/create">
                    + Create trip
                </a>
            </div>
            <% } else { %>
            <% for (Trip trip : trips) {
                    boolean owner
                            = trip.getOwnerId() == currentUser.getUserId();
            %>
            <div class="border-top py-3">
                <div class="d-flex justify-content-between
                     align-items-start flex-wrap gap-2 mb-2">
                    <a class="h5 mb-0 text-decoration-none"
                       style="overflow-wrap:anywhere;"
                       href="<%= request.getContextPath()%>/trip/detail?tripId=<%= trip.getTripId()%>">
                        <%= HtmlUtil.escape(trip.getTripName())%>
                    </a>

                          <span class="<%= owner
                                    ? "rd-role rd-role-lead"
                                    : "rd-role"%>">
                        <%= owner ? "Trip Lead" : "Member"%>
                    </span>
                </div>

                <div class="small text-muted mb-2">
                    <%= HtmlUtil.escape(trip.getDestination())%>
                </div>

                <div class="d-flex flex-wrap gap-3 small">
                    <span>
                        <strong>Duration:</strong>
                        <%= trip.getStartDate()%>
                        →
                        <%= trip.getEndDate()%>
                    </span>

                    <span>
                        <strong>Budget:</strong>
                        <%= trip.getBudget() == null
                                ? "Not set"
                                : java.text.NumberFormat
                                        .getNumberInstance(java.util.Locale.US)
                                        .format(trip.getBudget()) + " VND"%>
                    </span>
                </div>
            </div>
            <% } %>
            <% }%>
        </section>
    </div>

    <div class="col-12 col-lg-4">
        <section class="rd-card">
            <h2 class="h4 mb-2">Explore with LocalTrip</h2>

            <p class="text-muted mb-4">
                Plan a new adventure or preserve your travel memories.
            </p>

            <div class="d-grid gap-3">
                <a class="btn btn-primary"
                   href="<%= request.getContextPath()%>/trip/create">
                    + Plan a new trip
                </a>

                <a class="btn btn-outline-secondary"
                   href="<%= request.getContextPath()%>/places">
                    Explore destinations
                </a>

                <a class="btn btn-outline-secondary"
                   href="<%= request.getContextPath()%>/dump">
                    Travel feed
                </a>

                <a class="btn btn-outline-secondary"
                   href="<%= request.getContextPath()%>/passport">
                    Travel Passport
                </a>
            </div>
        </section>
    </div>
</div>
<%
    boolean showSeasonalComboPopup = Boolean.TRUE.equals(session.getAttribute("showSeasonalComboPopup"))
            && currentUser != null && "USER".equalsIgnoreCase(currentUser.getRole());
    if (showSeasonalComboPopup) {
        session.removeAttribute("showSeasonalComboPopup");
    }
%>
<%
    String seasonalComboTarget;
    String seasonalComboButtonText;
    if (trips != null && !trips.isEmpty() && trips.get(0) != null) {
        seasonalComboTarget = request.getContextPath() + "/combo?tripId=" + trips.get(0).getTripId();
        seasonalComboButtonText = "Explore combos";
    } else {
        seasonalComboTarget = request.getContextPath() + "/trip/create";
        seasonalComboButtonText = "Create trip to explore combos";
    }
%>
<% if (showSeasonalComboPopup) {%>
<div id="seasonalComboPopup" class="seasonal-popup-backdrop" role="dialog" aria-modal="true" aria-labelledby="seasonalPopupTitle">
    <div class="seasonal-popup-card">
        <button type="button" class="seasonal-popup-close" id="seasonalPopupClose" aria-label="Close popup">&times;</button>
        <img class="seasonal-popup-image" src="<%= request.getContextPath()%>/images/saigon-combo-bon-mua-popup.png" alt="Saigon - Explore Four Seasons Combos">
        <div class="seasonal-popup-caption">
            <h2 id="seasonalPopupTitle">Explore Saigon Seasonal Combos</h2>
            <p>Plan your next exciting adventure with LocalTrip.</p>
            <a class="btn btn-brand" href="<%= seasonalComboTarget%>"><%= seasonalComboButtonText%></a>
        </div>
    </div>
</div>
<style>
    .seasonal-popup-backdrop{
        position:fixed;
        inset:0;
        z-index:2000;
        display:flex;
        align-items:center;
        justify-content:center;
        padding:22px;
        background:rgba(18,24,20,.68);
        backdrop-filter:blur(3px);
        animation:seasonalFadeIn .18s ease-out
    }
    .seasonal-popup-card{
        position:relative;
        width:min(900px,96vw);
        max-height:92vh;
        overflow:auto;
        background:#fffaf2;
        border-radius:18px;
        box-shadow:0 24px 80px rgba(0,0,0,.3);
        animation:seasonalPopupIn .22s ease-out
    }
    .seasonal-popup-image{
        display:block;
        width:100%;
        height:auto;
        max-height:68vh;
        object-fit:contain;
        background:#f5e6cf
    }
    .seasonal-popup-close{
        position:absolute;
        top:10px;
        right:10px;
        z-index:2;
        width:42px;
        height:42px;
        border:0;
        border-radius:50%;
        background:rgba(30,25,20,.78);
        color:#fff;
        font-size:32px;
        line-height:1;
        cursor:pointer;
        display:flex;
        align-items:center;
        justify-content:center
    }
    .seasonal-popup-close:hover{
        background:#741313
    }
    .seasonal-popup-caption{
        text-align:center;
        padding:18px 22px 24px
    }
    .seasonal-popup-caption h2{
        font-family:Georgia,'Times New Roman',serif;
        color:#741313;
        font-size:clamp(20px,3vw,30px);
        margin:0 0 8px
    }
    .seasonal-popup-caption p{
        color:#5d6259;
        margin-bottom:14px
    }
    .seasonal-popup-backdrop.is-closing{
        opacity:0;
        transition:opacity .15s ease
    }
    @keyframes seasonalFadeIn{
        from{
            opacity:0
        }
        to{
            opacity:1
        }
    }
    @keyframes seasonalPopupIn{
        from{
            transform:translateY(10px) scale(.985)
        }
        to{
            transform:translateY(0) scale(1)
        }
    }
    @media(max-width:600px){
        .seasonal-popup-backdrop{
            padding:12px
        }
        .seasonal-popup-card{
            width:100%;
            max-height:94vh;
            border-radius:13px
        }
        .seasonal-popup-image{
            max-height:58vh
        }
        .seasonal-popup-caption{
            padding:14px 14px 18px
        }
        .seasonal-popup-close{
            width:36px;
            height:36px;
            font-size:28px;
            top:8px;
            right:8px
        }
    }
</style>
<script>
    (function(){var popup = document.getElementById('seasonalComboPopup'); if (!popup)return; var closeButton = document.getElementById('seasonalPopupClose'); function closePopup(){popup.classList.add('is-closing'); window.setTimeout(function(){if (popup && popup.parentNode)popup.parentNode.removeChild(popup); }, 160); }closeButton.addEventListener('click', closePopup); popup.addEventListener('click', function(event){if (event.target === popup)closePopup(); }); document.addEventListener('keydown', function(event){if (event.key === 'Escape' && document.getElementById('seasonalComboPopup'))closePopup(); }); })();
</script>
<% }
   %>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
