@echo off
echo Test du systeme Timeline Booking...
echo.

echo Verification des composants AURA...
if not exist "src\components\aura\Card.tsx" (
    echo ERREUR: Card.tsx manquant
    pause
    exit /b 1
)
if not exist "src\components\aura\Button.tsx" (
    echo ERREUR: Button.tsx manquant
    pause
    exit /b 1
)
if not exist "src\components\aura\Badge.tsx" (
    echo ERREUR: Badge.tsx manquant
    pause
    exit /b 1
)
if not exist "src\components\aura\Modal.tsx" (
    echo ERREUR: Modal.tsx manquant
    pause
    exit /b 1
)
if not exist "src\components\aura\Toast.tsx" (
    echo ERREUR: Toast.tsx manquant
    pause
    exit /b 1
)
if not exist "src\components\aura\EmptyState.tsx" (
    echo ERREUR: EmptyState.tsx manquant
    pause
    exit /b 1
)
if not exist "src\components\aura\Input.tsx" (
    echo ERREUR: Input.tsx manquant
    pause
    exit /b 1
)

echo Composants AURA OK!
echo.

echo Verification des composants Timeline...
if not exist "src\features\timeline\timelineApi.ts" (
    echo ERREUR: timelineApi.ts manquant
    pause
    exit /b 1
)
if not exist "src\features\timeline\components\TimelineGrid.tsx" (
    echo ERREUR: TimelineGrid.tsx manquant
    pause
    exit /b 1
)
if not exist "src\features\timeline\components\PerformanceCard.tsx" (
    echo ERREUR: PerformanceCard.tsx manquant
    pause
    exit /b 1
)
if not exist "src\features\timeline\components\DailySummaryCards.tsx" (
    echo ERREUR: DailySummaryCards.tsx manquant
    pause
    exit /b 1
)
if not exist "src\features\timeline\components\CustomTimePicker.tsx" (
    echo ERREUR: CustomTimePicker.tsx manquant
    pause
    exit /b 1
)

echo Composants Timeline OK!
echo.

echo Verification de la page principale...
if not exist "src\pages\LineupTimelinePage.tsx" (
    echo ERREUR: LineupTimelinePage.tsx manquant
    pause
    exit /b 1
)

echo Page principale OK!
echo.

echo Verification des dependances...
if not exist "node_modules\@dnd-kit" (
    echo ATTENTION: @dnd-kit non installe
    echo Executez: npm install @dnd-kit/core @dnd-kit/modifiers @dnd-kit/sortable
    echo.
)

echo.
echo ========================================
echo SYSTEME TIMELINE BOOKING PRET!
echo ========================================
echo.
echo URLs de test:
echo - Booking: http://localhost:5174/app/booking
echo - Timeline: http://localhost:5174/app/lineup/timeline
echo.
echo Fonctionnalites:
echo - Mode demo automatique si pas d'event_id
echo - Drag & drop avec snapping 5 minutes
echo - Modaux AURA pour creation/edition
echo - Resumé quotidien avec KPIs
echo - Synchronisation avec BookingPage
echo.
pause

