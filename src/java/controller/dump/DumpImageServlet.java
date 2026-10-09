package controller.dump;

import dao.TravelFeatureDAO;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;

/** Streams protected Dump images only after checking post visibility. */
@WebServlet("/dump/image")
public class DumpImageServlet extends HttpServlet {
    private final TravelFeatureDAO dao=new TravelFeatureDAO();
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException {
        HttpSession session=req.getSession(false);User user=session==null?null:(User)session.getAttribute("user");
        if(user==null){resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);return;}
        int imageId;try{imageId=Integer.parseInt(req.getParameter("id"));if(imageId<1)throw new NumberFormatException();}catch(Exception e){resp.sendError(400);return;}
        int postId=dao.getImagePostId(imageId);if(postId<1||!dao.canViewPost(postId,user.getUserId())){resp.sendError(HttpServletResponse.SC_NOT_FOUND);return;}
        String stored=dao.getImageStoredName(imageId);if(stored==null||stored.contains("/")||stored.contains("\\")||stored.contains("..")){resp.sendError(404);return;}
        File file=new File(DumpServlet.getUploadDir(),stored);if(!file.isFile()){resp.sendError(404);return;}
        String type=stored.toLowerCase().endsWith(".png")?"image/png":stored.toLowerCase().endsWith(".webp")?"image/webp":"image/jpeg";
        resp.setContentType(type);resp.setHeader("X-Content-Type-Options","nosniff");resp.setHeader("Cache-Control","private, max-age=300");resp.setContentLengthLong(file.length());Files.copy(file.toPath(),resp.getOutputStream());
    }
}
