@echo off
echo Nettoyage du cache Vite pour résoudre les problèmes d'import...
echo.

echo ================================================
echo NETTOYAGE DU CACHE
echo ================================================
echo.

echo 1. Arrêt des processus Node.js...
taskkill /f /im node.exe 2>nul
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

echo ================================================
echo REDÉMARRAGE
echo ================================================
echo.

echo 4. Redémarrage du serveur...
echo.
echo Le serveur va démarrer sur http://localhost:5178
echo.
npm run dev
