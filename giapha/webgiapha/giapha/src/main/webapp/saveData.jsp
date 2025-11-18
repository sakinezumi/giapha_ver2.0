<%@ page contentType="application/json; charset=UTF-8" language="java" %>
<%@ include file="db_config.jspf" %>
<%
    if (!request.getMethod().equalsIgnoreCase("POST")) {
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        out.print("{\"error\":\"Method not allowed\"}");
        return;
    }

    StringBuilder jsonBody = new StringBuilder();
    try (java.io.BufferedReader reader = request.getReader()) {
        String line;
        while ((line = reader.readLine()) != null) {
            jsonBody.append(line);
        }
    }
    
    String keyName = null;
    String jsonValue = null;

    try {
        keyName = request.getParameter("key");
        jsonValue = request.getParameter("value");
    } catch (Exception e) {
        Logger.getLogger("SaveData").log(Level.SEVERE, "Error parsing request", e);
    }
    
    if (keyName == null || jsonValue == null) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("{\"error\":\"Missing key or value\"}");
        return;
    }

    Connection conn = getConnection();
    if (conn != null) {
        String sql = "INSERT INTO app_storage (key_name, json_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE json_value = VALUES(json_value)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, keyName);
            ps.setString(2, jsonValue);
            ps.executeUpdate();
            out.print("{\"status\":\"success\"}");
        } catch (SQLException e) {
            Logger.getLogger("SaveData").log(Level.SEVERE, "SQL Error", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Database error\"}");
        } finally {
            conn.close();
        }
    } else {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("{\"error\":\"DB Connection error\"}");
    }
%>