package controller.checkin;

import dao.PlaceDAO;
import dao.TripDAO;
import dao.TravelFeatureDAO;
import dao.TravelFeatureDAO.StoredImage;
import controller.dump.DumpServlet;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.Collections;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import model.Place;
import model.User;

@WebServlet("/checkin")
@MultipartConfig(maxFileSize = 5L * 1024 * 1024, maxRequestSize = 25L * 1024 * 1024)
public class CheckInServlet extends HttpServlet {
    private final PlaceDAO places = new PlaceDAO();
    private final TripDAO trips = new TripDAO();
    private final TravelFeatureDAO dao = new TravelFeatureDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = current(req, resp);
        if (user == null) {
            return;
        }
        int placeId = parse(req.getParameter("placeId"));
        if (placeId < 1) {
            resp.sendError(400, "Invalid place identifier.");
            return;
        }
        Place place = places.findById(placeId);
        if (place == null) {
            resp.sendError(404, "Destination not found.");
            return;
        }
        if (place.getLatitude() == null || place.getLongitude() == null) {
            req.setAttribute("errorMessage", "This destination does not have GPS coordinates configured yet.");
        }
        if (req.getSession().getAttribute("travelCsrf") == null) {
            req.getSession().setAttribute("travelCsrf", UUID.randomUUID().toString());
        }
        req.setAttribute("place", place);
        req.setAttribute("trips", trips.findByUser(user.getUserId()));
        req.setAttribute("selectedTripId", req.getParameter("tripId"));
        req.getRequestDispatcher("/WEB-INF/views/dump/checkin.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User user = current(req, resp);
        if (user == null) {
            return;
        }

        Object token = req.getSession().getAttribute("travelCsrf");
        if (!(token instanceof String) || !token.equals(req.getParameter("csrfToken"))) {
            req.getSession().setAttribute("errorMessage", "Form session expired. Please try again.");
            resp.sendRedirect(req.getContextPath() + "/places");
            return;
        }

        int placeId = parse(req.getParameter("placeId"));
        Place place = places.findById(placeId);
        if (place == null) {
            req.getSession().setAttribute("errorMessage", "Destination not found.");
            resp.sendRedirect(req.getContextPath() + "/places");
            return;
        }

        double lat, lng;
        try {
            lat = Double.parseDouble(req.getParameter("latitude"));
            lng = Double.parseDouble(req.getParameter("longitude"));
        } catch (Exception e) {
            req.getSession().setAttribute("errorMessage", "Unable to obtain valid GPS coordinates from device.");
            resp.sendRedirect(req.getContextPath() + "/checkin?placeId=" + placeId);
            return;
        }

        if (!Double.isFinite(lat) || !Double.isFinite(lng) || lat < -90 || lat > 90 || lng < -180 || lng > 180) {
            req.getSession().setAttribute("errorMessage", "Invalid GPS coordinates received.");
            resp.sendRedirect(req.getContextPath() + "/checkin?placeId=" + placeId);
            return;
        }

        Integer tripId = null;
        String trip = req.getParameter("tripId");
        if (trip != null && !trip.trim().isEmpty()) {
            tripId = parse(trip);
            if (tripId < 1) {
                tripId = null;
            }
        }

        // Distance verification check (200m range)
        double distance = 0;
        if (place.getLatitude() != null && place.getLongitude() != null) {
            distance = calculateDistanceMeters(lat, lng, place.getLatitude().doubleValue(), place.getLongitude().doubleValue());
            if (distance > 200.0) {
                req.getSession().setAttribute("errorMessage", String.format(
                        "You are currently %.0f meters away from %s. Please move within 200 meters to check in.",
                        distance, place.getPlaceName()));
                resp.sendRedirect(req.getContextPath() + "/checkin?placeId=" + placeId + (tripId != null ? "&tripId=" + tripId : ""));
                return;
            }
        }

        File written = null;
        try {
            Part photoPart = null;
            for (Part part : req.getParts()) {
                if ("photo".equals(part.getName()) && part.getSize() > 0) {
                    photoPart = part;
                    break;
                }
            }

            StoredImage photo = null;
            if (photoPart != null) {
                if (photoPart.getSize() > 5L * 1024 * 1024) {
                    throw new IllegalArgumentException("Check-in photo size must not exceed 5 MB.");
                }
                String type = detectImageType(photoPart);
                if (type == null) {
                    throw new IllegalArgumentException("Check-in photo must be a valid JPG, PNG, or WEBP image.");
                }
                String stored = UUID.randomUUID().toString().replace("-", "") + "." + type.substring(type.indexOf('/') + 1).replace("jpeg", "jpg");
                written = new File(DumpServlet.getUploadDir(), stored);
                try (InputStream in = photoPart.getInputStream()) {
                    Files.copy(in, written.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
                String original = photoPart.getSubmittedFileName();
                if (original != null) {
                    original = original.replace('\\', '/');
                    original = original.substring(original.lastIndexOf('/') + 1);
                    if (original.length() > 255) {
                        original = original.substring(original.length() - 255);
                    }
                }
                photo = new StoredImage(stored, original, type);
            }

            boolean share = "on".equals(req.getParameter("shareToDump"));
            String note = req.getParameter("note");
            if (share && (photo == null) && (note == null || note.trim().isEmpty())) {
                throw new IllegalArgumentException("To share memory to the feed, please attach a photo or write an impression.");
            }

            dao.createCheckIn(user.getUserId(), placeId, tripId, lat, lng, distance, note, photo);
            String message = "Check-in verified! This spot has been stamped to your Travel Passport.";

            if (share) {
                try {
                    dao.createPost(user.getUserId(), placeId, tripId, note, null,
                            "FRIENDS".equals(req.getParameter("dumpVisibility")) ? "FRIENDS" : "PUBLIC",
                            photo == null ? Collections.<StoredImage>emptyList() : Collections.singletonList(photo));
                    message += " Your memory was also shared to the feed.";
                } catch (RuntimeException postError) {
                    message += " Note: unable to auto-share to feed; you can post it directly anytime.";
                }
            }

            req.getSession().setAttribute("successMessage", message);
        } catch (IllegalArgumentException e) {
            if (written != null) {
                Files.deleteIfExists(written.toPath());
            }
            req.getSession().setAttribute("errorMessage", e.getMessage());
        } catch (RuntimeException e) {
            if (written != null) {
                Files.deleteIfExists(written.toPath());
            }
            throw new ServletException("Unable to record check-in.", e);
        }

        resp.sendRedirect(req.getContextPath() + "/passport");
    }

    private double calculateDistanceMeters(double lat1, double lon1, double lat2, double lon2) {
        final double R = 6371000.0; // Earth radius in meters
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                 + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                 * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    private String detectImageType(Part part) throws IOException {
        byte[] h = new byte[12];
        int n;
        try (InputStream in = part.getInputStream()) {
            n = in.read(h);
        }
        if (n >= 3 && (h[0] & 255) == 255 && (h[1] & 255) == 216 && (h[2] & 255) == 255) {
            return "image/jpeg";
        }
        if (n >= 8 && (h[0] & 255) == 137 && h[1] == 80 && h[2] == 78 && h[3] == 71 && h[4] == 13 && h[5] == 10 && h[6] == 26 && h[7] == 10) {
            return "image/png";
        }
        if (n >= 12 && h[0] == 'R' && h[1] == 'I' && h[2] == 'F' && h[3] == 'F' && h[8] == 'W' && h[9] == 'E' && h[10] == 'B' && h[11] == 'P') {
            return "image/webp";
        }
        return null;
    }

    private User current(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession s = req.getSession(false);
        User u = s == null ? null : (User) s.getAttribute("user");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        return u;
    }

    private int parse(String s) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return -1;
        }
    }
}
