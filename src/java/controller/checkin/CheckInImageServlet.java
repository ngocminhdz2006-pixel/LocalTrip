package controller.checkin;

import controller.dump.DumpServlet;
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

@WebServlet("/checkin/image")
public class CheckInImageServlet extends HttpServlet {
    private final TravelFeatureDAO dao=new TravelFeatureDAO();
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException {
        HttpSession s=req.getSession(false);User u=s==null?null:(User)s.getAttribute("user");if(u==null){resp.sendError(401);return;}
        int id;try{id=Integer.parseInt(req.getParameter("id"));if(id<1)throw new NumberFormatException();}catch(Exception e){resp.sendError(400);return;}
        String stored=dao.getCheckInImageStoredName(id,u.getUserId());if(stored==null||stored.contains("/")||stored.contains("\\")||stored.contains("..")){resp.sendError(404);return;}
        File file=new File(DumpServlet.getUploadDir(),stored);if(!file.isFile()){resp.sendError(404);return;}
        String type=stored.toLowerCase().endsWith(".png")?"image/png":stored.toLowerCase().endsWith(".webp")?"image/webp":"image/jpeg";resp.setContentType(type);resp.setHeader("X-Content-Type-Options","nosniff");resp.setHeader("Cache-Control","private, max-age=300");resp.setContentLengthLong(file.length());Files.copy(file.toPath(),resp.getOutputStream());
    }
}
