<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>M-Pay Ar | Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>

<%
    // Navigation dynamique
    String p = request.getParameter("page");
    if (p == null) p = "home";

    java.util.List<String> allowedPages = java.util.Arrays.asList(
        "home", "history", "retrait", "parametre"
    );

    if (!allowedPages.contains(p)) p = "home";
%>

<div class="sidebar">
    <div class="logo">
        <i class="fas fa-wallet"></i> <span>M-PAY Ar</span>
    </div>

    <nav>
        <a href="index.jsp?page=home" class="nav-item <%= "home".equals(p)?"active":"" %>">
            <i class="fas fa-paper-plane"></i> <span>Envoyer</span>
        </a>

        <a href="index.jsp?page=retrait" class="nav-item <%= "retrait".equals(p)?"active":"" %>">
            <i class="fas fa-money-bill-wave"></i> <span>Retrait</span>
        </a>

        <a href="index.jsp?page=history" class="nav-item <%= "history".equals(p)?"active":"" %>">
            <i class="fas fa-history"></i> <span>Historique</span>
        </a>
    </nav>

    <div class="sidebar-footer" style="margin-top: auto;">
        <a href="index.jsp?page=parametre" class="nav-item <%= "parametre".equals(p)?"active":"" %>">
            <i class="fas fa-cog"></i> <span>Paramètres</span>
        </a>
        <a href="#" class="nav-item" style="color: #ff7675;">
            <i class="fas fa-sign-out-alt"></i> <span>Déconnexion</span>
        </a>
    </div>
</div>

<div class="main-content">

    <!-- Zone d'alerte -->
    <div class="alert-area">
        <%
            String s = request.getParameter("status");
            if (s != null) {
                String cls = s.startsWith("error") ? "alert error" : "alert success";
                String msg = "";
                String icon = s.startsWith("error") ? "fa-exclamation-triangle" : "fa-check-circle";

                switch(s) {
                    case "success": msg = "Opération réussie !"; break;
                    case "error_solde": msg = "Solde insuffisant."; break;
                    case "error_same_number": msg = "Numéro identique interdit."; break;
                    case "error_receiver_not_found": msg = "Destinataire introuvable."; break;
                    case "error_sender_not_found": msg = "Votre compte est introuvable."; break;
                    default: msg = "Erreur système ou problème de connexion.";
                }
                out.print("<div class='" + cls + " fade-in'><i class='fas " + icon + "'></i> " + msg + "</div>");
            }
        %>
    </div>

    <div class="page-container">
        <%-- Inclure la page correspondant au menu actif --%>
        <% if("retrait".equals(p)) { %>
            <%@ include file="retrait.jsp" %>
        <% } else if("history".equals(p)) { %>
            <%@ include file="history.jsp" %>
        <% } else if("parametre".equals(p)) { %>
            <%@ include file="parametre.jsp" %>
        <% } else { %>
            <%@ include file="home.jsp" %>
        <% } %>
    </div>

</div>

</body>
</html>
