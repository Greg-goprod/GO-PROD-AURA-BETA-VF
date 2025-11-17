@echo off
echo Redémarrage propre du serveur de développement...
echo.

echo 1. Arrêt des processus Node.js...
taskkill /f /im node.exe 2>nul
echo.

echo 2. Nettoyage du cache Vite...
if exist "node_modules\.vite" (
    rmdir /s /q "node_modules\.vite"
    echo Cache Vite nettoyé
) else (
    echo Pas de cache Vite à nettoyer
)
echo.

echo 3. Redémarrage du serveur...
echo.
echo Le serveur va démarrer sur http://localhost:5177
echo.
npm run dev