@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo 正在提取视频第一帧...

rem 支持的文件扩展名（可自行增删）
for %%i in (*.mp4 *.avi *.mov *.mkv *.flv *.wmv *.webm *.m4v *.3gp *.mpg *.mpeg) do (
    if exist "%%i" (
        echo 处理: %%i
        F:\yuyin\So-VITS-SVC新版\新版整合包\so-vits-svc\ffmpeg\bin\ffmpeg.exe -y -i "%%i" -frames:v 1 -q:v 2 "%%~ni.jpg"
    )
)

echo 处理完成！
pause