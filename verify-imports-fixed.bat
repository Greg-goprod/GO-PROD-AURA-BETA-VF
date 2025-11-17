@echo off
echo Verification des imports des modaux Booking...
echo.

echo 1. Verification des fichiers existants...
if exist "src\features\booking\pdf\pdfFill.ts" (
    echo ✅ pdfFill.ts existe
) else (
    echo ❌ pdfFill.ts MANQUANT
)

if exist "src\services\emailService.ts" (
    echo ✅ emailService.ts existe
) else (
    echo ❌ emailService.ts MANQUANT
)

if exist "src\services\date.ts" (
    echo ✅ date.ts existe
) else (
    echo ❌ date.ts MANQUANT
)

echo.
echo 2. Verification des fonctions dans pdfFill.ts...
findstr /C:"generateOfferPdfAndUpload" src\features\booking\pdf\pdfFill.ts >nul
if %errorlevel%==0 (
    echo ✅ generateOfferPdfAndUpload dans pdfFill.ts
) else (
    echo ❌ generateOfferPdfAndUpload MANQUANT dans pdfFill.ts
)

echo.
echo 3. Verification des fonctions dans emailService.ts...
findstr /C:"sendOfferEmail" src\services\emailService.ts >nul
if %errorlevel%==0 (
    echo ✅ sendOfferEmail dans emailService.ts
) else (
    echo ❌ sendOfferEmail MANQUANT dans emailService.ts
)

echo.
echo 4. Verification des fonctions dans date.ts...
findstr /C:"formatIsoDate" src\services\date.ts >nul
if %errorlevel%==0 (
    echo ✅ formatIsoDate dans date.ts
) else (
    echo ❌ formatIsoDate MANQUANT dans date.ts
)

findstr /C:"normalizeName" src\services\date.ts >nul
if %errorlevel%==0 (
    echo ✅ normalizeName dans date.ts
) else (
    echo ❌ normalizeName MANQUANT dans date.ts
)

findstr /C:"toHHMM" src\services\date.ts >nul
if %errorlevel%==0 (
    echo ✅ toHHMM dans date.ts
) else (
    echo ❌ toHHMM MANQUANT dans date.ts
)

echo.
echo 5. Verification des imports dans les modaux...
findstr /C:"from \"../pdf/pdfFill\"" src\features\booking\modals\OfferComposer.tsx >nul
if %errorlevel%==0 (
    echo ✅ Import pdfFill correct dans OfferComposer
) else (
    echo ❌ Import pdfFill INCORRECT dans OfferComposer
)

findstr /C:"from \"../../../services/emailService\"" src\features\booking\modals\SendOfferModal.tsx >nul
if %errorlevel%==0 (
    echo ✅ Import emailService correct dans SendOfferModal
) else (
    echo ❌ Import emailService INCORRECT dans SendOfferModal
)

echo.
echo ================================================
echo VERIFICATION TERMINEE
echo ================================================
echo.
echo Le serveur devrait maintenant fonctionner sans erreurs d'import.
echo Testez sur: http://localhost:5177/app/booking
echo.
pause

