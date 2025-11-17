@echo off
echo Installation des dependances pour Timeline Booking...
echo.

echo Installation @dnd-kit...
npm install @dnd-kit/core @dnd-kit/modifiers @dnd-kit/sortable

echo.
echo Installation terminee!
echo.
echo Le systeme Timeline Booking est maintenant pret:
echo - Route: /app/lineup/timeline
echo - Bouton dans BookingPage: "Ouvrir la timeline"
echo - Mode demo automatique si pas d'event_id
echo - Drag & drop avec snapping 5 minutes
echo - Modaux AURA pour creation/edition
echo.
pause

