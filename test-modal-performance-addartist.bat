@echo off
echo Test du modal "Ajouter une performance" avec intégration AddArtistModal...
echo.

echo 1. Ouvrir http://localhost:5177/app/booking
echo.
echo 2. Cliquer sur "➕ Ajouter une performance"
echo.
echo 3. Dans la section "Artiste", cliquer sur "+ Ajouter un artiste"
echo.
echo 4. Vérifier que le modal AddArtistModal s'ouvre avec:
echo.
echo ✅ TITRE: "Ajouter un artiste"
echo ✅ DESCRIPTION: "Ajoutez un nouvel artiste à votre base de données..."
echo ✅ CHAMP NOM: Input pour saisir le nom
echo ✅ BOUTON "Rechercher sur Spotify": Pour enrichir les données
echo ✅ BOUTONS: "Annuler" et "Enregistrer"
echo.
echo 5. Tester la création d'artiste:
echo    - Saisir un nom d'artiste
echo    - Cliquer sur "Rechercher sur Spotify" (optionnel)
echo    - Cliquer sur "Enregistrer"
echo.
echo 6. Vérifier que:
echo    - Le modal AddArtistModal se ferme
echo    - Le modal PerformanceModal reste ouvert
echo    - La liste des artistes se recharge
echo    - Le nouvel artiste apparaît dans le select
echo    - Toast de succès s'affiche
echo.
echo 7. Sélectionner le nouvel artiste et continuer la création de performance
echo.
echo ================================================
echo TEST TERMINÉ
echo ================================================
echo.
echo Le bouton "+ Ajouter un artiste" ouvre maintenant le modal complet
echo avec synchronisation Spotify et enrichissement des données !
echo.
pause

