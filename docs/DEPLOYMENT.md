# LocalTrip — Production Deployment & Security Configuration Guide

This guide details environment variables, database credential management, connection pooling, and production security hardening for the **LocalTrip** web application (Java Servlet 3.1 / Tomcat 9 / SQL Server).

---

## ⚠️ CRITICAL SECURITY NOTICE: Credential Rotation

> [!CAUTION]
> **Legacy Password Compromise in Historical Commits:**
> Previous revisions of this codebase included default credentials (`sa` / `12345`) committed in version control.
> If your SQL Server instance has ever run with `sa` password `12345`, **YOU MUST IMMEDIATELY ROTATE THE PASSWORD** and provision a dedicated, least-privileged application user.
> Never run production databases using the `sa` account or the legacy password.

---

## 🔐 Environment Variables & JVM System Properties

The application resolves configuration by inspecting environment variables first, then JVM system properties (e.g. `-DAPP_ENV=production`), with fallback to safe defaults.

| Variable / Property | Type | Description | Development Default | Production Requirement |
| :--- | :--- | :--- | :--- | :--- |
| `APP_ENV` | String | Application environment mode (`development` or `production`) | `development` | Must be `production` |
| `DB_URL` | String | Full custom JDBC connection string (overrides individual host/port/name settings) | `null` | Optional (if provided, must include `encrypt=true;trustServerCertificate=false`) |
| `DB_SERVER` / `DB_HOST` | String | SQL Server host name or IP address | `localhost` | Production database host |
| `DB_PORT` | Integer | SQL Server port | `1433` | Production database port |
| `DB_NAME` | String | Catalog / Database name | `LocalTripDB` | `LocalTripDB` |
| `DB_USER` | String | Database login username | `sa` (with warning) | **Forbidden to be `sa`**. Must use dedicated user (e.g. `localtrip_app`) |
| `DB_PASSWORD` | String | Database login secret | `""` | **Required**. Cannot be empty or `12345` |
| `DB_ENCRYPT` | Boolean | Enforce TLS transport encryption (`true` / `false`) | `false` | **Must be `true`** |
| `DB_TRUST_CERT` | Boolean | Trust unverified server certificates (`true` / `false`) | `true` | **Must be `false`** |

---

## 🚀 Setting Up the Database Connection

LocalTrip supports two connection architectures:
1. **Container JNDI Pool (`jdbc/LocalTripDB`):** Preferred in production for high-throughput connection pooling.
2. **Direct `DriverManager` Fallback:** Used for local development and non-container CLI / diagnostic tests.

### 1. Local Development Setup
1. Copy the sample context file:
   ```powershell
   Copy-Item web\META-INF\context.xml.sample web\META-INF\context.xml
   ```
2. Open `web/META-INF/context.xml` (this file is excluded from git via `.gitignore`).
3. Set your local database credentials:
   ```xml
   <Resource name="jdbc/LocalTripDB"
             auth="Container"
             type="javax.sql.DataSource"
             driverClassName="com.microsoft.sqlserver.jdbc.SQLServerDriver"
             url="jdbc:sqlserver://localhost:1433;databaseName=LocalTripDB;encrypt=false;trustServerCertificate=true"
             username="YOUR_LOCAL_USER"
             password="YOUR_LOCAL_PASSWORD"
             maxTotal="20"
             maxIdle="10"
             maxWaitMillis="10000"
             validationQuery="SELECT 1"
             testOnBorrow="true"/>
   ```
4. In non-production mode (`APP_ENV=development`), if insecure settings like `sa` or `trustServerCertificate=true` are detected, the system will log a `WARNING` but will continue operating for developer convenience.

---

### 2. Production Deployment Setup

