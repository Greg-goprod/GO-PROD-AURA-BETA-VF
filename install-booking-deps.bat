@echo off
echo Installation des dependances pour les modaux Booking...
echo.

echo Installation de @emailjs/browser...
npm install @emailjs/browser

echo.
echo Installation de pdf-lib...
npm install pdf-lib

echo.
echo Verification de l'installation...
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
echo Installation terminee.
echo Vous pouvez maintenant redemarrer le serveur avec: npm run dev
echo.
pause

