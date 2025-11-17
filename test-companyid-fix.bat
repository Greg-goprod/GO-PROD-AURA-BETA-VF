@echo off
echo Test de la correction du companyId dans PerformanceModal...
echo.

echo ================================================
echo PROBLÈME IDENTIFIÉ
echo ================================================
echo.
echo ❌ Page Artistes: Utilise getCurrentCompanyId() → Vrai company_id
echo ❌ PerformanceModal: Utilise localStorage → UUID par défaut inexistant
echo.
echo 🔍 Cause: Différence dans la récupération du company_id
echo.
echo ================================================
echo CORRECTION IMPLÉMENTÉE
echo ================================================
echo.
echo ✅ BookingPage.tsx modifié pour utiliser getCurrentCompanyId()
echo ✅ Même méthode que la page Artistes
echo ✅ Fallback vers localStorage si getCurrentCompanyId échoue
echo.
echo ================================================
echo TEST À EFFECTUER
echo ================================================
echo.

echo 1. Ouvrir http://localhost:5178/app/booking
echo.
echo 2. Vérifier dans la console:
echo    ✅ "Récupération du company_id..." (si getCurrentCompanyId fonctionne)
echo    ✅ Plus d'erreur de clé étrangère
echo.
echo 3. Cliquer sur "➕ Ajouter une performance"
echo.
echo 4. Cliquer sur "+ Ajouter un artiste"
echo.
echo 5. Saisir un nom d'artiste et cliquer "Enregistrer"
echo.
echo 6. Vérifier le succès:
echo    ✅ "✅ Compagnie par défaut créée" (si nécessaire)
echo    ✅ "✅ Artiste inséré avec succès"
echo    ✅ Retour au modal Performance
echo    ✅ Nouvel artiste dans la liste
echo.
echo ================================================
echo COMPARAISON AVEC PAGE ARTISTES
echo ================================================
echo.
echo Les deux modaux devraient maintenant utiliser
echo la même méthode de récupération du company_id !
echo.
echo Testez les deux pour confirmer:
echo 1. Page Artistes → Ajouter un artiste
echo 2. Page Booking → Ajouter une performance → Ajouter un artiste
echo.
pause

