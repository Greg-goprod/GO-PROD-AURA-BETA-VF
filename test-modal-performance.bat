@echo off
echo Test du modal "Ajouter une performance"...
echo.

echo 1. Ouvrir http://localhost:5177/app/booking
echo.
echo 2. Cliquer sur "➕ Ajouter une performance"
echo.
echo 3. Vérifier les éléments suivants:
echo.
echo ✅ TITRE: "Ajouter une performance"
echo ✅ ARTISTE: 
echo    - Placeholder: "Aucun artiste (optionnel)"
echo    - Bouton: "+ Ajouter un artiste"
echo.
echo ✅ JOUR: 
echo    - Placeholder: "Sélectionner un jour"
echo    - Astérisque rouge (*) pour obligatoire
echo.
echo ✅ SCÈNE: 
echo    - Placeholder: "Sélectionner une scène"
echo    - Astérisque rouge (*) pour obligatoire
echo.
echo ✅ HEURE DE DÉBUT: 
echo    - Placeholder: "00:00"
echo    - Bouton horloge (Clock icon)
echo    - Astérisque rouge (*) pour obligatoire
echo.
echo ✅ DURÉE (min):
echo    - Radio "Durée standard" (sélectionné par défaut)
echo    - Boutons: "60 min", "75 min", "90 min" (60 min sélectionné)
echo    - Radio "Durée personnalisée"
echo    - Astérisque rouge (*) pour obligatoire
echo.
echo ✅ DEVISE:
echo    - Dropdown avec "EUR" sélectionné par défaut
echo    - Options: EUR, CHF, USD
echo.
echo ✅ MONTANT:
echo    - Placeholder: "0.00"
echo    - Type: number avec step 0.01
echo.
echo ✅ STATUT (booking):
echo    - Dropdown avec "Idée" sélectionné par défaut
echo    - Options: Idée, Offre à faire, Offre rejetée
echo.
echo ✅ BOUTONS:
echo    - "Annuler" (variant="ghost")
echo    - "Enregistrer" (variant="primary")
echo.
echo ================================================
echo TEST TERMINÉ
echo ================================================
echo.
echo Si tous les éléments sont présents et corrects, le modal est conforme !
echo.
pause

