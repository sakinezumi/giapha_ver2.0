<%@ page contentType="application/json; charset=UTF-8" language="java" %>
<%@ include file="db_config.jspf" %>
<%
    String keyName = request.getParameter("key");
    String jsonValue = "null";
    Timestamp updatedAt = null;
    
    if (keyName != null && !keyName.isEmpty()) {
        Connection conn = getConnection();
        if (conn != null) {
            String sql = "SELECT json_value, updated_at FROM app_storage WHERE key_name = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, keyName);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        jsonValue = rs.getString("json_value");
                        updatedAt = rs.getTimestamp("updated_at");
                    }
                }
            } catch (SQLException e) {
                Logger.getLogger("LoadData").log(Level.SEVERE, "SQL Error", e);
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"Database error\"}");
                return;
            } finally {
                conn.close();
            }
        }
    }

    if (keyName.equals("gp_family")) {
        out.print("{\"value\":" + jsonValue + ", \"updated\":\"" + getTimestampString(updatedAt) + "\"}");
    } else {
        out.print(jsonValue);
    }
%>