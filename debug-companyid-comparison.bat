@echo off
echo Script de débogage pour comparer les company_id...
echo.

echo ================================================
echo DÉBOGAGE COMPANY_ID
echo ================================================
echo.

echo 1. Ouvrir la console du navigateur (F12)
echo.
echo 2. Aller sur la page Artistes:
echo    http://localhost:5178/app/artistes
echo.
echo 3. Dans la console, exécuter:
echo    console.log("Page Artistes - companyId:", companyId);
echo.
echo 4. Aller sur la page Booking:
echo    http://localhost:5178/app/booking
echo.
echo 5. Dans la console, exécuter:
echo    console.log("Page Booking - companyId:", companyId);
echo.
echo 6. Comparer les deux valeurs:
echo    ✅ Si identiques → Correction réussie
echo    ❌ Si différentes → Problème persistant
echo.
echo ================================================
echo VÉRIFICATION SUPABASE
echo ================================================
echo.
echo 7. Dans la console, exécuter:
echo    supabase.from("companies").select("*").then(console.log);
echo.
echo 8. Vérifier que la compagnie existe avec le bon UUID
echo.
echo ================================================
echo TEST MODAL ADDARTIST
echo ================================================
echo.
echo 9. Page Artistes → Bouton "Ajouter un artiste"
echo    - Vérifier le companyId passé au modal
echo    - Tester la création d'artiste
echo.
echo 10. Page Booking → Ajouter performance → Ajouter artiste
echo     - Vérifier le companyId passé au modal
echo     - Tester la création d'artiste
echo.
echo ================================================
echo RÉSULTAT ATTENDU
echo ================================================
echo.
echo Les deux modaux devraient maintenant utiliser
echo le même company_id et fonctionner identiquement !
echo.
pause

