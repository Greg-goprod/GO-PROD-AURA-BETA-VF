@echo off
echo Migration vers les versions completes apres installation des dependances...
echo.

echo Verification des dependances...
if not exist "node_modules\pdf-lib" (
    echo ERREUR: pdf-lib non installe
    echo Executez: npm install pdf-lib emailjs-com
    pause
    exit /b 1
)

if not exist "node_modules\emailjs-com" (
    echo ERREUR: emailjs-com non installe
    echo Executez: npm install pdf-lib emailjs-com
    pause
    exit /b 1
)

echo Dependances OK!
echo.

echo Remplacement des versions temporaires...

REM Sauvegarder les versions temporaires
copy "src\features\booking\pdf\pdfFill.ts" "src\features\booking\pdf\pdfFill_TEMP_BACKUP.ts" >nul
copy "src\services\emailService.ts" "src\services\emailService_TEMP_BACKUP.ts" >nul

REM Remplacer par les versions completes
copy "src\features\booking\pdf\pdfFill_COMPLETE.ts" "src\features\booking\pdf\pdfFill.ts" >nul
copy "src\services\emailService_COMPLETE.ts" "src\services\emailService.ts" >nul

echo Migration terminee!
echo.
echo Les fichiers ont ete remplaces par les versions completes.
echo Les versions temporaires sont sauvegardees avec _TEMP_BACKUP.
echo.
echo Redemarrez maintenant le serveur de developpement:
echo npm run dev
echo.
pause

