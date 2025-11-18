<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ include file="db_config.jspf" %>
<%@ page import="java.sql.*, java.util.logging.*" %>
<%!
  public int getMemberCountFromStorage(Connection conn) {
    int count = 0;
    String sql = "SELECT JSON_LENGTH(json_value, '$.members') FROM app_storage WHERE key_name = 'gp_family'";
    try (Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery(sql)) {
      if (rs.next()) {
        count = rs.getInt(1);
      }
    } catch (SQLException e) {
      Logger.getLogger("Index").log(Level.SEVERE, "Error counting members", e);
    }
    return count;
  }

  public String getLastUpdateTimeFromStorage(Connection conn) {
    String lastUpdate = "—";
    String sql = "SELECT updated_at FROM app_storage WHERE key_name = 'gp_family'";
    try (Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery(sql)) {
      if (rs.next()) {
        lastUpdate = getTimestampString(rs.getTimestamp(1));
      }
    } catch (SQLException e) {
      Logger.getLogger("Index").log(Level.SEVERE, "Error getting last update time", e);
    }
    return lastUpdate;
  }
%>
<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Gia Phả — Trang chủ</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
  <header class="navbar">
    <div class="brand-wrap">
      <a class="brand" href="index.jsp">GiaPhả<span class="brand-dot">.</span></a>
      <nav class="main-menu" aria-label="Chức năng chính">
        <a href="phado.jsp" class="menu-item">Phả đồ</a>
        <a href="quantri.jsp" class="menu-item">Quản trị</a>
        <a href="xuatfile.jsp" class="menu-item">Xuất file</a>
      </nav>
    </div>

    <div class="nav-actions">
      <button class="btn ghost" id="btnLogin">Đăng nhập</button>
      <button class="btn" id="btnRegister">Đăng ký</button>
    </div>
  </header>

  <main class="container">
    <section class="hero card">
      <div class="hero-left">
        <h1>Quản lý Gia Phả — Gọn, đẹp, trực quan</h1>
        <p class="muted">Chọn một chức năng ở menu để bắt đầu. Hệ thống hiện đang dùng MySQL Database.</p>
        <div class="hero-actions">
          <a class="btn large" href="phado.jsp">Mở Phả đồ</a>
          <a class="btn ghost large" href="quantri.jsp">Mở Quản trị</a>
        </div>
      </div>

      <div class="hero-stats">
<%
    int memberCount = 0;
    String lastUpdate = "—";
    Connection conn = getConnection();
    if (conn != null) {
        memberCount = getMemberCountFromStorage(conn);
        lastUpdate = getLastUpdateTimeFromStorage(conn);
        conn.close();
    }
%>
        <div class="stat card-mini">
          <div class="stat-title">Thành viên</div>
          <div class="stat-value" id="statMembers"><%= memberCount %></div>
        </div>
        <div class="stat card-mini">
          <div class="stat-title">Nhánh hoạt động</div>
          <div class="stat-value">Tổ tiên → B1</div>
        </div>
        <div class="stat card-mini">
          <div class="stat-title">Cập nhật</div>
          <div class="stat-value" id="statUpdated"><%= lastUpdate %></div>
        </div>
      </div>
    </section>

    <section class="cards-grid">
      <a class="card" href="phado.jsp">
        <div class="card-emoji">🌳</div>
        <h3>Phả đồ</h3>
        <p>Xem & chỉnh cấu trúc gia đình — thêm đời đầu, thêm/xóa, chỉnh sửa, đường hôn phối.</p>
      </a>

      <a class="card" href="quantri.jsp">
        <div class="card-emoji">🛠️</div>
        <h3>Quản trị</h3>
        <p>Theo dõi hoạt động, phân quyền, thêm tài khoản quản trị.</p>
      </a>

      <a class="card" href="xuatfile.jsp">
        <div class="card-emoji">📤</div>
        <h3>Xuất file</h3>
        <p>Xuất toàn bộ / nhánh hiện tại / thành viên thành PDF / Excel / JSON.</p>
      </a>
    </section>
  </main>

  <footer class="footer">
    <div>© 2025 GiaPhả Demo (DB Edition)</div>
    <div>Phiên bản: 1.0</div>
  </footer>
</body>
</html>