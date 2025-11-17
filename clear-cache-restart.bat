@echo off
echo Nettoyage du cache Vite et redémarrage...
echo.

echo ================================================
echo PROBLÈME IDENTIFIÉ
echo ================================================
echo.

echo ❌ Vite utilise encore l'ancien cache
echo    - Les dépendances sont installées (zustand, react-hook-form)
echo    - Mais Vite n'a pas encore détecté les nouveaux modules
echo    - Il faut nettoyer le cache et redémarrer
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
echo VÉRIFICATION DES DÉPENDANCES
echo ================================================
echo.

echo 4. Vérification de Zustand...
if exist "node_modules\zustand" (
    echo ✅ Zustand installé
) else (
    echo ❌ Zustand manquant - réinstaller avec: npm install zustand
)

echo.
echo 5. Vérification de react-hook-form...
if exist "node_modules\react-hook-form" (
    echo ✅ react-hook-form installé
) else (
    echo ❌ react-hook-form manquant - réinstaller avec: npm install react-hook-form
)

echo.
echo ================================================
echo REDÉMARRAGE
echo ================================================
echo.

echo 6. Redémarrage du serveur...
echo.
echo Le serveur va démarrer sur http://localhost:5179
echo.
npm run dev

