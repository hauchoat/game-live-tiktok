@echo off
title Cats and Gold - TikTok LIVE Mode
cd /d "%~dp0"

if not exist "node_modules" (
  echo Installing dependencies...
  call npm install
  if errorlevel 1 exit /b 1
)

echo Starting Cats and Gold in LIVE-ready mode...
start "" cmd /c "timeout /t 3 /nobreak >nul && start http://localhost:5173/control"
call npm run dev
