<section class="fade-in">
    <div class="header-flex" style="display: flex; align-items: center; gap: 15px; margin-bottom: 25px;">
        <div style="background: #2d3436; color: white; width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem;">
            <i class="fas fa-hand-holding-usd"></i>
        </div>
        <div>
            <h2 style="font-weight: 800; color: #2d3436; margin: 0;">Retrait d'argent</h2>
            <p style="color: #636e72; margin: 0; font-size: 0.9rem;">Récupérez vos fonds en toute sécurité</p>
        </div>
    </div>

    <div class="transaction-layout" style="display: grid; grid-template-columns: 1fr 350px; gap: 30px;">
        <!-- Formulaire retrait -->
        <div class="transaction-box" style="background: white; padding: 30px; border-radius: 20px; box-shadow: 0 10px 25px rgba(0,0,0,0.05);">
            <form action="RetraitServlet" method="post" id="retraitForm">
                <label>Numéro de l'expéditeur</label>
                <input type="text" name="num_exp" placeholder="Ex: 034xxxxxxx" required
                       style="width: 100%; padding: 12px; border-radius: 12px; border:2px solid #eee; margin-bottom: 20px;">

                <label>Montant à retirer (Ar)</label>
                <input type="number" name="montant" id="montantInput" placeholder="Ex: 10000" min="100" required
                       style="width: 100%; padding: 12px; border-radius: 12px; border:2px solid #eee; margin-bottom: 20px;">

                <button type="submit" class="btn-send" style="width: 100%; padding: 16px; background: #2d3436; color: white; border: none; border-radius: 12px; font-weight: 800;">
                    Confirmer le retrait
                </button>
            </form>
        </div>

        <!-- Ticket récap -->
        <div class="summary-side">
            <div class="ticket" style="background: white; border-radius: 15px; padding: 25px; box-shadow: 0 10px 20px rgba(0,0,0,0.05); border-top: 5px solid #2d3436;">
                <h4 style="margin: 0 0 20px 0; font-size: 0.8rem; letter-spacing: 1px; color: #b2bec3; text-transform: uppercase;">Récapitulatif</h4>

                <div style="display: flex; justify-content: space-between; margin-bottom: 12px;">
                    <span style="color: #636e72;">Montant</span>
                    <span id="viewMontant" style="font-weight: 700;">0 Ar</span>
                </div>

                <div style="display: flex; justify-content: space-between; margin-bottom: 12px;">
                    <span style="color: #636e72;">Frais de retrait</span>
                    <span id="viewFrais" style="font-weight: 700; color:#d63031;">+ 0 Ar</span>
                </div>

                <hr style="border: none; border-top: 1px dashed #eee; margin: 15px 0;">

                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <span style="font-weight: 800; color: #2d3436;">Total débité</span>
                    <span id="viewTotal" style="font-size: 1.3rem; font-weight: 900; color: #2d3436;">0 Ar</span>
                </div>
            </div>
        </div>
    </div>
</section>

<script>
const montantInput = document.getElementById('montantInput');

function calculFraisRetrait(montant) {
    if (montant <= 1000) return 100;
    if (montant <= 5000) return 200;
    if (montant <= 10000) return 300;
    return 1500;
}

function updateTicket() {
    let montant = parseFloat(montantInput.value) || 0;
    let frais = montant > 0 ? calculFraisRetrait(montant) : 0;

    document.getElementById('viewMontant').innerText = montant.toLocaleString() + " Ar";
    document.getElementById('viewFrais').innerText = "+ " + frais.toLocaleString() + " Ar";
    document.getElementById('viewTotal').innerText = (montant + frais).toLocaleString() + " Ar";
}

montantInput.addEventListener('input', updateTicket);
updateTicket();
</script>
