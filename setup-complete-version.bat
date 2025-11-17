@echo off
echo Configuration de la version complete Timeline Booking...
echo.

echo 1. Nettoyage du cache Vite...
if exist "node_modules\.vite" (
    rmdir /s /q "node_modules\.vite"
    echo ✅ Cache Vite supprime
) else (
    echo ℹ️ Cache Vite deja absent
)

echo.
echo 2. Verification des imports @dnd-kit...
findstr /C:"@dnd-kit/core" src\features\timeline\components\TimelineGrid.tsx >nul
if %errorlevel%==0 (
    echo ✅ Imports @dnd-kit presents
) else (
    echo ❌ Imports @dnd-kit manquants
)

echo.
echo 3. Verification des types DnD...
findstr /C:"interface DragStartEvent" src\features\timeline\components\TimelineGrid.tsx >nul
if %errorlevel%==0 (
    echo ✅ Types DnD definis
) else (
    echo ❌ Types DnD manquants
)

echo.
echo 4. Verification des dependances...
if exist "node_modules\@dnd-kit\core" (
    echo ✅ @dnd-kit/core installe
) else (
    echo ❌ @dnd-kit/core non installe
)

if exist "node_modules\@dnd-kit\modifiers" (
    echo ✅ @dnd-kit/modifiers installe
) else (
    echo ❌ @dnd-kit/modifiers non installe
)

if exist "node_modules\@dnd-kit\sortable" (
    echo ✅ @dnd-kit/sortable installe
) else (
    echo ❌ @dnd-kit/sortable non installe
)

echo.
echo 5. Redemarrage du serveur...
echo Arretez le serveur actuel (Ctrl+C) puis appuyez sur une touche...
pause

echo.
echo Demarrage du serveur de developpement...
npm run dev

echo.
echo ========================================
echo CONFIGURATION TERMINEE
echo ========================================
echo.
echo La version complete avec drag & drop est maintenant active.
echo.
echo Fonctionnalites disponibles:
echo ✅ Timeline visuelle avec grille jours x scenes
echo ✅ Drag & drop des performances avec snapping 5 minutes
echo ✅ Modaux AURA pour creation/edition/suppression
echo ✅ Resumé quotidien avec KPIs
echo ✅ Sélecteur temps plein écran
echo ✅ Mode demo automatique si pas d'event_id
echo.
echo URLs de test:
echo - Booking: http://localhost:5176/app/booking
echo - Timeline: http://localhost:5176/app/lineup/timeline
echo.
echo Si vous voyez encore des erreurs, consultez la console du navigateur (F12).
echo.
pause

