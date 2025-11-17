@echo off
echo Diagnostic de la page blanche Timeline Booking...
echo.

echo 1. Verification des erreurs de compilation...
echo Ouvrez la console du navigateur (F12) et regardez les erreurs.
echo.

echo 2. Verification des fichiers critiques...
if exist "src\pages\LineupTimelinePage.tsx" (
    echo ✅ LineupTimelinePage.tsx existe
) else (
    echo ❌ LineupTimelinePage.tsx manquant
)

if exist "src\features\timeline\timelineApi.ts" (
    echo ✅ timelineApi.ts existe
) else (
    echo ❌ timelineApi.ts manquant
)

if exist "src\lib\supabaseClient.ts" (
    echo ✅ supabaseClient.ts existe
) else (
    echo ❌ supabaseClient.ts manquant
)

echo.
echo 3. Verification des imports dans LineupTimelinePage.tsx...
findstr /C:"import.*Card" src\pages\LineupTimelinePage.tsx
findstr /C:"import.*Button" src\pages\LineupTimelinePage.tsx
findstr /C:"import.*TimelineGrid" src\pages\LineupTimelinePage.tsx

echo.
echo 4. Verification des composants AURA...
if exist "src\components\aura\Card.tsx" (
    echo ✅ Card.tsx existe
) else (
    echo ❌ Card.tsx manquant
)

if exist "src\components\aura\Button.tsx" (
    echo ✅ Button.tsx existe
) else (
    echo ❌ Button.tsx manquant
)

if exist "src\components\aura\EmptyState.tsx" (
    echo ✅ EmptyState.tsx existe
) else (
    echo ❌ EmptyState.tsx manquant
)

echo.
echo 5. Verification des composants Timeline...
if exist "src\features\timeline\components\TimelineGrid.tsx" (
    echo ✅ TimelineGrid.tsx existe
) else (
    echo ❌ TimelineGrid.tsx manquant
)

if exist "src\features\timeline\components\PerformanceCard.tsx" (
    echo ✅ PerformanceCard.tsx existe
) else (
    echo ❌ PerformanceCard.tsx manquant
)

echo.
echo 6. Verification des dependances...
if exist "node_modules\@dnd-kit" (
    echo ✅ @dnd-kit installe
) else (
    echo ❌ @dnd-kit non installe
)

echo.
echo 7. Verification de la route...
findstr /C:"lineup/timeline" src\App.tsx
if %errorlevel%==0 (
    echo ✅ Route ajoutee dans App.tsx
) else (
    echo ❌ Route manquante dans App.tsx
)

echo.
echo ========================================
echo DIAGNOSTIC TERMINE
echo ========================================
echo.
echo Actions recommandees:
echo 1. Ouvrir la console du navigateur (F12)
echo 2. Recharger la page
echo 3. Noter les erreurs JavaScript
echo 4. Verifier que tous les fichiers existent
echo 5. Tester en mode demo d'abord
echo.
echo URLs de test:
echo - http://localhost:5175/app/booking
echo - http://localhost:5175/app/lineup/timeline
echo.
pause

