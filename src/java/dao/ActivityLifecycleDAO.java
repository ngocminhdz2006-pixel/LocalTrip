package dao;

import java.sql.*;
import java.time.LocalDate;
import java.time.ZoneId;
import java.math.BigDecimal;
import java.util.*;
import model.ItineraryItem;
import utils.ActivityLifecycle;

/** Authoritative edits lock the trip before checking the current activity state. */
public class ActivityLifecycleDAO {
    private DateToday today() { return new DateToday(); }
    private static final class DateToday {
        final java.sql.Date value = java.sql.Date.valueOf(LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")));
    }

    public void updateRunningEnd(int tripId,int itemId,int ownerId,String expectedEnd,Time newEnd) {
        try(Connection c=DBContext.getConnection()) {
            c.setAutoCommit(false); c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                TripInfo trip=lockTrip(c,tripId,ownerId);
                ItineraryItem item=readItem(c,tripId,itemId);
                item.setTripId(tripId); item.setItemId(itemId);
                if(!"ONGOING".equals(trip.status) || !"IN_PROGRESS".equals(item.getActivityStatus())
                        || !item.getEndTime().toString().equals(expectedEnd))
                    throw new IllegalArgumentException("Activity or end time has changed. Please reload the itinerary.");
                item.setEndTime(newEnd);
                validateItem(c,trip,item);
                rejectConflict(c,item,itemId,false);
                try(PreparedStatement ps=c.prepareStatement("UPDATE dbo.ItineraryItems SET end_time=CAST(? AS TIME) WHERE trip_id=? AND item_id=? AND activity_status='IN_PROGRESS'")) {
                    ps.setString(1,newEnd.toString()); ps.setInt(2,tripId); ps.setInt(3,itemId);
                    if(ps.executeUpdate()!=1) throw new IllegalArgumentException("Activity is no longer in progress.");
                }
                c.commit();
            } catch(SQLException|RuntimeException e) { rollback(c,e); throw e; }
        } catch(SQLException e) { throw new RuntimeException("Unable to adjust end time.",e); }
    }

