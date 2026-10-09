package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Data access for Dump, friendships, GPS check-ins, passport and badges. */
public class TravelFeatureDAO {
    private static RuntimeException failure(String message, SQLException e) {
        return new RuntimeException(message, e);
    }

    public boolean areFriends(Connection c, int first, int second) throws SQLException {
        if (first == second) return true;
        String sql = "SELECT 1 FROM dbo.Friendships WHERE status='ACCEPTED' AND "
                + "((requester_id=? AND addressee_id=?) OR (requester_id=? AND addressee_id=?))";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, first); ps.setInt(2, second); ps.setInt(3, second); ps.setInt(4, first);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    public List<Map<String,Object>> getFeed(int viewerId, String filter) {
        List<Map<String,Object>> list = new ArrayList<Map<String,Object>>();
        String sql = "SELECT p.post_id,p.user_id,u.full_name,p.place_id,pl.place_name,p.trip_id,p.content,p.rating,p.visibility,p.created_at,"
                + "(SELECT COUNT(*) FROM dbo.PostLikes l WHERE l.post_id=p.post_id) like_count,"
                + "(SELECT COUNT(*) FROM dbo.PostComments c WHERE c.post_id=p.post_id AND c.is_deleted=0) comment_count,"
                + "CASE WHEN EXISTS(SELECT 1 FROM dbo.PostLikes l2 WHERE l2.post_id=p.post_id AND l2.user_id=?) THEN 1 ELSE 0 END liked,"
                + "CASE WHEN EXISTS(SELECT 1 FROM dbo.PostBookmarks b WHERE b.post_id=p.post_id AND b.user_id=?) THEN 1 ELSE 0 END bookmarked "
                + "FROM dbo.Posts p JOIN dbo.Users u ON u.user_id=p.user_id LEFT JOIN dbo.Places pl ON pl.place_id=p.place_id "
                + "WHERE p.is_deleted=0 AND (p.user_id=? OR p.visibility='PUBLIC' OR EXISTS(SELECT 1 FROM dbo.Friendships f WHERE f.status='ACCEPTED' AND ((f.requester_id=p.user_id AND f.addressee_id=?) OR (f.requester_id=? AND f.addressee_id=p.user_id)))) ";
        if ("BOOKMARKS".equals(filter)) sql += "AND EXISTS(SELECT 1 FROM dbo.PostBookmarks b2 WHERE b2.post_id=p.post_id AND b2.user_id=?) ";
        sql += "ORDER BY p.created_at DESC, p.post_id DESC";
        try (Connection c=DBContext.getConnection(); PreparedStatement ps=c.prepareStatement(sql)) {
            ps.setInt(1,viewerId); ps.setInt(2,viewerId); ps.setInt(3,viewerId); ps.setInt(4,viewerId); ps.setInt(5,viewerId);
            if ("BOOKMARKS".equals(filter)) ps.setInt(6,viewerId);
            try (ResultSet rs=ps.executeQuery()) {
                while(rs.next()) {
                    Map<String,Object> m=new LinkedHashMap<String,Object>();
                    int id=rs.getInt("post_id");
                    m.put("postId",id); m.put("userId",rs.getInt("user_id")); m.put("fullName",rs.getString("full_name"));
                    Object placeObject=rs.getObject("place_id"); m.put("placeId",placeObject==null?null:Integer.valueOf(rs.getInt("place_id")));
                    m.put("placeName",rs.getString("place_name")); m.put("tripId",rs.getObject("trip_id")); m.put("content",rs.getString("content"));
                    int rating=rs.getInt("rating"); m.put("rating",rs.wasNull()?null:Integer.valueOf(rating));
                    m.put("visibility",rs.getString("visibility")); m.put("createdAt",rs.getTimestamp("created_at"));
                    m.put("likeCount",rs.getInt("like_count")); m.put("commentCount",rs.getInt("comment_count")); m.put("liked",rs.getInt("liked")==1); m.put("bookmarked",rs.getInt("bookmarked")==1);
                    list.add(m);
                }
            }
            // SQL Server JDBC connections may not have MARS enabled: run child queries only after closing the feed ResultSet.
            for(Map<String,Object> m:list) { int id=((Integer)m.get("postId")).intValue(); m.put("images",getImages(c,id)); m.put("comments",getComments(c,id)); }
        } catch(SQLException e) { throw failure("Không thể tải Dump.",e); }
        return list;
    }

