@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 设置ffmpeg路径（请根据实际路径修改）
set "FFMPEG_PATH=F:\yuyin\So-VITS-SVC新版\新版整合包\so-vits-svc\ffmpeg\bin\ffmpeg.exe"

:: 支持的视频文件扩展名
set "VIDEO_EXTS=.mp4 .avi .mov .mkv .flv .wmv .webm .m4v .3gp .mpg .mpeg"

cls
echo ====================================
echo   视频文件批量处理工具
echo ====================================
echo 步骤1：按顺序重命名视频文件
echo 步骤2：提取所有视频第一帧为JPG图片
echo ====================================
echo.
echo 警告：重命名操作不可逆！请确认已备份重要文件。
set /p "confirm=是否继续？(Y/N)："
if /i not "!confirm!"=="Y" (
    echo 操作已取消。
    pause
    exit /b
)

:: ========== 步骤1：按顺序重命名视频文件 ==========
echo.
echo ====================================
echo 步骤1：正在按顺序重命名视频文件...
echo ====================================

:: 收集所有视频文件并按创建时间排序
set "tempfile=%temp%\videolist.txt"
set "tempfilter=%temp%\videolist_filtered.txt"

dir /b /a-d /od *.* > "%tempfile%" 2>nul

:: 筛选视频文件并编号
set "count=0"
(for /f "delims=" %%i in ('type "%tempfile%"') do (
    for %%x in (%VIDEO_EXTS%) do (
        if /i "%%~xi"=="%%x" (
            set /a count+=1
            echo !count! %%i
        )
    )
)) > "%tempfilter%"

if !count! equ 0 (
    echo 当前目录下没有找到视频文件！
    del "%tempfile%" "%tempfilter%" 2>nul
    pause
    exit /b
)

echo 找到 !count! 个视频文件，将按创建时间顺序重命名为：
echo 1.mp4, 2.mp4, ... , !count!.mp4
echo.

:: 执行重命名
set "num=1"
set "rename_success=0"
set "rename_failed=0"

for /f "tokens=1,*" %%a in ('type "%tempfilter%"') do (
    set "oldname=%%b"
    set "newname=!num!.mp4"
    if not "!oldname!"=="!newname!" (
        echo 正在重命名："!oldname!" → "!newname!"
        ren "!oldname!" "!newname!" 2>nul
        if errorlevel 1 (
            echo 错误：无法重命名 "!oldname!"，可能文件正在使用中或权限不足。
            set /a rename_failed+=1
        ) else (
            set /a rename_success+=1
        )
    ) else (
        echo 跳过："!oldname!" 已经是目标名称。
        set /a rename_success+=1
    )
    set /a num+=1
)

:: 清理临时文件
del "%tempfile%" "%tempfilter%" 2>nul

echo.
echo 重命名完成！成功：!rename_success! 个，失败：!rename_failed! 个
echo.

:: ========== 步骤2：提取所有视频第一帧 ==========
echo ====================================
echo 步骤2：正在提取视频第一帧...
echo ====================================

set "frame_count=0"
set "frame_success=0"
set "frame_failed=0"

:: 扫描重命名后的视频文件（主要是.mp4格式，但也支持其他格式）
for %%x in (%VIDEO_EXTS%) do (
    for %%i in ("*%%x") do (
        if exist "%%i" (
            set /a frame_count+=1
            echo 正在处理 [%%i] ...
            "%FFMPEG_PATH%" -y -i "%%i" -frames:v 1 -q:v 2 "%%~ni.jpg" 2>nul
            if errorlevel 1 (
                echo 错误：提取失败 - %%i
                set /a frame_failed+=1
            ) else (
                set /a frame_success+=1
            )
        )
    )
)

echo.
echo ====================================
echo 全部处理完成！
echo ====================================
echo 【重命名统计】
echo   成功：!rename_success! 个
echo   失败：!rename_failed! 个
echo.
echo 【提取帧统计】
echo   处理视频：!frame_count! 个
echo   成功提取：!frame_success! 个
echo   提取失败：!frame_failed! 个
echo ====================================

pause