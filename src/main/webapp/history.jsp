<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
    // Gestion des messages de statut
    String status = request.getParameter("status");
%>

<% if ("deleted".equals(status)) { %>
    <div style="padding: 15px; background: #dff9fb; color: #2d3436; border-radius: 12px; margin-bottom: 20px;">
        Historique supprimé avec succès !
    </div>
<% } else if ("error".equals(status)) { %>
    <div style="padding: 15px; background: #fab1a0; color: #2d3436; border-radius: 12px; margin-bottom: 20px;">
        Une erreur est survenue lors de la suppression.
    </div>
<% } %>

<!-- Bouton Supprimer tout l'historique -->
<div style="margin-bottom: 20px; text-align: right;">
    <form action="SupprimerHistoriqueServlet" method="post" onsubmit="return confirm('Voulez-vous vraiment supprimer tout l\'historique ?');">
        <button type="submit"
                style="padding: 12px 25px; background: #d63031; color: white; border: none; border-radius: 12px; font-weight: 700; cursor: pointer;">
            Supprimer tout l'historique
        </button>
    </form>
</div>

<%
    // Initialisation des compteurs
    double totalEnvoi = 0;
    int nbEnvoi = 0;
    double totalRetrait = 0;
    int nbRetrait = 0;

    List<Map<String, Object>> transactions = new ArrayList<>();

    try {
        Class.forName("org.postgresql.Driver");
        Connection cn = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/mobile_money",
                "postgres", "0701");

        String sql = "SELECT id, numero_expediteur, numero_recepteur, montant_principal, frais_envoi, frais_retrait, type_op, date_op " +
                     "FROM transactions ORDER BY date_op DESC";

        try (PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> t = new HashMap<>();
                int id = rs.getInt("id"); // identifiant unique
                String type = rs.getString("type_op");
                double montant = rs.getDouble("montant_principal");
                double fraisEnvoi = rs.getDouble("frais_envoi");
                double fraisRetrait = rs.getDouble("frais_retrait");

                t.put("id", id);
                t.put("date", rs.getTimestamp("date_op"));
                t.put("exp", rs.getString("numero_expediteur"));
                t.put("rec", rs.getString("numero_recepteur"));
                t.put("montant", montant);
                t.put("f_envoi", fraisEnvoi);
                t.put("f_retrait", fraisRetrait);
                t.put("type", type);

                // Statistiques
                if ("ENVOI".equalsIgnoreCase(type)) {
                    totalEnvoi += montant + fraisEnvoi + fraisRetrait; 
                    nbEnvoi++;
                } else if ("RETRAIT".equalsIgnoreCase(type)) {
                    totalRetrait += montant + fraisRetrait;
                    nbRetrait++;
                }

                transactions.add(t);
            }
        }
        cn.close();
    } catch(Exception e) {
        request.setAttribute("dbError", e.getMessage());
    }
%>

<section class="fade-in">
    <h2 style="font-weight: 800; color: #2d3436; margin-bottom: 25px;">Historique des Opérations</h2>

    <div class="stats-container" style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 30px;">
        <div class="stat-card" style="background: white; padding: 20px; border-radius: 15px; border-left: 5px solid #ffcc00;">
            <div style="color: #636e72; font-size: 0.9rem; font-weight: 600;">TOTAL ENVOIS</div>
            <div style="font-size: 1.8rem; font-weight: 800; color: #2d3436; margin: 5px 0;">
                <%= String.format("%,.0f", totalEnvoi) %> Ar
            </div>
            <div style="color: #ffcc00; font-weight: 600;"><i class="fas fa-paper-plane"></i> <%= nbEnvoi %> transactions</div>
        </div>
        <div class="stat-card" style="background: white; padding: 20px; border-radius: 15px; border-left: 5px solid #2d3436;">
            <div style="color: #636e72; font-size: 0.9rem; font-weight: 600;">TOTAL RETRAITS</div>
            <div style="font-size: 1.8rem; font-weight: 800; color: #2d3436; margin: 5px 0;">
                <%= String.format("%,.0f", totalRetrait) %> Ar
            </div>
            <div style="color: #636e72; font-weight: 600;"><i class="fas fa-money-bill-wave"></i> <%= nbRetrait %> transactions</div>
        </div>
    </div>

    <div class="history-box" style="background: white; padding: 20px; border-radius: 20px;">
        <table class="history-table" style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr>
                    <th>Date</th>
                    <th>Numéro</th>
                    <th>Montant</th>
                    <th>Frais</th>
                    <th>Type</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
            <% if (request.getAttribute("dbError") != null) { %>
                <tr><td colspan="6" style="color: red; padding: 20px;">Erreur : <%= request.getAttribute("dbError") %></td></tr>
            <% } else if (transactions.isEmpty()) { %>
                <tr><td colspan="6" style="text-align:center; padding: 40px; color: #b2bec3;">Aucune transaction trouvée.</td></tr>
            <% } else {
                for (Map<String,Object> t : transactions) {
                    String type = (String) t.get("type");
                    double frais = 0;
                    String fraisLabel = "";
                    if ("ENVOI".equalsIgnoreCase(type)) {
                        double fEnvoi = (double)t.get("f_envoi");
                        double fRetrait = (double)t.get("f_retrait");
                        frais = fEnvoi + fRetrait;
                        fraisLabel = fRetrait>0 ? String.format("%,.0f", fEnvoi) + " + " + String.format("%,.0f", fRetrait) + " (frais retrait)" : String.format("%,.0f", fEnvoi);
                    } else {
                        frais = (double)t.get("f_retrait");
                        fraisLabel = String.format("%,.0f", frais);
                    }
                    String rec = t.get("rec")==null||t.get("rec").toString().isEmpty() ? "-" : (String)t.get("rec");
            %>
                <tr>
                    <td><%= t.get("date") %></td>
                    <td><%= rec %></td>
                    <td><%= String.format("%,.0f", t.get("montant")) %> Ar</td>
                    <td style="color:#d63031;"><%= fraisLabel %> Ar</td>
                    <td><span style="padding: 5px 10px; border-radius: 8px; font-weight:bold; border:1px solid <%= "ENVOI".equalsIgnoreCase(type)?"#ffcc00":"#2d3436" %>; color:<%= "ENVOI".equalsIgnoreCase(type)?"#ffcc00":"#2d3436" %>;"><%= type %></span></td>
                    <td>
                        <form action="SupprimerTransactionServlet" method="post" onsubmit="return confirm('Supprimer cette transaction ?');">
                            <input type="hidden" name="id" value="<%= t.get("id") %>">
                            <button type="submit" style="background:#d63031;color:white;border:none;padding:5px 10px;border-radius:8px;cursor:pointer;">Supprimer</button>
                        </form>
                    </td>
                </tr>
            <% } } %>
            </tbody>
        </table>
    </div>
</section>
