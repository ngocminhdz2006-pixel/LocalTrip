package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.TripNote;

public class TripNoteDAO {

    private static final Logger LOGGER = Logger.getLogger(TripNoteDAO.class.getName());

    public List<TripNote> findByTripId(int tripId) {
        List<TripNote> notes = new ArrayList<>();
        String sql = "SELECT tn.note_id, tn.trip_id, tn.user_id, tn.note_text, tn.created_at, u.full_name "
                   + "FROM TripNotes tn "
                   + "JOIN Users u ON u.user_id = tn.user_id "
                   + "WHERE tn.trip_id = ? "
                   + "ORDER BY tn.created_at DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tripId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TripNote note = new TripNote();
                    note.setNoteId(rs.getInt("note_id"));
                    note.setTripId(rs.getInt("trip_id"));
                    note.setUserId(rs.getInt("user_id"));
                    note.setNoteText(rs.getString("note_text"));
                    note.setCreatedAt(rs.getTimestamp("created_at"));
                    note.setUserName(rs.getString("full_name"));
                    notes.add(note);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to load trip notes for trip " + tripId, e);
        }
        return notes;
    }

    public boolean addNote(int tripId, int userId, String noteText) {
        if (noteText == null || noteText.trim().isEmpty()) {
            return false;
        }
        String sql = "INSERT INTO TripNotes (trip_id, user_id, note_text) VALUES (?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tripId);
            ps.setInt(2, userId);
            ps.setString(3, noteText.trim());
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to insert trip note", e);
            return false;
        }
    }

    public boolean deleteNote(int noteId, int userId, boolean isTripOwner) {
        String sql = isTripOwner
                   ? "DELETE FROM TripNotes WHERE note_id = ?"
                   : "DELETE FROM TripNotes WHERE note_id = ? AND user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, noteId);
            if (!isTripOwner) {
                ps.setInt(2, userId);
            }
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to delete trip note", e);
            return false;
        }
    }
}
