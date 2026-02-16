package com.mpay.servlet;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/ParametreServlet")
public class ParametreServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String typeOp = request.getParameter("type_op"); // "RETRAIT" ou "ENVOI"
        String montantMin = request.getParameter("montant_min");
        String montantMax = request.getParameter("montant_max");
        String frais = request.getParameter("frais");

        if(typeOp == null || montantMin == null || montantMax == null || frais == null) {
            response.sendRedirect("index.jsp?page=parametre&status=error_data");
            return;
        }

        try {
            double min = Double.parseDouble(montantMin);
            double max = Double.parseDouble(montantMax);
            double f = Double.parseDouble(frais);

            Class.forName("org.postgresql.Driver");
            try(Connection conn = DriverManager.getConnection(
                    "jdbc:postgresql://localhost:5432/mobile_money", "postgres", "0701")) {

                String sql = "INSERT INTO parametres(type_op, montant_min, montant_max, frais) VALUES (?,?,?,?)";
                try(PreparedStatement p = conn.prepareStatement(sql)) {
                    p.setString(1, typeOp.toUpperCase());
                    p.setDouble(2, min);
                    p.setDouble(3, max);
                    p.setDouble(4, f);
                    p.executeUpdate();
                }
            }

            response.sendRedirect("index.jsp?page=parametre&status=success");

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?page=parametre&status=error_system");
        }
    }
}
