package com.mpay.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/GetFraisServlet")
public class GetFraisServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String type = request.getParameter("type");
        double montant = Double.parseDouble(request.getParameter("montant"));

        double frais = 0;

        try {
            Class.forName("org.postgresql.Driver");
            Connection conn = DriverManager.getConnection(
                    "jdbc:postgresql://localhost:5432/mobile_money",
                    "postgres", "0701");

            String sql = "SELECT frais FROM parametres " +
                         "WHERE type_op=? AND ? BETWEEN montant_min AND montant_max";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, type);
            ps.setDouble(2, montant);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) frais = rs.getDouble("frais");

            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.getWriter().print(frais);
    }
}
