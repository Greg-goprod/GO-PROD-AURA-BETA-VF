@echo off
echo Test de la correction de l'erreur de clé étrangère company_id...
echo.

echo ================================================
echo PROBLÈME IDENTIFIÉ
echo ================================================
echo.
echo ❌ Erreur: "Key (company_id)=(00000000-0000-0000-0000-000000000000) 
echo    is not present in table \"companies\""
echo.
echo 🔍 Cause: La compagnie par défaut n'existe pas dans la base
echo.
echo ================================================
echo SOLUTIONS IMPLÉMENTÉES
echo ================================================
echo.
echo 1. SCRIPT SQL: sql/create_default_company.sql
echo    - Crée la compagnie avec l'UUID utilisé dans l'app
echo    - À exécuter dans le SQL Editor de Supabase
echo.
echo 2. CODE AUTOMATIQUE: AddArtistModal.tsx
echo    - Vérifie l'existence de la compagnie
echo    - Crée automatiquement la compagnie si elle n'existe pas
echo    - Puis crée l'artiste
echo.
echo ================================================
echo TEST À EFFECTUER
echo ================================================
echo.

echo OPTION 1 - Script SQL (recommandé):
echo 1. Ouvrir le SQL Editor de Supabase
echo 2. Exécuter le contenu de sql/create_default_company.sql
echo 3. Vérifier que la compagnie est créée
echo.

echo OPTION 2 - Test automatique:
echo 1. Ouvrir http://localhost:5178/app/booking
echo 2. Cliquer sur "➕ Ajouter une performance"
echo 3. Cliquer sur "+ Ajouter un artiste"
echo 4. Saisir un nom d'artiste
echo 5. Cliquer sur "Enregistrer"
echo.
echo 6. Vérifier dans la console:
echo    ✅ "🏢 Vérification de la compagnie par défaut..."
echo    ✅ "🏢 Création de la compagnie par défaut..."
echo    ✅ "✅ Compagnie par défaut créée"
echo    ✅ "✅ Artiste inséré avec succès"
echo.
echo ================================================
echo RÉSULTAT ATTENDU
echo ================================================
echo.
echo L'artiste devrait maintenant être créé avec succès
echo et la compagnie par défaut sera créée automatiquement !
echo.
pause