    private List<Map<String,Object>> getImages(Connection c,int postId) throws SQLException {
        List<Map<String,Object>> images=new ArrayList<Map<String,Object>>();
        try(PreparedStatement ps=c.prepareStatement("SELECT image_id,original_name,content_type FROM dbo.PostImages WHERE post_id=? ORDER BY display_order,image_id")) {
            ps.setInt(1,postId); try(ResultSet rs=ps.executeQuery()) { while(rs.next()) { Map<String,Object> m=new LinkedHashMap<String,Object>(); m.put("imageId",rs.getInt(1));m.put("originalName",rs.getString(2));m.put("contentType",rs.getString(3));images.add(m); } }
        } return images;
    }

    private List<Map<String,Object>> getComments(Connection c,int postId) throws SQLException {
        List<Map<String,Object>> comments=new ArrayList<Map<String,Object>>();
        try(PreparedStatement ps=c.prepareStatement("SELECT TOP 3 c.comment_id,c.content,c.created_at,u.full_name FROM dbo.PostComments c JOIN dbo.Users u ON u.user_id=c.user_id WHERE c.post_id=? AND c.is_deleted=0 ORDER BY c.created_at DESC")) {
            ps.setInt(1,postId); try(ResultSet rs=ps.executeQuery()) { while(rs.next()) { Map<String,Object> m=new LinkedHashMap<String,Object>();m.put("commentId",rs.getInt(1));m.put("content",rs.getString(2));m.put("createdAt",rs.getTimestamp(3));m.put("fullName",rs.getString(4));comments.add(m); } }
        } return comments;
    }

