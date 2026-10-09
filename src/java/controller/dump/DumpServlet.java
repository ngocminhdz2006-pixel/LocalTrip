package controller.dump;

import dao.TravelFeatureDAO;
import dao.PlaceDAO;
import dao.TripDAO;
import dao.TravelFeatureDAO.StoredImage;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import model.User;

@WebServlet({"/dump", "/dump/create", "/dump/action", "/dump/friends"})
@MultipartConfig(fileSizeThreshold=1024*1024, maxFileSize=5*1024*1024, maxRequestSize=30*1024*1024)
public class DumpServlet extends HttpServlet {
    private final TravelFeatureDAO dao = new TravelFeatureDAO();
    private final PlaceDAO placeDAO = new PlaceDAO();
    private final TripDAO tripDAO = new TripDAO();
    private static final int MAX_IMAGES=5;

    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp) throws ServletException,IOException {
        req.setCharacterEncoding("UTF-8");
        User user=currentUser(req,resp); if(user==null)return;
        ensureCsrf(req.getSession());
        String path=req.getServletPath();
        try {
            if("/dump/friends".equals(path)) {
                String keyword=req.getParameter("q");
                req.setAttribute("searchResults",dao.searchUsers(keyword,user.getUserId()));
                req.setAttribute("friendRequests",dao.getFriendRequests(user.getUserId()));
                req.setAttribute("keyword",keyword==null?"":keyword);
                req.getRequestDispatcher("/WEB-INF/views/dump/friends.jsp").forward(req,resp); return;
            }
            req.setAttribute("places",placeDAO.findAll());
            req.setAttribute("trips",tripDAO.findByUser(user.getUserId()));
            req.setAttribute("posts",dao.getFeed(user.getUserId(),"BOOKMARKS".equals(req.getParameter("filter"))?"BOOKMARKS":"ALL"));
            req.setAttribute("bookmarksOnly","BOOKMARKS".equals(req.getParameter("filter")));
            req.getRequestDispatcher("/WEB-INF/views/dump/feed.jsp").forward(req,resp);
        } catch(RuntimeException e) { throw new ServletException("Không thể tải Dump.",e); }
    }

    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp) throws ServletException,IOException {
        req.setCharacterEncoding("UTF-8");
        User user=currentUser(req,resp); if(user==null)return;
        if(!validCsrf(req)) { req.getSession().setAttribute("errorMessage","Phiên gửi biểu mẫu đã hết hạn. Vui lòng thử lại."); resp.sendRedirect(req.getContextPath()+"/dump");return; }
        String path=req.getServletPath();
        try {
            if("/dump/create".equals(path)) { createPost(req,user); req.getSession().setAttribute("successMessage","Đã đăng bài lên Dump."); resp.sendRedirect(req.getContextPath()+"/dump");return; }
            if("/dump/friends".equals(path)) { handleFriendAction(req,user); resp.sendRedirect(req.getContextPath()+"/dump/friends");return; }
            String action=req.getParameter("action"); int postId=parsePositive(req.getParameter("postId"));
            if("like".equals(action))dao.toggleLike(postId,user.getUserId());
            else if("bookmark".equals(action))dao.toggleBookmark(postId,user.getUserId());
            else if("comment".equals(action))dao.addComment(postId,user.getUserId(),req.getParameter("content"));
            else if("report".equals(action))dao.reportPost(postId,user.getUserId(),req.getParameter("reason"));
            else if("delete".equals(action))dao.deleteOwnPost(postId,user.getUserId());
            else throw new IllegalArgumentException("Thao tác không hợp lệ.");
            req.getSession().setAttribute("successMessage", "like".equals(action)?"Đã cập nhật lượt thích.":"bookmark".equals(action)?"Đã cập nhật bài viết đã lưu.":"comment".equals(action)?"Đã gửi bình luận.":"report".equals(action)?"Đã gửi báo cáo cho quản trị viên.":"Đã xóa bài viết.");
        } catch(IllegalArgumentException e) { req.getSession().setAttribute("errorMessage",e.getMessage()); }
        catch(RuntimeException e) { throw new ServletException("Không thể xử lý thao tác Dump.",e); }
        resp.sendRedirect(req.getContextPath()+("BOOKMARKS".equals(req.getParameter("returnTo"))?"/dump?filter=BOOKMARKS":"/dump"));
    }

    private void createPost(HttpServletRequest req,User user) throws IOException,ServletException {
        String content=trim(req.getParameter("content")); if(content!=null&&content.length()>2000)throw new IllegalArgumentException("Cảm nhận tối đa 2000 ký tự.");
        Integer placeId=optionalPositive(req.getParameter("placeId")); Integer tripId=optionalPositive(req.getParameter("tripId"));
        String visibility="FRIENDS".equals(req.getParameter("visibility"))?"FRIENDS":"PUBLIC";
        Integer rating=null; String r=trim(req.getParameter("rating")); if(r!=null){try{rating=Integer.valueOf(r);}catch(NumberFormatException e){throw new IllegalArgumentException("Đánh giá không hợp lệ.");}if(rating<1||rating>5)throw new IllegalArgumentException("Đánh giá phải từ 1 đến 5 sao.");}
        List<Part> parts=new ArrayList<Part>(); for(Part part:req.getParts()) if("images".equals(part.getName())&&part.getSize()>0)parts.add(part);
        if(parts.size()>MAX_IMAGES)throw new IllegalArgumentException("Mỗi bài viết được tải tối đa 5 ảnh.");
        File uploadDir=getUploadDir(); List<StoredImage> images=new ArrayList<StoredImage>(); List<File> written=new ArrayList<File>();
        try {
            for(Part part:parts) {
                if(part.getSize()>5L*1024*1024)throw new IllegalArgumentException("Mỗi ảnh tối đa 5 MB.");
                String type=detectImageType(part); if(type==null)throw new IllegalArgumentException("Chỉ chấp nhận ảnh JPG, PNG hoặc WEBP hợp lệ.");
                String stored=UUID.randomUUID().toString().replace("-","")+"."+type.substring(type.indexOf('/')+1).replace("jpeg","jpg");
                File target=new File(uploadDir,stored); try(InputStream in=part.getInputStream()){Files.copy(in,target.toPath(),StandardCopyOption.REPLACE_EXISTING);} written.add(target);
                String original=part.getSubmittedFileName(); if(original!=null){original=original.replace('\\','/');original=original.substring(original.lastIndexOf('/')+1);if(original.length()>255)original=original.substring(original.length()-255);}
                images.add(new StoredImage(stored,original,type));
            }
            dao.createPost(user.getUserId(),placeId,tripId,content,rating,visibility,images);
        } catch(RuntimeException|IOException e) { for(File f:written)try{Files.deleteIfExists(f.toPath());}catch(IOException ignored){} throw e; }
    }
    private void handleFriendAction(HttpServletRequest req,User user) {
        String action=req.getParameter("action");
        if("send".equals(action))dao.sendFriendRequest(user.getUserId(),parsePositive(req.getParameter("targetUserId")));
        else if("accept".equals(action)||"decline".equals(action))dao.respondFriendRequest(parsePositive(req.getParameter("friendshipId")),user.getUserId(),"accept".equals(action));
        else throw new IllegalArgumentException("Thao tác bạn bè không hợp lệ.");
        req.getSession().setAttribute("successMessage","accept".equals(action)?"Đã chấp nhận lời mời kết bạn.":"decline".equals(action)?"Đã từ chối lời mời kết bạn.":"Đã gửi lời mời kết bạn.");
    }
    public static File getUploadDir() throws IOException {
        String base=System.getProperty("catalina.base"); if(base==null||base.trim().isEmpty())base=System.getProperty("java.io.tmpdir");
        File dir=new File(base,"LocalTripUploads/dump"); if(!dir.exists()&&!dir.mkdirs())throw new IOException("Không thể tạo thư mục lưu ảnh an toàn."); return dir;
    }
    private String detectImageType(Part part) throws IOException {
        byte[] h=new byte[12]; int n; try(InputStream in=part.getInputStream()){n=in.read(h);} if(n>=3&&(h[0]&255)==255&&(h[1]&255)==216&&(h[2]&255)==255)return "image/jpeg";
        if(n>=8&&(h[0]&255)==137&&h[1]==80&&h[2]==78&&h[3]==71&&h[4]==13&&h[5]==10&&h[6]==26&&h[7]==10)return "image/png";
        if(n>=12&&h[0]=='R'&&h[1]=='I'&&h[2]=='F'&&h[3]=='F'&&h[8]=='W'&&h[9]=='E'&&h[10]=='B'&&h[11]=='P')return "image/webp";
        return null;
    }
    private User currentUser(HttpServletRequest req,HttpServletResponse resp)throws IOException {HttpSession s=req.getSession(false);User u=s==null?null:(User)s.getAttribute("user");if(u==null){resp.sendRedirect(req.getContextPath()+"/login");return null;}return u;}
    private void ensureCsrf(HttpSession s){if(s.getAttribute("travelCsrf")==null)s.setAttribute("travelCsrf",UUID.randomUUID().toString());}
    private boolean validCsrf(HttpServletRequest req){Object token=req.getSession().getAttribute("travelCsrf");return token instanceof String&&((String)token).equals(req.getParameter("csrfToken"));}
    private int parsePositive(String value){try{int n=Integer.parseInt(value);if(n>0)return n;}catch(Exception ignored){}throw new IllegalArgumentException("Mã không hợp lệ.");}
    private Integer optionalPositive(String value){if(value==null||value.trim().isEmpty())return null;return Integer.valueOf(parsePositive(value));}
    private String trim(String s){if(s==null)return null;s=s.trim();return s.isEmpty()?null:s;}
}
