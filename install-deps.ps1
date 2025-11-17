Write-Host "Installation des dépendances pour Booking PDF + Email..." -ForegroundColor Green
npm install pdf-lib emailjs-com
Write-Host ""
Write-Host "Installation terminée!" -ForegroundColor Green
Write-Host ""
Write-Host "N'oubliez pas de configurer EmailJS:" -ForegroundColor Yellow
Write-Host "1. Créez un fichier .env.local avec vos clés EmailJS" -ForegroundColor Yellow
Write-Host "2. Suivez les instructions dans EMAILJS_SETUP.md" -ForegroundColor Yellow
Write-Host ""
Read-Host "Appuyez sur Entrée pour continuer"

