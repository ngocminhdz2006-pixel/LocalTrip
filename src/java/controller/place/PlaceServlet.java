package controller.place;

import dao.CategoryDAO;
import dao.PlaceDAO;
import dao.PreferenceDAO;
import dao.TripDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.GroupPreference;
import model.Place;
import model.Trip;
import model.User;

@WebServlet({
    "/places",
    "/places/detail"
})
public class PlaceServlet extends HttpServlet {

    private static final String LIST_VIEW
            = "/WEB-INF/views/place/place-list.jsp";

    private static final String DETAIL_VIEW
            = "/WEB-INF/views/place/place-detail.jsp";

    private final PlaceDAO placeDAO = new PlaceDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final TripDAO tripDAO = new TripDAO();
    private final PreferenceDAO preferenceDAO = new PreferenceDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User user = getCurrentUser(request, response);

        if (user == null) {
            return;
        }

        String path = request.getServletPath();

        if ("/places".equals(path)) {
            showList(request, response, user);
            return;
        }

        if ("/places/detail".equals(path)) {
            showDetail(request, response, user);
            return;
        }

        response.sendError(
                HttpServletResponse.SC_NOT_FOUND
        );
    }

    private void showList(
            HttpServletRequest request,
            HttpServletResponse response,
            User user)
            throws ServletException, IOException {

        int categoryId = parsePositiveInt(
                request.getParameter("categoryId")
        );

        String city = request.getParameter("city");
        String district = request.getParameter("district");

        city = city == null ? "" : city.trim();
        district = district == null ? "" : district.trim();

        if (city.contains(",") && district.isEmpty()) {
            String[] parts = city.split(",", 2);
            district = parts[0].trim();
            city = parts[1].trim();
        }

        String maxPriceParam = request.getParameter("maxPrice");
        BigDecimal maxPrice = null;
        if (maxPriceParam != null && !maxPriceParam.trim().isEmpty()) {
            try {
                maxPrice = new BigDecimal(maxPriceParam.trim());
                request.setAttribute("selectedMaxPrice", maxPrice);
            } catch (Exception ignored) {
            }
        }

        int tripId = parsePositiveInt(request.getParameter("tripId"));
        Set<Integer> groupCategoryIds = new HashSet<>();
        Trip currentTrip = null;

        List<Trip> userTrips = tripDAO.findByUser(user.getUserId());
        request.setAttribute("userTrips", userTrips);

        if (tripId > 0) {
            currentTrip = tripDAO.findByIdForUser(tripId, user.getUserId());
            if (currentTrip != null) {
                request.setAttribute("currentTrip", currentTrip);
                List<GroupPreference> groupPrefs = preferenceDAO.findGroupPreferences(tripId);
                for (GroupPreference gp : groupPrefs) {
                    groupCategoryIds.add(gp.getCategoryId());
                }
            }
        }
        request.setAttribute("groupCategoryIds", groupCategoryIds);

        try {
            request.setAttribute("categories", categoryDAO.findAll());
            request.setAttribute("cities", placeDAO.findCities());

            request.setAttribute(
                    "districts",
                    placeDAO.findDistricts(city)
            );

            request.setAttribute("selectedCity", city);
            request.setAttribute("selectedDistrict", district);
            request.setAttribute("selectedCategoryId", categoryId);

            request.setAttribute(
                    "places",
                    placeDAO.findFiltered(categoryId, city, district, maxPrice)
            );

            request.getRequestDispatcher(LIST_VIEW)
                    .forward(request, response);

        } catch (RuntimeException e) {
            throw new ServletException(
                    "Unable to load places.", e
            );
        }
    }

    private void showDetail(HttpServletRequest request,
            HttpServletResponse response,
            User user)
            throws ServletException, IOException {

        int placeId = parsePositiveInt(
                request.getParameter("placeId")
        );

        if (placeId <= 0) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST
            );
            return;
        }

        Place place;

        try {
            place = placeDAO.findById(placeId);

        } catch (RuntimeException e) {
            throw new ServletException(
                    "Unable to load place details.",
                    e
            );
        }

        if (place == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND
            );
            return;
        }

        int tripId = parsePositiveInt(request.getParameter("tripId"));
        Set<Integer> groupCategoryIds = new HashSet<>();
        Trip currentTrip = null;

        List<Trip> userTrips = tripDAO.findByUser(user.getUserId());
        request.setAttribute("userTrips", userTrips);

        if (tripId > 0) {
            currentTrip = tripDAO.findByIdForUser(tripId, user.getUserId());
            if (currentTrip != null) {
                request.setAttribute("currentTrip", currentTrip);
                List<GroupPreference> groupPrefs = preferenceDAO.findGroupPreferences(tripId);
                for (GroupPreference gp : groupPrefs) {
                    groupCategoryIds.add(gp.getCategoryId());
                }
            }
        }
        request.setAttribute("groupCategoryIds", groupCategoryIds);

        request.setAttribute("place", place);

        request.getRequestDispatcher(DETAIL_VIEW)
                .forward(request, response);
    }

    private User getCurrentUser(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        User user = session == null
                ? null
                : (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return null;
        }

        if (!"USER".equals(user.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN
            );
            return null;
        }

        return user;
    }

    private int parsePositiveInt(String value) {
        try {
            int number = Integer.parseInt(value);
            return number > 0 ? number : -1;

        } catch (NumberFormatException e) {
            return -1;
        }
    }
}
