<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<section class="fade-in">
    <div class="header-flex" style="display: flex; align-items: center; gap: 15px; margin-bottom: 25px;">
        <div style="background: #2d3436; color: white; width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem;">
            <i class="fas fa-cog"></i>
        </div>
        <div>
            <h2 style="font-weight: 800; color: #2d3436; margin: 0;">Paramètres des frais</h2>
            <p style="color: #636e72; margin: 0; font-size: 0.9rem;">Définissez les frais pour les transactions</p>
        </div>
    </div>

    <div class="transaction-layout" style="display: grid; grid-template-columns: 1fr 1fr; gap: 30px;">

        <!-- Formulaire pour ajouter frais -->
        <div class="transaction-box" style="background: white; padding: 30px; border-radius: 20px; box-shadow: 0 10px 25px rgba(0,0,0,0.05);">
            <form action="ParametreServlet" method="post">
                <label>Type d'opération</label>
                <select name="type_op" required style="width: 100%; padding: 12px; border-radius: 12px; border:2px solid #eee; margin-bottom: 20px;">
                    <option value="RETRAIT">Retrait</option>
                    <option value="ENVOI">Envoi</option>
                </select>

                <label>Montant minimum</label>
                <input type="number" name="montant_min" placeholder="Ex: 0" min="0" required
                       style="width: 100%; padding: 12px; border-radius: 12px; border:2px solid #eee; margin-bottom: 20px;">

                <label>Montant maximum</label>
                <input type="number" name="montant_max" placeholder="Ex: 10000" min="0" required
                       style="width: 100%; padding: 12px; border-radius: 12px; border:2px solid #eee; margin-bottom: 20px;">

                <label>Frais (Ar)</label>
                <input type="number" name="frais" placeholder="Ex: 300" min="0" required
                       style="width: 100%; padding: 12px; border-radius: 12px; border:2px solid #eee; margin-bottom: 20px;">

                <button type="submit" class="btn-send"
                        style="width: 100%; padding: 16px; background: #2d3436; color: white; border: none; border-radius: 12px; font-weight: 800;">
                    Ajouter / Modifier
                </button>
            </form>
        </div>

        <!-- Liste des frais existants -->
        <div class="summary-side" style="overflow-x: auto;">
            <div class="ticket" style="background: white; border-radius: 15px; padding: 25px; box-shadow: 0 10px 20px rgba(0,0,0,0.05); border-top: 5px solid #2d3436;">
                <h4 style="margin: 0 0 20px 0; font-size: 0.8rem; letter-spacing: 1px; color: #b2bec3; text-transform: uppercase;">
                    Liste des frais définis
                </h4>

                <table style="width:100%; border-collapse: collapse;">
                    <tr style="background: #dfe6e9; font-weight: bold;">
                        <th style="padding: 8px; border: 1px solid #b2bec3;">Type</th>
                        <th style="padding: 8px; border: 1px solid #b2bec3;">Montant min</th>
                        <th style="padding: 8px; border: 1px solid #b2bec3;">Montant max</th>
                        <th style="padding: 8px; border: 1px solid #b2bec3;">Frais</th>
                    </tr>

                    <%
                        try {
                            Class.forName("org.postgresql.Driver");
                            try(Connection conn = DriverManager.getConnection(
                                    "jdbc:postgresql://localhost:5432/mobile_money","postgres","0701");
                                Statement st = conn.createStatement();
                                ResultSet rs = st.executeQuery("SELECT * FROM parametres ORDER BY type_op, montant_min")) {

                                while(rs.next()) {
                    %>
                    <tr>
                        <td style="padding: 8px; border: 1px solid #b2bec3;"><%= rs.getString("type_op") %></td>
                        <td style="padding: 8px; border: 1px solid #b2bec3;"><%= rs.getDouble("montant_min") %></td>
                        <td style="padding: 8px; border: 1px solid #b2bec3;"><%= rs.getDouble("montant_max") %></td>
                        <td style="padding: 8px; border: 1px solid #b2bec3;"><%= rs.getDouble("frais") %></td>
                    </tr>
                    <%      }
                            }
                        } catch(Exception e) {
                            out.print("<tr><td colspan='4'>Erreur: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </table>
            </div>
        </div>

    </div>

    <!-- Messages de statut -->
    <div class="alert-area" style="margin-top: 20px;">
     <%
    String status = request.getParameter("status"); // Changement de variable
    if(status != null) {
        String cls = status.startsWith("error") ? "alert error" : "alert success";
        String msg = "";
        switch(status) {
            case "success": msg = "Frais ajoutés avec succès !"; break;
            case "error_data": msg = "Veuillez remplir tous les champs."; break;
            case "error_system": msg = "Erreur système, contactez l'administrateur."; break;
            default: msg = "Erreur inconnue."; break;
        }
        out.print("<div class='" + cls + " fade-in' style='margin-bottom:15px; padding:10px; border-radius:8px;'>" + msg + "</div>");
    }
%>

    </div>
</section>
