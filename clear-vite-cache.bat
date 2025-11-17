@echo off
echo Nettoyage du cache Vite et redemarrage...
echo.

echo Arret du serveur de developpement...
echo Appuyez sur Ctrl+C pour arreter le serveur actuel
echo Puis appuyez sur une touche pour continuer...
pause

echo.
echo Nettoyage du cache Vite...
if exist "node_modules\.vite" (
    rmdir /s /q "node_modules\.vite"
    echo ✅ Cache Vite supprime
) else (
    echo ℹ️ Cache Vite deja absent
)

echo.
echo Nettoyage du cache npm...
if exist "node_modules\.cache" (
    rmdir /s /q "node_modules\.cache"
    echo ✅ Cache npm supprime
) else (
    echo ℹ️ Cache npm deja absent
)

echo.
echo Redemarrage du serveur de developpement...
npm run dev

echo.
echo ========================================
echo NETTOYAGE TERMINE
echo ========================================
echo.
echo Le serveur devrait maintenant fonctionner sans erreurs de cache.
echo Testez l'URL: http://localhost:5176/app/lineup/timeline
echo.
pause

