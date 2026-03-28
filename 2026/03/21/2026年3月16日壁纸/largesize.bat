@echo off
setlocal enabledelayedexpansion

:: ffmpeg路径
set "FFMPEG_PATH=F:\yuyin\So-VITS-SVC新版\新版整合包\so-vits-svc\ffmpeg\bin\ffmpeg.exe"

:: 文件大小阈值：100 MB = 104857600 字节
set "SIZE_LIMIT=104857600"

cls
echo ========================================
echo   自动提取大于 100MB 视频的前10秒
echo ========================================
echo.

if not exist "%FFMPEG_PATH%" (
    echo [错误] 未找到 ffmpeg: %FFMPEG_PATH%
    pause
    exit /b
)

set "total_found=0"
set "total_processed=0"
set "total_success=0"
set "total_failed=0"
set "total_skipped=0"

echo 正在扫描视频文件...
echo.

:: 遍历所有视频文件（可根据需要修改扩展名列表）
for %%i in (*.mp4 *.avi *.mov *.mkv *.flv *.wmv *.webm *.m4v *.3gp *.mpg *.mpeg) do (
    if exist "%%i" (
        set /a total_found+=1
        set "size=%%~zi"
        echo [文件] %%i
        echo   大小: !size! 字节
        
        if !size! GEQ %SIZE_LIMIT% (
            echo   条件: 文件大小 >= 100MB，开始处理...
            set "outname=%%~ni_10s%%~xi"
            
            :: 尝试快速复制模式
            "%FFMPEG_PATH%" -i "%%i" -t 10 -c copy "!outname!" >nul 2>&1
            if errorlevel 1 (
                echo   快速复制失败，尝试重新编码...
                "%FFMPEG_PATH%" -i "%%i" -t 10 -c:v libx264 -c:a aac "!outname!" >nul 2>&1
                if errorlevel 1 (
                    echo   [失败] 提取失败
                    set /a total_failed+=1
                ) else (
                    echo   [成功] 已生成: !outname!
                    set /a total_success+=1
                )
            ) else (
                echo   [成功] 已生成: !outname!
                set /a total_success+=1
            )
            set /a total_processed+=1
        ) else (
            echo   条件: 文件小于100MB，跳过
            set /a total_skipped+=1
        )
        echo.
    )
)

echo ========================================
echo 处理完成！
echo 扫描到的视频文件总数: %total_found%
echo 符合条件的文件数（>=100MB）: %total_processed%
echo   成功提取: %total_success%
echo   提取失败: %total_failed%
echo 跳过的小文件（<100MB）: %total_skipped%
echo ========================================
pause