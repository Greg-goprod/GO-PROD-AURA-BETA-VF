@echo off
cd /d D:\NEW-GO-PROD\go-prod-aura
echo === Basculement sur la branche main ===
git checkout main
echo.
echo === Branche actuelle ===
git branch --show-current
echo.
echo === Lancement du serveur de developpement ===
npm run dev


