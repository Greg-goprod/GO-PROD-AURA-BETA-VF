@echo off
echo Script pour créer la compagnie par défaut dans Supabase...
echo.

echo ================================================
echo INSTRUCTIONS
echo ================================================
echo.

echo 1. Ouvrir le Dashboard Supabase:
echo    https://supabase.com/dashboard
echo.

echo 2. Sélectionner votre projet
echo.

echo 3. Aller dans "SQL Editor"
echo.

echo 4. Copier et coller ce SQL:
echo.
echo ================================================
echo SQL À EXÉCUTER
echo ================================================
echo.

echo -- Créer la compagnie par défaut avec l'UUID utilisé dans l'app
echo INSERT INTO companies (
echo   id,
echo   name,
echo   created_at,
echo   updated_at
echo ) VALUES (
echo   '00000000-0000-0000-0000-000000000000',
echo   'Compagnie par défaut',
echo   NOW(),
echo   NOW()
echo ) ON CONFLICT (id) DO NOTHING;
echo.
echo -- Vérifier que la compagnie a été créée
echo SELECT 
echo   id,
echo   name,
echo   created_at
echo FROM companies 
echo WHERE id = '00000000-0000-0000-0000-000000000000';
echo.

echo ================================================
echo 5. Cliquer sur "Run" pour exécuter le SQL
echo ================================================
echo.

echo 6. Vérifier que le résultat affiche:
echo    ✅ Une ligne avec l'UUID et "Compagnie par défaut"
echo.

echo 7. Tester maintenant l'ajout d'artiste dans l'app
echo.

echo ================================================
echo ALTERNATIVE AUTOMATIQUE
echo ================================================
echo.
echo Si vous préférez, l'app créera automatiquement
echo la compagnie lors du premier ajout d'artiste.
echo.
echo Testez directement l'ajout d'artiste dans l'app !
echo.
pause

