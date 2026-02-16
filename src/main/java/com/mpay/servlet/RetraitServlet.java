package com.mpay.servlet;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/RetraitServlet")
public class RetraitServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String DB_URL = "jdbc:postgresql://localhost:5432/mobile_money";
    private static final String DB_USER = "postgres";
    private static final String DB_PASS = "0701";
    private static final String RECEPTEUR_RETRAIT = "0342626760"; // compte central pour retrait

    // Méthode calcul frais retrait selon montant
    private double getFraisRetrait(double montant) {
        if (montant <= 1000) return 100;
        if (montant <= 5000) return 200;
        if (montant <= 10000) return 300;
        return 1500;
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String numExp = request.getParameter("num_exp");
        String mtStr = request.getParameter("montant");

        if (numExp == null || numExp.isEmpty() || mtStr == null || mtStr.isEmpty()) {
            response.sendRedirect("index.jsp?page=retrait&status=error_data");
            return;
        }

        try {
            double montant = Double.parseDouble(mtStr);
            double frais = getFraisRetrait(montant);
            double totalADeduire = montant + frais;

            Class.forName("org.postgresql.Driver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

                conn.setAutoCommit(false);

                try {
                    double solde = getSolde(conn, numExp);
                    if (solde < totalADeduire) {
                        conn.rollback();
                        response.sendRedirect("index.jsp?page=retrait&status=error_solde");
                        return;
                    }

                    // Débit expéditeur
                    updateSolde(conn, -totalADeduire, numExp);

                    // Sauvegarde transaction
                    saveTransaction(conn, numExp, RECEPTEUR_RETRAIT, montant, 0, frais, "RETRAIT");

                    conn.commit();
                    response.sendRedirect("index.jsp?page=retrait&status=success");

                } catch (Exception e) {
                    conn.rollback();
                    e.printStackTrace();
                    response.sendRedirect("index.jsp?page=retrait&status=error_system");
                }
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("index.jsp?page=retrait&status=error_format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?page=retrait&status=error_system");
        }
    }

    private double getSolde(Connection c, String tel) throws SQLException {
        try (PreparedStatement p = c.prepareStatement("SELECT solde FROM clients WHERE numero_tel=?")) {
            p.setString(1, tel);
            ResultSet rs = p.executeQuery();
            return rs.next() ? rs.getDouble("solde") : 0;
        }
    }

    private void updateSolde(Connection c, double montant, String tel) throws SQLException {
        try (PreparedStatement p = c.prepareStatement(
                "UPDATE clients SET solde = solde + ? WHERE numero_tel=?")) {
            p.setDouble(1, montant);
            p.setString(2, tel);
            p.executeUpdate();
        }
    }

    private void saveTransaction(Connection c, String exp, String rec, double montant,
                                 double fraisEnvoi, double fraisRetrait, String typeOp)
            throws SQLException {
        String sql = "INSERT INTO transactions(numero_expediteur, numero_recepteur, montant_principal, " +
                     "frais_envoi, frais_retrait, type_op, date_op) VALUES (?,?,?,?,?,?,NOW())";
        try (PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, exp);
            p.setString(2, rec);
            p.setDouble(3, montant);
            p.setDouble(4, fraisEnvoi);
            p.setDouble(5, fraisRetrait);
            p.setString(6, typeOp);
            p.executeUpdate();
        }
    }
}