    public int createPost(int userId, Integer placeId, Integer tripId, String content, Integer rating, String visibility, List<StoredImage> images) {
        String sql="INSERT dbo.Posts(user_id,place_id,trip_id,content,rating,visibility) VALUES(?,?,?,?,?,?)";
        try(Connection c=DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                if(placeId!=null)try(PreparedStatement check=c.prepareStatement("SELECT 1 FROM dbo.Places WHERE place_id=? AND is_active=1")){check.setInt(1,placeId);try(ResultSet rs=check.executeQuery()){if(!rs.next())throw new IllegalArgumentException("Địa điểm không tồn tại hoặc đã ngừng hoạt động.");}}
                if(tripId!=null)try(PreparedStatement check=c.prepareStatement("SELECT 1 FROM dbo.Trips t LEFT JOIN dbo.TripMembers tm ON tm.trip_id=t.trip_id AND tm.user_id=? WHERE t.trip_id=? AND (t.owner_id=? OR tm.user_id IS NOT NULL)")){check.setInt(1,userId);check.setInt(2,tripId);check.setInt(3,userId);try(ResultSet rs=check.executeQuery()){if(!rs.next())throw new IllegalArgumentException("Bạn không có quyền gắn bài viết với chuyến đi này.");}}
                int postId;
                try(PreparedStatement ps=c.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1,userId); if(placeId==null)ps.setNull(2,java.sql.Types.INTEGER);else ps.setInt(2,placeId);
                    if(tripId==null)ps.setNull(3,java.sql.Types.INTEGER);else ps.setInt(3,tripId);
                    if(content==null||content.trim().isEmpty())ps.setNull(4,java.sql.Types.NVARCHAR);else ps.setString(4,content.trim());
                    if(rating==null)ps.setNull(5,java.sql.Types.TINYINT);else ps.setInt(5,rating);
                    ps.setString(6,visibility); ps.executeUpdate(); try(ResultSet keys=ps.getGeneratedKeys()){if(!keys.next())throw new SQLException("Không lấy được mã bài viết.");postId=keys.getInt(1);}
                }
                int order=0; for(StoredImage image:images) try(PreparedStatement ps=c.prepareStatement("INSERT dbo.PostImages(post_id,stored_name,original_name,content_type,display_order) VALUES(?,?,?,?,?)")) {ps.setInt(1,postId);ps.setString(2,image.storedName);ps.setString(3,image.originalName);ps.setString(4,image.contentType);ps.setInt(5,order++);ps.executeUpdate();}
                if(images.isEmpty() && (content==null||content.trim().isEmpty()) && rating==null) throw new SQLException("Bài viết cần có nội dung, đánh giá hoặc ảnh.");
                c.commit(); return postId;
            } catch(Exception e) { c.rollback(); if(e instanceof SQLException) throw (SQLException)e; if(e instanceof RuntimeException) throw (RuntimeException)e; throw new RuntimeException(e); }
            finally { c.setAutoCommit(true); }
        } catch(SQLException e) { throw failure("Không thể tạo bài Dump.",e); }
    }

    public static class StoredImage { public final String storedName,originalName,contentType; public StoredImage(String s,String o,String t){storedName=s;originalName=o;contentType=t;} }

    public boolean canViewPost(int postId,int viewerId) {
        String sql="SELECT p.user_id,p.visibility FROM dbo.Posts p WHERE p.post_id=? AND p.is_deleted=0";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setInt(1,postId);try(ResultSet rs=ps.executeQuery()){if(!rs.next())return false;int owner=rs.getInt(1);return owner==viewerId||"PUBLIC".equals(rs.getString(2))||areFriends(c,owner,viewerId);}}
        catch(SQLException e){throw failure("Không thể kiểm tra quyền xem bài viết.",e);}
    }

    public String getImageStoredName(int imageId) {
        String sql="SELECT i.stored_name FROM dbo.PostImages i JOIN dbo.Posts p ON p.post_id=i.post_id WHERE i.image_id=? AND p.is_deleted=0";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setInt(1,imageId);try(ResultSet rs=ps.executeQuery()){if(rs.next())return rs.getString(1);return null;}}
        catch(SQLException e){throw failure("Không thể tải ảnh.",e);}
    }
    public String getCheckInImageStoredName(int imageId,int userId) {
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement("SELECT ci.stored_name FROM dbo.CheckInImages ci JOIN dbo.CheckIns ch ON ch.checkin_id=ci.checkin_id WHERE ci.checkin_image_id=? AND ch.user_id=? AND ch.status='VERIFIED'")){ps.setInt(1,imageId);ps.setInt(2,userId);try(ResultSet rs=ps.executeQuery()){return rs.next()?rs.getString(1):null;}}
        catch(SQLException e){throw failure("Không thể tải ảnh check-in.",e);}
    }

    public int getImagePostId(int imageId) {
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement("SELECT post_id FROM dbo.PostImages WHERE image_id=?")){ps.setInt(1,imageId);try(ResultSet rs=ps.executeQuery()){return rs.next()?rs.getInt(1):-1;}}
        catch(SQLException e){throw failure("Không thể kiểm tra ảnh.",e);}
    }

    public void toggleLike(int postId,int userId) { toggleRelation("dbo.PostLikes",postId,userId); }
    public void toggleBookmark(int postId,int userId) { toggleRelation("dbo.PostBookmarks",postId,userId); }
    private void toggleRelation(String table,int postId,int userId) {
        if(!canViewPost(postId,userId)) throw new IllegalArgumentException("Bạn không có quyền truy cập bài viết này.");
        String delete="DELETE FROM "+table+" WHERE post_id=? AND user_id=?";
        try(Connection c=DBContext.getConnection();PreparedStatement d=c.prepareStatement(delete)){d.setInt(1,postId);d.setInt(2,userId);if(d.executeUpdate()==0){try(PreparedStatement i=c.prepareStatement("INSERT INTO "+table+"(post_id,user_id) VALUES(?,?)")){i.setInt(1,postId);i.setInt(2,userId);i.executeUpdate();}}}
        catch(SQLException e){throw failure("Không thể cập nhật tương tác bài viết.",e);}
    }
    public void addComment(int postId,int userId,String content) {
        if(!canViewPost(postId,userId))throw new IllegalArgumentException("Bạn không có quyền bình luận bài viết này.");
        if(content==null||content.trim().isEmpty()||content.trim().length()>1000)throw new IllegalArgumentException("Bình luận phải từ 1 đến 1000 ký tự.");
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement("INSERT dbo.PostComments(post_id,user_id,content) VALUES(?,?,?)")){ps.setInt(1,postId);ps.setInt(2,userId);ps.setString(3,content.trim());ps.executeUpdate();}
        catch(SQLException e){throw failure("Không thể gửi bình luận.",e);}
    }
    public void reportPost(int postId,int userId,String reason) {
        if(!canViewPost(postId,userId))throw new IllegalArgumentException("Bài viết không tồn tại hoặc bạn không có quyền xem.");
        if(reason==null||reason.trim().isEmpty()||reason.trim().length()>500)throw new IllegalArgumentException("Vui lòng nhập lý do báo cáo (tối đa 500 ký tự).");
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement("IF NOT EXISTS(SELECT 1 FROM dbo.PostReports WHERE post_id=? AND reporter_id=?) INSERT dbo.PostReports(post_id,reporter_id,reason) VALUES(?,?,?)")){ps.setInt(1,postId);ps.setInt(2,userId);ps.setInt(3,postId);ps.setInt(4,userId);ps.setString(5,reason.trim());ps.executeUpdate();}
        catch(SQLException e){throw failure("Không thể gửi báo cáo.",e);}
    }
    public void deleteOwnPost(int postId,int userId) {
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement("UPDATE dbo.Posts SET is_deleted=1,updated_at=SYSDATETIME() WHERE post_id=? AND user_id=?")){ps.setInt(1,postId);ps.setInt(2,userId);if(ps.executeUpdate()==0)throw new IllegalArgumentException("Bạn chỉ có thể xóa bài viết của mình.");}
        catch(SQLException e){throw failure("Không thể xóa bài viết.",e);}
    }

    public List<Map<String,Object>> searchUsers(String keyword,int currentUser) {
        List<Map<String,Object>> out=new ArrayList<Map<String,Object>>(); if(keyword==null||keyword.trim().length()<2)return out;
        String sql="SELECT TOP 20 u.user_id,u.full_name,u.email, f.status, f.requester_id FROM dbo.Users u LEFT JOIN dbo.Friendships f ON ((f.requester_id=? AND f.addressee_id=u.user_id) OR (f.requester_id=u.user_id AND f.addressee_id=?)) WHERE u.user_id<>? AND u.is_active=1 AND (u.full_name LIKE ? OR u.email LIKE ?) ORDER BY u.full_name";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setInt(1,currentUser);ps.setInt(2,currentUser);ps.setInt(3,currentUser);ps.setString(4,"%"+keyword.trim()+"%");ps.setString(5,"%"+keyword.trim()+"%");try(ResultSet rs=ps.executeQuery()){while(rs.next()){Map<String,Object> m=new LinkedHashMap<String,Object>();m.put("userId",rs.getInt(1));m.put("fullName",rs.getString(2));m.put("email",rs.getString(3));m.put("status",rs.getString(4));m.put("requesterId",rs.getObject(5));out.add(m);}}}
        catch(SQLException e){throw failure("Không thể tìm người dùng.",e);}return out;
    }
    public void sendFriendRequest(int from,int to) {
        if(from==to)throw new IllegalArgumentException("Không thể kết bạn với chính mình.");
        try(Connection c=DBContext.getConnection()) {if(areFriends(c,from,to))throw new IllegalArgumentException("Hai bạn đã là bạn bè.");
            try(PreparedStatement q=c.prepareStatement("SELECT friendship_id,status,requester_id FROM dbo.Friendships WHERE (requester_id=? AND addressee_id=?) OR (requester_id=? AND addressee_id=?)")){q.setInt(1,from);q.setInt(2,to);q.setInt(3,to);q.setInt(4,from);try(ResultSet rs=q.executeQuery()){if(rs.next()){String status=rs.getString("status");int requester=rs.getInt("requester_id");if("PENDING".equals(status)&&requester==to){try(PreparedStatement u=c.prepareStatement("UPDATE dbo.Friendships SET status='ACCEPTED',updated_at=SYSDATETIME() WHERE friendship_id=?")){u.setInt(1,rs.getInt("friendship_id"));u.executeUpdate();}return;}throw new IllegalArgumentException("Lời mời kết bạn đã tồn tại hoặc đã được xử lý.");}}}
            try(PreparedStatement i=c.prepareStatement("INSERT dbo.Friendships(requester_id,addressee_id,status) VALUES(?,?,'PENDING')")){i.setInt(1,from);i.setInt(2,to);i.executeUpdate();}
        }catch(SQLException e){throw failure("Không thể gửi lời mời kết bạn.",e);}
    }
    public void respondFriendRequest(int friendshipId,int userId,boolean accept) {
        String sql="UPDATE dbo.Friendships SET status=?,updated_at=SYSDATETIME() WHERE friendship_id=? AND addressee_id=? AND status='PENDING'";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setString(1,accept?"ACCEPTED":"DECLINED");ps.setInt(2,friendshipId);ps.setInt(3,userId);if(ps.executeUpdate()==0)throw new IllegalArgumentException("Lời mời không hợp lệ hoặc đã được xử lý.");}
        catch(SQLException e){throw failure("Không thể xử lý lời mời.",e);}
    }
    public List<Map<String,Object>> getFriendRequests(int userId) {
        List<Map<String,Object>> out=new ArrayList<Map<String,Object>>();String sql="SELECT f.friendship_id,u.user_id,u.full_name,u.email,f.created_at FROM dbo.Friendships f JOIN dbo.Users u ON u.user_id=f.requester_id WHERE f.addressee_id=? AND f.status='PENDING' ORDER BY f.created_at DESC";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setInt(1,userId);try(ResultSet rs=ps.executeQuery()){while(rs.next()){Map<String,Object> m=new LinkedHashMap<String,Object>();m.put("friendshipId",rs.getInt(1));m.put("userId",rs.getInt(2));m.put("fullName",rs.getString(3));m.put("email",rs.getString(4));m.put("createdAt",rs.getTimestamp(5));out.add(m);}}}catch(SQLException e){throw failure("Không thể tải lời mời kết bạn.",e);}return out;
    }

    private static double haversineMeters(double lat1,double lon1,double lat2,double lon2) {
        double earthRadius=6371000.0;
        double dLat=Math.toRadians(lat2-lat1), dLon=Math.toRadians(lon2-lon1);
        double a=Math.sin(dLat/2)*Math.sin(dLat/2)+Math.cos(Math.toRadians(lat1))*Math.cos(Math.toRadians(lat2))*Math.sin(dLon/2)*Math.sin(dLon/2);
        return earthRadius*2*Math.atan2(Math.sqrt(a),Math.sqrt(1-a));
    }

    public List<Map<String,Object>> getPostReports() {
        List<Map<String,Object>> out=new ArrayList<Map<String,Object>>();
        String sql="SELECT r.report_id,r.reason,r.status,r.created_at,reporter.full_name reporter_name,p.post_id,p.content,p.visibility,owner.full_name owner_name FROM dbo.PostReports r JOIN dbo.Users reporter ON reporter.user_id=r.reporter_id JOIN dbo.Posts p ON p.post_id=r.post_id JOIN dbo.Users owner ON owner.user_id=p.user_id ORDER BY CASE WHEN r.status='OPEN' THEN 0 ELSE 1 END,r.created_at DESC";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql);ResultSet rs=ps.executeQuery()) {while(rs.next()){Map<String,Object> m=new LinkedHashMap<String,Object>();m.put("reportId",rs.getInt(1));m.put("reason",rs.getString(2));m.put("status",rs.getString(3));m.put("createdAt",rs.getTimestamp(4));m.put("reporterName",rs.getString(5));m.put("postId",rs.getInt(6));m.put("content",rs.getString(7));m.put("visibility",rs.getString(8));m.put("ownerName",rs.getString(9));out.add(m);}}
        catch(SQLException e){throw failure("Không thể tải báo cáo Dump.",e);}return out;
    }
    public void updatePostReport(int reportId,String status) {
        if(!"REVIEWED".equals(status)&&!"DISMISSED".equals(status))throw new IllegalArgumentException("Trạng thái báo cáo không hợp lệ.");
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement("UPDATE dbo.PostReports SET status=? WHERE report_id=?")){ps.setString(1,status);ps.setInt(2,reportId);if(ps.executeUpdate()==0)throw new IllegalArgumentException("Không tìm thấy báo cáo.");}
        catch(SQLException e){throw failure("Không thể cập nhật báo cáo.",e);}
    }

    public int createCheckIn(int userId,int placeId,Integer tripId,double lat,double lng,double distance,String note,StoredImage photo) {
        if(distance<0||distance>200)throw new IllegalArgumentException("Bạn đang ở ngoài phạm vi check-in (200 m).");
        try(Connection c=DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                try(PreparedStatement q=c.prepareStatement("SELECT latitude,longitude FROM dbo.Places WHERE place_id=? AND is_active=1")){q.setInt(1,placeId);try(ResultSet rs=q.executeQuery()){if(!rs.next())throw new IllegalArgumentException("Địa điểm không tồn tại.");if(rs.getBigDecimal(1)==null||rs.getBigDecimal(2)==null)throw new IllegalArgumentException("Địa điểm chưa có tọa độ GPS, chưa thể check-in.");double actualDistance=haversineMeters(lat,lng,rs.getDouble(1),rs.getDouble(2));if(actualDistance>200.0)throw new IllegalArgumentException("Bạn đang ở ngoài phạm vi check-in (200 m). Khoảng cách ước tính: "+Math.round(actualDistance)+" m.");distance=actualDistance;}}
                if(tripId!=null){try(PreparedStatement q=c.prepareStatement("SELECT 1 FROM dbo.Trips t LEFT JOIN dbo.TripMembers tm ON tm.trip_id=t.trip_id AND tm.user_id=? WHERE t.trip_id=? AND (t.owner_id=? OR tm.user_id IS NOT NULL)")){q.setInt(1,userId);q.setInt(2,tripId);q.setInt(3,userId);try(ResultSet rs=q.executeQuery()){if(!rs.next())throw new IllegalArgumentException("Bạn không có quyền liên kết check-in với chuyến đi này.");}}}
                int id;String sql="INSERT dbo.CheckIns(user_id,place_id,trip_id,latitude,longitude,distance_meters,verification_method,status,has_photo,note) VALUES(?,?,?,?,?,?, 'GPS','VERIFIED',?,?)";
                try(PreparedStatement ps=c.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)){ps.setInt(1,userId);ps.setInt(2,placeId);if(tripId==null)ps.setNull(3,java.sql.Types.INTEGER);else ps.setInt(3,tripId);ps.setDouble(4,lat);ps.setDouble(5,lng);ps.setDouble(6,distance);ps.setBoolean(7,photo!=null);if(note==null||note.trim().isEmpty())ps.setNull(8,java.sql.Types.NVARCHAR);else ps.setString(8,note.trim().substring(0,Math.min(500,note.trim().length())));ps.executeUpdate();try(ResultSet rs=ps.getGeneratedKeys()){rs.next();id=rs.getInt(1);}}
                if(photo!=null)try(PreparedStatement image=c.prepareStatement("INSERT dbo.CheckInImages(checkin_id,stored_name,original_name,content_type) VALUES(?,?,?,?)")){image.setInt(1,id);image.setString(2,photo.storedName);image.setString(3,photo.originalName);image.setString(4,photo.contentType);image.executeUpdate();}
                awardEligibleBadges(c,userId);c.commit();return id;
            }catch(Exception e){c.rollback();if(e instanceof SQLException)throw (SQLException)e;if(e instanceof RuntimeException)throw (RuntimeException)e;throw new RuntimeException(e);}finally{c.setAutoCommit(true);}
        }catch(SQLException e){if(e.getErrorCode()==2627||e.getErrorCode()==2601)throw new IllegalArgumentException("Bạn đã check-in địa điểm này rồi. Check-in lặp lại không được tính thêm.");throw failure("Không thể lưu check-in.",e);}
    }

    private void awardEligibleBadges(Connection c,int userId) throws SQLException {
        List<int[]> badgeRows=new ArrayList<int[]>(); List<String> types=new ArrayList<String>();
        try(PreparedStatement ps=c.prepareStatement("SELECT b.badge_id,b.criteria_type,b.threshold FROM dbo.TravelBadges b WHERE b.is_active=1 AND NOT EXISTS(SELECT 1 FROM dbo.UserBadges ub WHERE ub.badge_id=b.badge_id AND ub.user_id=?)")) {
            ps.setInt(1,userId); try(ResultSet rs=ps.executeQuery()){while(rs.next()){badgeRows.add(new int[]{rs.getInt(1),rs.getInt(3)});types.add(rs.getString(2));}}
        }
        for(int i=0;i<badgeRows.size();i++) {
            int badgeId=badgeRows.get(i)[0], threshold=badgeRows.get(i)[1], count=0; String type=types.get(i);
            String countSql="UNIQUE_PLACES".equals(type)?"SELECT COUNT(DISTINCT place_id) FROM dbo.CheckIns WHERE user_id=? AND status='VERIFIED'":"PHOTO_CHECKINS".equals(type)?"SELECT COUNT(DISTINCT place_id) FROM dbo.CheckIns WHERE user_id=? AND status='VERIFIED' AND has_photo=1":"SELECT COUNT(DISTINCT ci.place_id) FROM dbo.CheckIns ci JOIN dbo.Places p ON p.place_id=ci.place_id JOIN dbo.Categories c ON c.category_id=p.category_id WHERE ci.user_id=? AND ci.status='VERIFIED' AND (c.category_name LIKE N'%tham quan%' OR c.category_name LIKE N'%sightseeing%' OR c.category_code LIKE '%SIGHT%')";
            try(PreparedStatement q=c.prepareStatement(countSql)){q.setInt(1,userId);try(ResultSet cr=q.executeQuery()){if(cr.next())count=cr.getInt(1);}}
            if(count>=threshold)try(PreparedStatement ins=c.prepareStatement("INSERT dbo.UserBadges(user_id,badge_id) VALUES(?,?)")){ins.setInt(1,userId);ins.setInt(2,badgeId);ins.executeUpdate();}
        }
    }

    public List<Map<String,Object>> getPassportCheckIns(int userId) {
        List<Map<String,Object>> out=new ArrayList<Map<String,Object>>();String sql="SELECT ci.checkin_id,ci.place_id,p.place_name,p.address,c.category_name,ci.checkin_time,ci.has_photo,ci.note,ci.trip_id,(SELECT TOP 1 checkin_image_id FROM dbo.CheckInImages chi WHERE chi.checkin_id=ci.checkin_id ORDER BY chi.checkin_image_id) AS image_id FROM dbo.CheckIns ci JOIN dbo.Places p ON p.place_id=ci.place_id JOIN dbo.Categories c ON c.category_id=p.category_id WHERE ci.user_id=? AND ci.status='VERIFIED' ORDER BY ci.checkin_time DESC";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setInt(1,userId);try(ResultSet rs=ps.executeQuery()){while(rs.next()){Map<String,Object> m=new LinkedHashMap<String,Object>();m.put("checkInId",rs.getInt(1));m.put("placeId",rs.getInt(2));m.put("placeName",rs.getString(3));m.put("address",rs.getString(4));m.put("categoryName",rs.getString(5));m.put("checkInTime",rs.getTimestamp(6));m.put("hasPhoto",rs.getBoolean(7));m.put("note",rs.getString(8));m.put("tripId",rs.getObject(9));m.put("imageId",rs.getObject(10));out.add(m);}}}catch(SQLException e){throw failure("Không thể tải Travel Passport.",e);}return out;
    }
    public List<Map<String,Object>> getBadges(int userId) {
        List<Map<String,Object>> out=new ArrayList<Map<String,Object>>();String sql="SELECT b.badge_id,b.badge_name,b.description,b.icon,b.criteria_type,b.threshold,ub.earned_at,"
                +"CASE WHEN ub.user_id IS NULL THEN 0 ELSE 1 END earned,"
                +"CASE WHEN b.criteria_type='UNIQUE_PLACES' THEN (SELECT COUNT(DISTINCT place_id) FROM dbo.CheckIns WHERE user_id=? AND status='VERIFIED') "
                +"WHEN b.criteria_type='PHOTO_CHECKINS' THEN (SELECT COUNT(DISTINCT place_id) FROM dbo.CheckIns WHERE user_id=? AND status='VERIFIED' AND has_photo=1) "
                +"ELSE (SELECT COUNT(DISTINCT ci.place_id) FROM dbo.CheckIns ci JOIN dbo.Places p ON p.place_id=ci.place_id JOIN dbo.Categories c ON c.category_id=p.category_id WHERE ci.user_id=? AND ci.status='VERIFIED' AND (c.category_name LIKE N'%tham quan%' OR c.category_name LIKE N'%sightseeing%' OR c.category_code LIKE '%SIGHT%')) END progress "
                +"FROM dbo.TravelBadges b LEFT JOIN dbo.UserBadges ub ON ub.badge_id=b.badge_id AND ub.user_id=? WHERE b.is_active=1 ORDER BY b.display_order,b.badge_id";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setInt(1,userId);ps.setInt(2,userId);ps.setInt(3,userId);ps.setInt(4,userId);try(ResultSet rs=ps.executeQuery()){while(rs.next()){Map<String,Object> m=new LinkedHashMap<String,Object>();m.put("badgeId",rs.getInt(1));m.put("badgeName",rs.getString(2));m.put("description",rs.getString(3));m.put("icon",rs.getString(4));m.put("criteriaType",rs.getString(5));m.put("threshold",rs.getInt(6));m.put("earnedAt",rs.getTimestamp(7));m.put("earned",rs.getInt(8)==1);m.put("progress",rs.getInt(9));out.add(m);}}}catch(SQLException e){throw failure("Không thể tải huy hiệu.",e);}return out;
    }
    public String getPassportVisibility(int userId) {
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement("SELECT visibility FROM dbo.TravelPassportSettings WHERE user_id=?")){ps.setInt(1,userId);try(ResultSet rs=ps.executeQuery()){return rs.next()?rs.getString(1):"PRIVATE";}}
        catch(SQLException e){throw failure("Không thể tải quyền riêng tư hộ chiếu.",e);}
    }
    public void setPassportVisibility(int userId,String visibility) {
        if(!"PRIVATE".equals(visibility)&&!"PUBLIC".equals(visibility))throw new IllegalArgumentException("Quyền riêng tư không hợp lệ.");
        String sql="IF EXISTS(SELECT 1 FROM dbo.TravelPassportSettings WHERE user_id=?) UPDATE dbo.TravelPassportSettings SET visibility=?,updated_at=SYSDATETIME() WHERE user_id=? ELSE INSERT dbo.TravelPassportSettings(user_id,visibility) VALUES(?,?)";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setInt(1,userId);ps.setString(2,visibility);ps.setInt(3,userId);ps.setInt(4,userId);ps.setString(5,visibility);ps.executeUpdate();}
        catch(SQLException e){throw failure("Không thể cập nhật quyền riêng tư hộ chiếu.",e);}
    }
    public boolean canViewPassport(int viewerId,int ownerId) { return viewerId==ownerId||"PUBLIC".equals(getPassportVisibility(ownerId)); }

    public Map<String,Object> getPassportSummary(int userId) {
        Map<String,Object> m=new LinkedHashMap<String,Object>();String sql="SELECT COUNT(DISTINCT place_id) place_count,COUNT(*) checkin_count,COUNT(DISTINCT trip_id) trip_count,SUM(CASE WHEN has_photo=1 THEN 1 ELSE 0 END) photo_count FROM dbo.CheckIns WHERE user_id=? AND status='VERIFIED'";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setInt(1,userId);try(ResultSet rs=ps.executeQuery()){if(rs.next()){m.put("placeCount",rs.getInt(1));m.put("checkInCount",rs.getInt(2));m.put("tripCount",rs.getInt(3));m.put("photoCount",rs.getInt(4));}}}catch(SQLException e){throw failure("Không thể thống kê hộ chiếu.",e);}
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement("SELECT COUNT(*) FROM dbo.UserBadges WHERE user_id=?")){ps.setInt(1,userId);try(ResultSet rs=ps.executeQuery()){m.put("badgeCount",rs.next()?rs.getInt(1):0);}}catch(SQLException e){throw failure("Không thể thống kê huy hiệu.",e);}return m;
    }
}
