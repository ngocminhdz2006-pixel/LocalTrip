# LocalTrip — Collaborative Travel Planning Web Application

LocalTrip is a production-ready Java Servlet 3.1 / JSP / JSTL web application for group itinerary planning, travel taste synchronization, real-time activity tracking, and expense settlement.

---

## 🚀 Quick Start for Developers

### 1. Database Setup
Ensure Microsoft SQL Server (2017+) is running. Run the consolidated reset script:
```powershell
sqlcmd -S localhost -U sa -P <YOUR_SA_PASSWORD> -i "sql\LocalTripDB_RESET.sql"
```
For detailed migration instructions and test accounts, see [`sql/README.md`](file:///d:/PRJ301_Project_LocalTrip/LocalTrip/LocalTrip/sql/README.md).

### 2. Configure Database Connection (`context.xml`)
The real `context.xml` is excluded from version control for security. To configure your local connection:

1. Copy the sample file:
   ```powershell
   Copy-Item web\META-INF\context.xml.sample web\META-INF\context.xml
   ```
2. Edit `web/META-INF/context.xml` and supply your database user and password:
   ```xml
   <Resource name="jdbc/LocalTripDB"
             auth="Container"
             type="javax.sql.DataSource"
             driverClassName="com.microsoft.sqlserver.jdbc.SQLServerDriver"
             url="jdbc:sqlserver://localhost:1433;databaseName=LocalTripDB;encrypt=false;trustServerCertificate=true"
             username="YOUR_DB_USER"
             password="YOUR_DB_PASSWORD"
             maxTotal="20"
             maxIdle="10"
             maxWaitMillis="10000"
             validationQuery="SELECT 1"
             testOnBorrow="true"/>
   ```
   *Alternatively, configure the JNDI resource in Tomcat's server-level `$CATALINA_BASE/conf/context.xml` or set environment variables `DB_USER` and `DB_PASSWORD`.*

### 3. Build & Deploy
Compile and package the application with Apache Ant:
```powershell
ant clean dist
```
Deploy `dist/LocalTrip.war` to Apache Tomcat 9 (`webapps/`).

---

## 🔒 Production Security Hardening

For production environments (`APP_ENV=production`):
- Run [`sql/create_app_user.sql`](file:///d:/PRJ301_Project_LocalTrip/LocalTrip/LocalTrip/sql/create_app_user.sql) to create a dedicated, least-privileged database user (`localtrip_app`).
- The startup listener [`DatabaseSecurityListener`](file:///d:/PRJ301_Project_LocalTrip/LocalTrip/LocalTrip/src/java/listener/DatabaseSecurityListener.java) enforces that the user is NOT `sa`, the password is not default, and `encrypt=true;trustServerCertificate=false`.
- For complete production deployment guidelines, consult [`docs/DEPLOYMENT.md`](file:///d:/PRJ301_Project_LocalTrip/LocalTrip/LocalTrip/docs/DEPLOYMENT.md).

---

## 🧪 Testing & Verification
- Detailed 13-step manual test script: [`docs/SMOKE_TEST.md`](file:///d:/PRJ301_Project_LocalTrip/LocalTrip/LocalTrip/docs/SMOKE_TEST.md).
