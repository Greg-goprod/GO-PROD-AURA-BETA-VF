@echo off
echo Verification finale du systeme Timeline Booking...
echo.

echo 1. Verification des composants AURA...
if exist "src\components\aura\Button.tsx" (
    echo ✅ Button.tsx
) else (
    echo ❌ Button.tsx manquant
)

if exist "src\components\aura\Card.tsx" (
    echo ✅ Card.tsx
) else (
    echo ❌ Card.tsx manquant
)

if exist "src\components\aura\Badge.tsx" (
    echo ✅ Badge.tsx
) else (
    echo ❌ Badge.tsx manquant
)

if exist "src\components\aura\Modal.tsx" (
    echo ✅ Modal.tsx
) else (
    echo ❌ Modal.tsx manquant
)

if exist "src\components\aura\Toast.tsx" (
    echo ✅ Toast.tsx
) else (
    echo ❌ Toast.tsx manquant
)

if exist "src\components\aura\EmptyState.tsx" (
    echo ✅ EmptyState.tsx
) else (
    echo ❌ EmptyState.tsx manquant
)

if exist "src\components\aura\Input.tsx" (
    echo ✅ Input.tsx
) else (
    echo ❌ Input.tsx manquant
)

echo.
echo 2. Verification des composants Timeline...
if exist "src\features\timeline\timelineApi.ts" (
    echo ✅ timelineApi.ts
) else (
    echo ❌ timelineApi.ts manquant
)

if exist "src\features\timeline\components\TimelineGrid.tsx" (
    echo ✅ TimelineGrid.tsx
) else (
    echo ❌ TimelineGrid.tsx manquant
)

if exist "src\features\timeline\components\PerformanceCard.tsx" (
    echo ✅ PerformanceCard.tsx
) else (
    echo ❌ PerformanceCard.tsx manquant
)

if exist "src\features\timeline\components\DailySummaryCards.tsx" (
    echo ✅ DailySummaryCards.tsx
) else (
    echo ❌ DailySummaryCards.tsx manquant
)

if exist "src\features\timeline\components\CustomTimePicker.tsx" (
    echo ✅ CustomTimePicker.tsx
) else (
    echo ❌ CustomTimePicker.tsx manquant
)

echo.
echo 3. Verification des fichiers utilitaires...
if exist "src\lib\utils.ts" (
    echo ✅ utils.ts
) else (
    echo ❌ utils.ts manquant
)

if exist "src\pages\LineupTimelinePage.tsx" (
    echo ✅ LineupTimelinePage.tsx
) else (
    echo ❌ LineupTimelinePage.tsx manquant
)

echo.
echo 4. Verification des dependances...
if exist "node_modules\@dnd-kit" (
    echo ✅ @dnd-kit installe
) else (
    echo ❌ @dnd-kit non installe
    echo Executez: npm install @dnd-kit/core @dnd-kit/modifiers @dnd-kit/sortable
)

echo.
echo 5. Verification des routes...
findstr /C:"lineup/timeline" src\App.tsx >nul
if %errorlevel%==0 (
    echo ✅ Route /app/lineup/timeline ajoutee
) else (
    echo ❌ Route /app/lineup/timeline manquante
)

findstr /C:"Ouvrir la timeline" src\pages\BookingPage.tsx >nul
if %errorlevel%==0 (
    echo ✅ Bouton Timeline dans BookingPage
) else (
    echo ❌ Bouton Timeline manquant dans BookingPage
)

echo.
echo ========================================
echo VERIFICATION FINALE TERMINEE
echo ========================================
echo.
echo Si tous les elements sont OK, le systeme Timeline Booking est pret!
echo.
echo URLs de test:
echo - Booking: http://localhost:5175/app/booking
echo - Timeline: http://localhost:5175/app/lineup/timeline
echo.
echo Fonctionnalites:
echo - Mode demo automatique si pas d'event_id
echo - Drag & drop avec snapping 5 minutes
echo - Modaux AURA pour creation/edition
echo - Resumé quotidien avec KPIs
echo - Synchronisation avec BookingPage
echo.
pause

