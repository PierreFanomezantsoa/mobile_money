package com.mpay.servlet;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
@WebServlet("/TransactionServlet")
public class TransactionServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private static final String DB_URL = "jdbc:postgresql://localhost:5432/mobile_money";
    private static final String DB_USER = "postgres";
    private static final String DB_PASS = "0701";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String numExp = (String) request.getSession().getAttribute("user_tel");
        if (numExp == null || numExp.isEmpty()) numExp = "0342626760";

        String numRec = request.getParameter("num_rec");
        String mtStr = request.getParameter("montant");

        boolean addFraisRetrait = request.getParameter("add_frais_retrait") != null;

        if (mtStr == null || mtStr.isEmpty()) {
            response.sendRedirect("index.jsp?page=transfert&status=error_data");
            return;
        }

        try {
            double montant = Double.parseDouble(mtStr);

            Class.forName("org.postgresql.Driver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

                conn.setAutoCommit(false);

                try {

                    // ===============================
                    // 🔥 RECUPERATION FRAIS ENVOI
                    // ===============================
                    double fraisEnvoi = getFrais(conn, "ENVOI", montant);

                    // ===============================
                    // 🔥 RECUPERATION FRAIS RETRAIT
                    // ===============================
                    double fraisRetrait = 0;
                    if (addFraisRetrait) {
                        fraisRetrait = getFrais(conn, "RETRAIT", montant);
                    }

                    double total = montant + fraisEnvoi + fraisRetrait;

                    // ===============================
                    // Vérifier solde
                    // ===============================
                    double solde = getSolde(conn, numExp);
                    if (solde < total) {
                        conn.rollback();
                        response.sendRedirect("index.jsp?page=transfert&status=error_solde_custom");
                        return;
                    }

                    // ===============================
                    // Vérifier destinataire
                    // ===============================
                    if (!clientExiste(conn, numRec)) {
                        conn.rollback();
                        response.sendRedirect("index.jsp?page=transfert&status=error_receiver_not_found");
                        return;
                    }

                    // ===============================
                    // Débit / Crédit
                    // ===============================
                    updateSolde(conn, -total, numExp);
                    updateSolde(conn, montant, numRec);

                    // ===============================
                    // Sauvegarde transaction
                    // ===============================
                    saveTransaction(conn, numExp, numRec, montant, fraisEnvoi, fraisRetrait, "ENVOI");

                    conn.commit();
                    response.sendRedirect("index.jsp?page=transfert&status=success");

                } catch (Exception e) {
                    conn.rollback();
                    throw e;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?page=transfert&status=error_system");
        }
    }

    // ============================================
    // 🔥 METHODE CALCUL FRAIS PAR TRANCHE
    // ============================================
    private double getFrais(Connection conn, String typeOp, double montant) throws SQLException {

        String sql = "SELECT frais FROM parametres " +
                     "WHERE type_op=? AND ? BETWEEN montant_min AND montant_max";

        try (PreparedStatement p = conn.prepareStatement(sql)) {
            p.setString(1, typeOp);
            p.setDouble(2, montant);

            ResultSet rs = p.executeQuery();
            if (rs.next()) return rs.getDouble("frais");
        }
        return 0;
    }

    private boolean clientExiste(Connection c, String tel) throws SQLException {
        try (PreparedStatement p = c.prepareStatement("SELECT id FROM clients WHERE numero_tel=?")) {
            p.setString(1, tel);
            return p.executeQuery().next();
        }
    }

    private double getSolde(Connection c, String tel) throws SQLException {
        try (PreparedStatement p = c.prepareStatement("SELECT solde FROM clients WHERE numero_tel=?")) {
            p.setString(1, tel);
            ResultSet rs = p.executeQuery();
            return rs.next() ? rs.getDouble("solde") : 0;
        }
    }

    private void updateSolde(Connection c, double m, String tel) throws SQLException {
        try (PreparedStatement p = c.prepareStatement(
                "UPDATE clients SET solde = solde + ? WHERE numero_tel=?")) {
            p.setDouble(1, m);
            p.setString(2, tel);
            p.executeUpdate();
        }
    }

    private void saveTransaction(Connection c, String ex, String re, double m,
                                 double fe, double fr, String typeOp) throws SQLException {

        String sql = "INSERT INTO transactions(numero_expediteur, numero_recepteur, montant_principal, frais_envoi, frais_retrait, type_op, date_op) VALUES (?,?,?,?,?,?,NOW())";

        try (PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, ex);
            p.setString(2, re);
            p.setDouble(3, m);
            p.setDouble(4, fe);
            p.setDouble(5, fr);
            p.setString(6, typeOp);
            p.executeUpdate();
        }
    }
}
