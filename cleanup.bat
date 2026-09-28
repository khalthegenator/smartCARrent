@echo off
echo Cleaning build artifacts and IDE files...
if exist build (
  rd /s /q build
  echo Removed build/ directory
)
if exist smart_car_rent.iml (
  del /f /q smart_car_rent.iml
  echo Removed smart_car_rent.iml
)
for %%f in (*.iml) do (
  if exist "%%f" del /f /q "%%f"
)
echo Cleanup complete.
pause