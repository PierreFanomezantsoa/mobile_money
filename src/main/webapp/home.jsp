<%@ page import="java.sql.*" %>

<%
    // ================================
    // EXPEDITEUR PAR DEFAUT
    // ================================
    String numExpDefault = (String) session.getAttribute("user_tel");
    if (numExpDefault == null || numExpDefault.isEmpty())
        numExpDefault = "0342626760";

    String montantDefault = request.getParameter("montant");
    if (montantDefault == null) montantDefault = "0";
%>

<div class="transaction-layout">

    <!-- ================= FORMULAIRE ================= -->
    <div class="transaction-box">
        <h3>Transférer de l'argent</h3>

        <form action="TransactionServlet" method="post">

            <input type="hidden" name="num_exp" value="<%= numExpDefault %>">

            <label>Numéro destinataire</label>
            <input type="text" name="num_rec" required>

            <label>Montant (Ar)</label>
            <input type="number" id="mt" name="montant"
                   value="<%= montantDefault %>" min="100" required>

            <label style="margin-top:15px;">
                <input type="checkbox" id="addFr" name="add_frais_retrait">
                Ajouter frais de retrait du récepteur
            </label>

            <input type="hidden" name="type_op" value="ENVOI">

            <button type="submit" class="btn-send">
                Valider l'envoi
            </button>
        </form>
    </div>

    <!-- ================= RECAP ================= -->
    <div class="ticket">
        <h4>Récapitulatif</h4>

        <p>Montant :
            <b id="viewMt">0</b> Ar
        </p>

        <p>Frais d'envoi :
            <b id="viewFe">0</b> Ar
        </p>

        <p id="sectionFr" style="display:none;">
            Frais retrait :
            <b id="viewFr">0</b> Ar
        </p>

        <hr>

        <p>Total débité :
            <b id="viewTotal">0</b> Ar
        </p>
    </div>

</div>

<!-- ================= JAVASCRIPT ================= -->
<script>

const mtInput = document.getElementById("mt");
const checkbox = document.getElementById("addFr");

// =====================
// Appel servlet frais
// =====================
async function getFrais(type, montant) {

    const response = await fetch(
        "GetFraisServlet?type=" + type + "&montant=" + montant
    );

    const text = await response.text();
    return parseFloat(text) || 0;
}

// =====================
// Mise à jour récap
// =====================
async function updateRecap() {

    let mt = parseFloat(mtInput.value);

    if (isNaN(mt) || mt <= 0) {
        document.getElementById("viewMt").innerText = "0";
        document.getElementById("viewFe").innerText = "0";
        document.getElementById("viewFr").innerText = "0";
        document.getElementById("viewTotal").innerText = "0";
        return;
    }

    document.getElementById("viewMt").innerText = mt.toLocaleString();

    // ===== FRAIS ENVOI =====
    let fraisEnvoi = await getFrais("ENVOI", mt);
    document.getElementById("viewFe").innerText = fraisEnvoi.toLocaleString();

    let total = mt + fraisEnvoi;

    // ===== FRAIS RETRAIT =====
    if (checkbox.checked) {

        let fraisRetrait = await getFrais("RETRAIT", mt);

        document.getElementById("sectionFr").style.display = "block";
        document.getElementById("viewFr").innerText = fraisRetrait.toLocaleString();

        total += fraisRetrait;

    } else {

        document.getElementById("sectionFr").style.display = "none";
        document.getElementById("viewFr").innerText = "0";
    }

    // ===== TOTAL =====
    document.getElementById("viewTotal").innerText = total.toLocaleString();
}

// =====================
// EVENTS
// =====================
mtInput.addEventListener("input", updateRecap);
checkbox.addEventListener("change", updateRecap);

// lancement initial
updateRecap();

</script>
