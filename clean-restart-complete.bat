@echo off
echo Nettoyage complet du cache Vite et redémarrage...
echo.

echo ================================================
echo NETTOYAGE COMPLET
echo ================================================
echo.

echo 1. Arrêt des processus Node.js...
taskkill /f /im node.exe 2>nul
if %errorlevel% equ 0 (
    echo ✅ Processus Node.js arrêtés
) else (
    echo ℹ️ Aucun processus Node.js en cours
)
echo.

echo 2. Suppression du cache Vite...
if exist "node_modules\.vite" (
    rmdir /s /q "node_modules\.vite"
    echo ✅ Cache Vite supprimé
) else (
    echo ℹ️ Pas de cache Vite à supprimer
)
echo.

echo 3. Suppression du cache TypeScript...
if exist ".tsbuildinfo" (
    del ".tsbuildinfo"
    echo ✅ Cache TypeScript supprimé
) else (
    echo ℹ️ Pas de cache TypeScript à supprimer
)
echo.

echo 4. Suppression du cache npm...
if exist "node_modules\.cache" (
    rmdir /s /q "node_modules\.cache"
    echo ✅ Cache npm supprimé
) else (
    echo ℹ️ Pas de cache npm à supprimer
)
echo.

echo ================================================
echo VÉRIFICATION DES DÉPENDANCES
echo ================================================
echo.

echo 5. Vérification de Zustand...
if exist "node_modules\zustand" (
    echo ✅ Zustand présent
) else (
    echo ❌ Zustand manquant
    pause
    exit /b 1
)

echo.
echo 6. Vérification de react-hook-form...
if exist "node_modules\react-hook-form" (
    echo ✅ react-hook-form présent
) else (
    echo ❌ react-hook-form manquant
    pause
    exit /b 1
)

echo.
echo ================================================
echo REDÉMARRAGE DU SERVEUR
echo ================================================
echo.

echo 7. Redémarrage du serveur de développement...
echo.
echo Le serveur va démarrer sur http://localhost:5179
echo.
echo ✅ Nettoyage terminé - Redémarrage en cours...
echo.

npm run dev