#### Step 1: Provision Least-Privilege Database User
Run the provisioning script [`sql/create_app_user.sql`](file:///d:/PRJ301_Project_LocalTrip/LocalTrip/LocalTrip/sql/create_app_user.sql) as SQL Server administrator:
```powershell
sqlcmd -S your-prod-sql-server -U sa -P <ADMIN_PASSWORD> -i "sql\create_app_user.sql"
```
This script creates a dedicated login `localtrip_app` with:
- `db_datareader` (Read access to data)
- `db_datawriter` (Write access to data)
- `EXECUTE` (Stored procedures if required)
- **NO `db_owner` role, NO `sysadmin` role**.

#### Step 2: Configure Server-Level JNDI Pool in Tomcat
Instead of embedding production passwords in application WAR files, configure the JNDI resource at the Tomcat container level:

Add the resource into `$CATALINA_BASE/conf/context.xml` or `$CATALINA_BASE/conf/server.xml` inside `<GlobalNamingResources>`:
```xml
<Resource name="jdbc/LocalTripDB"
          auth="Container"
          type="javax.sql.DataSource"
          driverClassName="com.microsoft.sqlserver.jdbc.SQLServerDriver"
          url="jdbc:sqlserver://your-db-host:1433;databaseName=LocalTripDB;encrypt=true;trustServerCertificate=false"
          username="localtrip_app"
          password="<STRONG_PRODUCTION_SECRET>"
          maxTotal="50"
          maxIdle="20"
          minIdle="5"
          maxWaitMillis="10000"
          validationQuery="SELECT 1"
          testOnBorrow="true"/>
```
And ensure the JDBC driver (`mssql-jdbc` or `sqljdbc4.jar`) is placed in `$CATALINA_HOME/lib` so the container connection pool can load the driver class.

#### Step 3: Set Production Environment Variables
Set the environment flags on your host or container runner (Docker / Kubernetes / Systemd):
```bash
export APP_ENV=production
export DB_USER=localtrip_app
export DB_PASSWORD='<STRONG_PRODUCTION_SECRET>'
export DB_ENCRYPT=true
export DB_TRUST_CERT=false
```

---

## 🛡️ Startup Fail-Fast Security Listener (`DatabaseSecurityListener`)

When the application boots in Tomcat, the `@WebListener` [`DatabaseSecurityListener`](file:///d:/PRJ301_Project_LocalTrip/LocalTrip/LocalTrip/src/java/listener/DatabaseSecurityListener.java) executes prior to serving any HTTP request.

### Enforced Policies when `APP_ENV=production`:
1. **Password Enforcement:** Password cannot be null, empty, or legacy default `"12345"`.
2. **Account Least Privilege:** Database user cannot be `"sa"`.
3. **Transport Security:** Connection MUST specify `encrypt=true` and `trustServerCertificate=false`.

If any policy is violated, the listener logs a `SEVERE` error with the specific failure reasons and throws an `IllegalStateException`, halting application deployment immediately to prevent running with compromised credentials.


---

## 🔒 Web Security Hardening: Cookies, Proxy & Content Security Policy

### 1. Reverse Proxy & HTTPS (`X-Forwarded-Proto`)
When deploying behind a reverse proxy (e.g., NGINX, Cloudflare, AWS ALB), TLS is typically terminated at the proxy. To ensure Tomcat and the application know the original request scheme was HTTPS without blindly trusting spoofed headers:

Configure Tomcat's `RemoteIpValve` in `$CATALINA_BASE/conf/server.xml` inside `<Host name="localhost" ...>`:
```xml
<Valve className="org.apache.catalina.valves.RemoteIpValve"
       internalProxies="127\.0\.0\.1|::1|10\..*|192\.168\..*|172\.(1[6-9]|2[0-9]|3[0-1])\..*"
       remoteIpHeader="x-forwarded-for"
       protocolHeader="x-forwarded-proto"
       protocolHeaderHttpsValue="https" />
```
- **Security Rule:** `request.isSecure()` returns `true` and the `Secure` cookie flag is applied only when the request originates from an authorized proxy listed in `internalProxies`.
- In application code, `RememberMeUtil.isSecure(request)` verifies `request.isSecure()` and only accepts `X-Forwarded-Proto` if `request.getRemoteAddr()` matches trusted loopback addresses.

### 2. Cookie Security: SameSite & HttpOnly
- **Session Cookie (`JSESSIONID`):** Configured with `SameSite=Lax` via Tomcat's `<CookieProcessor sameSiteCookies="lax"/>` in `web/META-INF/context.xml` and `LocalTrip.xml`. `HttpOnly` is declared in `web.xml`.
- **Remember-Me Cookie (`LOCALTRIP_REMEMBER`):** Emitted manually via `Set-Cookie` with `SameSite=Lax; HttpOnly; Path=/LocalTrip[; Secure]` (and cleared with `Max-Age=0`).

### 3. Content Security Policy (CSP)
Managed by `filter.AuthFilter`:
- **Allowed External Hosts:**
  - `cdn.jsdelivr.net` (Bootstrap 5 CSS & JS)
  - `unpkg.com` (Leaflet map library CSS & JS)
  - `fonts.googleapis.com` & `fonts.gstatic.com` (Google Fonts)
  - `api.qrserver.com` & `img.vietqr.io` (QR code generation)
  - `images.unsplash.com` & `commons.wikimedia.org` (Curated place & cover imagery)
  - `tile.openstreetmap.org` & `*.openstreetmap.org` (Map tiles)
  - `router.project-osrm.org` (OSRM public routing API)
  - `api.open-meteo.com` (Weather forecast API)
- **Deployment Mode:**
  - Default: `Content-Security-Policy-Report-Only` (prevents breaking legacy inline scripts/handlers).
  - Enforcing Mode Switch: Set `private static final boolean CSP_ENFORCE = true;` in `src/java/filter/AuthFilter.java` once all inline script tags are replaced with nonces/hashes.

### 4. PBKDF2 Password Hashing (OWASP Standard)
- Iteration count is set to **600,000** iterations (`PBKDF2WithHmacSHA256`) in `utils.PasswordUtil`.
- **Automatic Rehash-on-Login:** When a user with an older hash (e.g., 20,000 iterations) logs in successfully, the application transparently upgrades their stored hash in `Users.password_hash` to 600,000 iterations without requiring a password reset.
