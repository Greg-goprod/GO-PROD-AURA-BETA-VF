@echo off
echo Test des Modaux Booking - Verification Complete
echo ================================================
echo.

echo 1. Verification des fichiers crees...
echo.

if exist "src\features\booking\modals\PerformanceModal.tsx" (
    echo ✅ PerformanceModal.tsx
) else (
    echo ❌ PerformanceModal.tsx MANQUANT
)

if exist "src\features\booking\modals\OfferComposer.tsx" (
    echo ✅ OfferComposer.tsx
) else (
    echo ❌ OfferComposer.tsx MANQUANT
)

if exist "src\features\booking\modals\SendOfferModal.tsx" (
    echo ✅ SendOfferModal.tsx
) else (
    echo ❌ SendOfferModal.tsx MANQUANT
)

if exist "src\features\booking\modals\RejectOfferModal.tsx" (
    echo ✅ RejectOfferModal.tsx
) else (
    echo ❌ RejectOfferModal.tsx MANQUANT
)

if exist "src\services\emailService.ts" (
    echo ✅ emailService.ts
) else (
    echo ❌ emailService.ts MANQUANT
)

if exist "src\services\date.ts" (
    echo ✅ date.ts
) else (
    echo ❌ date.ts MANQUANT
)

echo.
echo 2. Verification des imports dans les pages...
echo.

findstr /C:"PerformanceModal" src\pages\BookingPage.tsx >nul
if %errorlevel%==0 (
    echo ✅ PerformanceModal importe dans BookingPage
) else (
    echo ❌ PerformanceModal NON importe dans BookingPage
)

findstr /C:"OfferComposer" src\pages\BookingPage.tsx >nul
if %errorlevel%==0 (
    echo ✅ OfferComposer importe dans BookingPage
) else (
    echo ❌ OfferComposer NON importe dans BookingPage
)

findstr /C:"SendOfferModal" src\pages\BookingPage.tsx >nul
if %errorlevel%==0 (
    echo ✅ SendOfferModal importe dans BookingPage
) else (
    echo ❌ SendOfferModal NON importe dans BookingPage
)

findstr /C:"RejectOfferModal" src\pages\BookingPage.tsx >nul
if %errorlevel%==0 (
    echo ✅ RejectOfferModal importe dans BookingPage
) else (
    echo ❌ RejectOfferModal NON importe dans BookingPage
)

findstr /C:"PerformanceModal" src\pages\LineupTimelinePage.tsx >nul
if %errorlevel%==0 (
    echo ✅ PerformanceModal importe dans LineupTimelinePage
) else (
    echo ❌ PerformanceModal NON importe dans LineupTimelinePage
)

echo.
echo 3. Verification des fonctions API...
echo.

findstr /C:"createOffer" src\features\booking\bookingApi.ts >nul
if %errorlevel%==0 (
    echo ✅ createOffer dans bookingApi.ts
) else (
    echo ❌ createOffer MANQUANT dans bookingApi.ts
)

findstr /C:"updateOffer" src\features\booking\bookingApi.ts >nul
if %errorlevel%==0 (
    echo ✅ updateOffer dans bookingApi.ts
) else (
    echo ❌ updateOffer MANQUANT dans bookingApi.ts
)

findstr /C:"createOfferVersion" src\features\booking\bookingApi.ts >nul
if %errorlevel%==0 (
    echo ✅ createOfferVersion dans bookingApi.ts
) else (
    echo ❌ createOfferVersion MANQUANT dans bookingApi.ts
)

echo.
echo 4. Verification des types...
echo.

findstr /C:"PerformanceCreate" src\features\booking\bookingTypes.ts >nul
if %errorlevel%==0 (
    echo ✅ PerformanceCreate dans bookingTypes.ts
) else (
    echo ❌ PerformanceCreate MANQUANT dans bookingTypes.ts
)

findstr /C:"PerformanceUpdate" src\features\booking\bookingTypes.ts >nul
if %errorlevel%==0 (
    echo ✅ PerformanceUpdate dans bookingTypes.ts
) else (
    echo ❌ PerformanceUpdate MANQUANT dans bookingTypes.ts
)

findstr /C:"OfferCreate" src\features\booking\bookingTypes.ts >nul
if %errorlevel%==0 (
    echo ✅ OfferCreate dans bookingTypes.ts
) else (
    echo ❌ OfferCreate MANQUANT dans bookingTypes.ts
)

findstr /C:"OfferUpdate" src\features\booking\bookingTypes.ts >nul
if %errorlevel%==0 (
    echo ✅ OfferUpdate dans bookingTypes.ts
) else (
    echo ❌ OfferUpdate MANQUANT dans bookingTypes.ts
)

echo.
echo 5. Verification des boutons dans BookingPage...
echo.

findstr /C:"Ajouter une performance" src\pages\BookingPage.tsx >nul
if %errorlevel%==0 (
    echo ✅ Bouton "Ajouter une performance" dans BookingPage
) else (
    echo ❌ Bouton "Ajouter une performance" MANQUANT dans BookingPage
)

echo.
echo 6. Verification des dependances...
echo.

if exist "node_modules\@emailjs\browser" (
    echo ✅ @emailjs/browser installe
) else (
    echo ❌ @emailjs/browser NON installe
)

if exist "node_modules\pdf-lib" (
    echo ✅ pdf-lib installe
) else (
    echo ❌ pdf-lib NON installe
)

echo.
echo ================================================
echo VERIFICATION TERMINEE
echo ================================================
echo.
echo Prochaines etapes:
echo 1. Demarrer le serveur: npm run dev
echo 2. Tester BookingPage: http://localhost:5176/app/booking
echo 3. Tester Timeline: http://localhost:5176/app/lineup/timeline
echo 4. Suivre le guide: TEST_MODAUX_BOOKING.md
echo.
echo Si des erreurs apparaissent, consulter la console du navigateur (F12).
echo.
pause

