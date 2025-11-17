@echo off
echo Test d'intégration complète du modal Performance avec AddArtistModal...
echo.

echo ================================================
echo ÉTAPES DE TEST
echo ================================================
echo.

echo 1. DÉMARRER LE SERVEUR:
echo    npm run dev
echo.
echo 2. OUVRIR LE BOOKING:
echo    http://localhost:5177/app/booking
echo.
echo 3. OUVRIR LE MODAL PERFORMANCE:
echo    Cliquer sur "➕ Ajouter une performance"
echo.
echo 4. TESTER L'AJOUT D'ARTISTE:
echo    - Cliquer sur "+ Ajouter un artiste"
echo    - Vérifier que AddArtistModal s'ouvre
echo    - Saisir un nom d'artiste (ex: "Test Artist")
echo    - Optionnel: Cliquer sur "Rechercher sur Spotify"
echo    - Cliquer sur "Enregistrer"
echo.
echo 5. VÉRIFIER L'INTÉGRATION:
echo    ✅ AddArtistModal se ferme
echo    ✅ PerformanceModal reste ouvert
echo    ✅ Liste des artistes se recharge
echo    ✅ Nouvel artiste dans le select
echo    ✅ Toast de succès affiché
echo.
echo 6. COMPLÉTER LA PERFORMANCE:
echo    - Sélectionner le nouvel artiste
echo    - Remplir jour, scène, heure, durée
echo    - Cliquer sur "Enregistrer"
echo.
echo 7. VÉRIFIER LA CRÉATION:
echo    ✅ Performance créée avec le nouvel artiste
echo    ✅ Données Spotify synchronisées (si utilisées)
echo    ✅ Performance visible dans la timeline/kanban
echo.
echo ================================================
echo RÉSULTAT ATTENDU
echo ================================================
echo.
echo Le bouton "+ Ajouter un artiste" ouvre maintenant le modal
echo complet AddArtistModal de la page artiste, permettant:
echo.
echo - Création d'artiste avec nom
echo - Recherche et synchronisation Spotify
echo - Enrichissement automatique des données
echo - Rechargement de la liste des artistes
echo - Intégration transparente dans le workflow
echo.
echo ================================================
echo TEST TERMINÉ
echo ================================================
echo.
pause