    public void changeStatus(int tripId, int itemId, int ownerId, String expected, String next) {
        try (Connection c=DBContext.getConnection()) {
            c.setAutoCommit(false);
            c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                TripInfo trip=lockTrip(c,tripId,ownerId);
                ItineraryItem original=readItem(c,tripId,itemId);
                if (!Objects.equals(expected,original.getActivityStatus())
                        || !ActivityLifecycle.canTransition(trip.status,expected,next)) {
                    throw new IllegalArgumentException("Status has changed or operation is not allowed. Please reload.");
                }
                if ("IN_PROGRESS".equals(next)) {
                    if(original.getVisitDate().after(today().value))
                        throw new IllegalArgumentException("Cannot start an activity for a future date.");
                    try(PreparedStatement ps=c.prepareStatement("SELECT 1 FROM dbo.ItineraryItems WHERE trip_id=? AND activity_status='IN_PROGRESS' AND item_id<>?")) {
                        ps.setInt(1,tripId); ps.setInt(2,itemId);
                        try(ResultSet rs=ps.executeQuery()) {
                            if(rs.next()) throw new IllegalArgumentException("Please complete or cancel the currently ongoing activity first.");
                        }
                    }
                }
                try(PreparedStatement ps=c.prepareStatement("UPDATE dbo.ItineraryItems SET activity_status=? WHERE item_id=? AND trip_id=? AND activity_status=?")) {
                    ps.setString(1,next); ps.setInt(2,itemId); ps.setInt(3,tripId); ps.setString(4,expected);
                    if(ps.executeUpdate()!=1) throw new IllegalArgumentException("Activity has been modified.");
                }
                c.commit();
            } catch(SQLException|RuntimeException e) { rollback(c,e); throw e; }
        } catch(SQLException e) { throw new RuntimeException("Unable to update activity status.",e); }
    }

    public void editItem(ItineraryItem edited,int ownerId,String revision) {
        try(Connection c=DBContext.getConnection()) {
            c.setAutoCommit(false); c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                TripInfo trip=lockTrip(c,edited.getTripId(),ownerId);
                if(!new ItineraryDAO().revision(c,edited.getTripId()).equals(revision))
                    throw new IllegalArgumentException("Itinerary has changed. Please reopen the form to avoid overwriting.");
                ItineraryItem original=readItem(c,edited.getTripId(),edited.getItemId());
                if(!"UPCOMING".equals(original.getActivityStatus()))
                    throw new IllegalArgumentException("Only upcoming activities can be edited.");
                if(original.getVisitDate().before(today().value))
                    throw new IllegalArgumentException("Cannot edit activities for past dates.");
                edited.setActivityType(original.getActivityType());
                edited.setActivityTitle("REST".equals(original.getActivityType())?original.getActivityTitle():null);
                if("REST".equals(original.getActivityType()) && original.getPlaceId()==0) edited.setPlaceId(0);
                validateItem(c,trip,edited);
                rejectConflict(c,edited,edited.getItemId(),false);
                try(PreparedStatement ps=c.prepareStatement("UPDATE dbo.ItineraryItems SET place_id=?, visit_date=?, start_time=?, end_time=?, note=?, estimated_cost=?, activity_title=? WHERE trip_id=? AND item_id=? AND activity_status='UPCOMING'")) {
                    bindPlace(ps,1,edited.getPlaceId()); ps.setDate(2,edited.getVisitDate()); ps.setString(3,edited.getStartTime().toString()); ps.setString(4,edited.getEndTime().toString());
                    ps.setString(5,edited.getNote()); ps.setBigDecimal(6,edited.getEstimatedCost()); ps.setString(7,edited.getActivityTitle());
                    ps.setInt(8,edited.getTripId()); ps.setInt(9,edited.getItemId());
                    if(ps.executeUpdate()!=1) throw new IllegalArgumentException("Activity can no longer be edited.");
                }
                c.commit();
            } catch(SQLException|RuntimeException e) { rollback(c,e); throw e; }
        } catch(SQLException e) { throw new RuntimeException("Unable to save activity. Previous schedule preserved.",e); }
    }

    public void replaceUpcoming(int tripId,int ownerId,java.sql.Date fromDate,String revision,List<ItineraryItem> items) {
        if(items==null || items.isEmpty() || items.size()>120 || fromDate==null || fromDate.before(today().value))
            throw new IllegalArgumentException("Draft preview is empty, too large, or expired.");
        try(Connection c=DBContext.getConnection()) {
            c.setAutoCommit(false); c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                TripInfo trip=lockTrip(c,tripId,ownerId);
                if(!new ItineraryDAO().revision(c,tripId).equals(revision))
                    throw new IllegalArgumentException("Itinerary, trip, or group members changed. Please regenerate the draft.");
                List<ItineraryItem> ordered=new ArrayList<>(items);
                ordered.sort(Comparator.comparing(ItineraryItem::getVisitDate).thenComparing(ItineraryItem::getStartTime));
                ItineraryItem previous=null;
                for(ItineraryItem item:ordered) {
                    if(item.getTripId()!=tripId || item.getVisitDate().before(fromDate))
                        throw new IllegalArgumentException("Activity falls outside the replacement date range.");
                    validateItem(c,trip,item);
                    if(previous!=null && previous.getVisitDate().equals(item.getVisitDate()) && item.getStartTime().before(previous.getEndTime()))
                        throw new IllegalArgumentException("Draft preview has overlapping activity times.");
                    rejectConflict(c,item,0,true);
                    previous=item;
                }
                // Preserve completed, running and cancelled history, even on today's date.
                try(PreparedStatement ps=c.prepareStatement("DELETE FROM dbo.ItineraryItems WHERE trip_id=? AND visit_date>=? AND activity_status='UPCOMING'")) {
                    ps.setInt(1,tripId); ps.setDate(2,fromDate); ps.executeUpdate();
                }
                String sql="INSERT dbo.ItineraryItems(trip_id,place_id,visit_date,start_time,end_time,note,estimated_cost,activity_type,activity_title,activity_status) VALUES(?,?,?,?,?,?,?,?,?,'UPCOMING')";
                try(PreparedStatement ps=c.prepareStatement(sql)) {
                    for(ItineraryItem item:ordered) {
                        ps.setInt(1,tripId); bindPlace(ps,2,item.getPlaceId()); ps.setDate(3,item.getVisitDate()); ps.setString(4,item.getStartTime().toString()); ps.setString(5,item.getEndTime().toString());
                        ps.setString(6,item.getNote()); ps.setBigDecimal(7,item.getEstimatedCost()); ps.setString(8,item.getActivityType() != null ? item.getActivityType() : "VISIT"); ps.setString(9,item.getActivityTitle()); ps.addBatch();
                    }
                    ps.executeBatch();
                }
                c.commit();
            } catch(SQLException|RuntimeException e) { rollback(c,e); throw e; }
        } catch(SQLException e) { throw new RuntimeException("Unable to apply schedule. Previous itinerary preserved.",e); }
    }

    private TripInfo lockTrip(Connection c,int tripId,int ownerId) throws SQLException {
        try(PreparedStatement ps=c.prepareStatement("SELECT status,destination,start_date,end_date FROM dbo.Trips WITH(UPDLOCK,HOLDLOCK) WHERE trip_id=? AND owner_id=?")) {
            ps.setInt(1,tripId); ps.setInt(2,ownerId);
            try(ResultSet rs=ps.executeQuery()) {
                if(!rs.next() || !("PLANNING".equals(rs.getString("status")) || "ONGOING".equals(rs.getString("status"))))
                    throw new IllegalArgumentException("You do not have permission to edit the schedule or trip is closed.");
                TripInfo trip=new TripInfo(); trip.status=rs.getString("status"); trip.destination=rs.getString("destination");
                trip.start=rs.getDate("start_date"); trip.end=rs.getDate("end_date"); return trip;
            }
        }
    }
    private static final class TripInfo { String status,destination; java.sql.Date start,end; }
    private ItineraryItem readItem(Connection c,int tripId,int itemId) throws SQLException {
        try(PreparedStatement ps=c.prepareStatement("SELECT place_id,visit_date,start_time,end_time,note,estimated_cost,activity_type,activity_title,activity_status FROM dbo.ItineraryItems WITH(UPDLOCK,HOLDLOCK) WHERE trip_id=? AND item_id=?")) {
            ps.setInt(1,tripId); ps.setInt(2,itemId);
            try(ResultSet rs=ps.executeQuery()) {
                if(!rs.next()) throw new IllegalArgumentException("Activity not found.");
                ItineraryItem item=new ItineraryItem(); item.setPlaceId(rs.getInt("place_id")); item.setVisitDate(rs.getDate("visit_date"));
                item.setStartTime(rs.getTime("start_time")); item.setEndTime(rs.getTime("end_time")); item.setNote(rs.getString("note")); item.setEstimatedCost(rs.getBigDecimal("estimated_cost"));
                item.setActivityType(rs.getString("activity_type")); item.setActivityTitle(rs.getString("activity_title")); item.setActivityStatus(rs.getString("activity_status")); return item;
            }
        }
    }
    private void validateItem(Connection c,TripInfo trip,ItineraryItem item) throws SQLException {
        if(item.getVisitDate()==null || item.getVisitDate().before(today().value) || item.getVisitDate().before(trip.start) || item.getVisitDate().after(trip.end)
                || item.getStartTime()==null || item.getEndTime()==null || !item.getEndTime().after(item.getStartTime()))
            throw new IllegalArgumentException("Invalid activity date or time.");
        BigDecimal cost=item.getEstimatedCost();
        if(cost==null || cost.signum()<0 || cost.compareTo(new BigDecimal("9999999999999999.99"))>0 || cost.stripTrailingZeros().scale()>2)
            throw new IllegalArgumentException("Invalid estimated cost.");
        if(item.getNote()!=null && item.getNote().length()>500) throw new IllegalArgumentException("Note cannot exceed 500 characters.");
        if(item.getActivityType()==null) item.setActivityType("VISIT");
        if(!Arrays.asList("VISIT","MEAL","CAFE","REST").contains(item.getActivityType())) throw new IllegalArgumentException("Invalid activity type.");
        if(item.getActivityTitle()!=null && item.getActivityTitle().length()>200) throw new IllegalArgumentException("Activity title cannot exceed 200 characters.");
        if(item.getPlaceId()==0) {
            if(!"REST".equals(item.getActivityType()) || item.getActivityTitle()==null || item.getActivityTitle().trim().isEmpty())
                throw new IllegalArgumentException("Only named rest intervals can have an empty destination.");
            return;
        }
        try(PreparedStatement ps=c.prepareStatement("SELECT opening_time,closing_time,city_name,district_name FROM dbo.Places WITH(HOLDLOCK) WHERE place_id=? AND is_active=1")) {
            ps.setInt(1,item.getPlaceId());
            try(ResultSet rs=ps.executeQuery()) {
                if(!rs.next()) throw new IllegalArgumentException("Destination is not active or not found.");
                String city = rs.getString("city_name");
                String district = rs.getString("district_name");
                String fullArea = (district != null ? district + ", " : "") + (city != null ? city : "");
                String dest = trip.destination == null ? "" : trip.destination.trim();
                if (!dest.isEmpty() && !dest.equalsIgnoreCase(fullArea)
                        && (city == null || !dest.toLowerCase().contains(city.toLowerCase()))
                        && (district == null || !dest.toLowerCase().contains(district.toLowerCase()))
                        && !fullArea.toLowerCase().contains(dest.toLowerCase())) {
                    try (PreparedStatement psCheck = c.prepareStatement("SELECT 1 FROM dbo.Places WHERE is_active=1 AND ((district_name+N', '+city_name)=? OR city_name=? OR ? LIKE N'%' + city_name + N'%')")) {
                        psCheck.setString(1, dest);
                        psCheck.setString(2, dest);
                        psCheck.setString(3, dest);
                        try (ResultSet rsCheck = psCheck.executeQuery()) {
                            if (rsCheck.next()) {
                                throw new IllegalArgumentException("Destination is not active in this trip region.");
                            }
                        }
                    }
                }
                Time open=rs.getTime(1),close=rs.getTime(2);
                boolean overnight=open!=null && close!=null && close.before(open);
                boolean valid=overnight?(!item.getStartTime().before(open)||!item.getEndTime().after(close))
                        :(open==null||!item.getStartTime().before(open))&&(close==null||!item.getEndTime().after(close));
                if(!valid) throw new IllegalArgumentException("Activity hours are outside venue operating hours.");
            }
        }
    }
    private void rejectConflict(Connection c,ItineraryItem item,int exclude,boolean historyOnly) throws SQLException {
        String sql="SELECT 1 FROM dbo.ItineraryItems WITH(UPDLOCK,HOLDLOCK) WHERE trip_id=? AND item_id<>? AND visit_date=? AND activity_status<>'CANCELLED' "
                +(historyOnly?"AND activity_status<>'UPCOMING' ":"")+"AND start_time<CAST(? AS TIME) AND end_time>CAST(? AS TIME)";
        try(PreparedStatement ps=c.prepareStatement(sql)) {
            ps.setInt(1,item.getTripId()); ps.setInt(2,exclude); ps.setDate(3,item.getVisitDate()); ps.setString(4,item.getEndTime().toString()); ps.setString(5,item.getStartTime().toString());
            try(ResultSet rs=ps.executeQuery()) { if(rs.next()) throw new IllegalArgumentException("Activity time conflicts with an existing schedule."); }
        }
    }
    private void bindPlace(PreparedStatement ps,int index,int placeId) throws SQLException {
        if(placeId==0) ps.setNull(index,Types.INTEGER); else ps.setInt(index,placeId);
    }
    private void rollback(Connection c,Exception e) { try { c.rollback(); } catch(SQLException rollback) { e.addSuppressed(rollback); } }
}
