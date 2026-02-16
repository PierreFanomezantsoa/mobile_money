package com.mpay.servlet;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/SupprimerTransactionServlet")
public class SupprimerHistoriqueServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String DB_URL = "jdbc:postgresql://localhost:5432/mobile_money";
    private static final String DB_USER = "postgres";
    private static final String DB_PASS = "0701";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");

        // =========================
        // Vérification paramètre
        // =========================
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect("index.jsp?page=history&status=invalid_id");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);

            Class.forName("org.postgresql.Driver");

            String sql = "DELETE FROM transactions WHERE id = ?";

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setInt(1, id);

                int rows = ps.executeUpdate();

                // =========================
                // Résultat suppression
                // =========================
                if (rows > 0) {
                    response.sendRedirect("index.jsp?page=history&status=deleted");
                } else {
                    response.sendRedirect("index.jsp?page=history&status=not_found");
                }
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("index.jsp?page=history&status=invalid_id");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?page=history&status=error");
        }
    }
}