<#
.SYNOPSIS
    将当前目录下的视频文件按名称排序，重命名为 1,2,3...（保留原扩展名）
.DESCRIPTION
    支持常见视频格式，自动跳过已存在的目标文件名，避免覆盖。
    运行前会显示文件列表并要求确认。
#>

# 定义支持的视频扩展名（可根据需要增减）
$videoExtensions = @(
    '.mp4', '.avi', '.mov', '.mkv', '.wmv',
    '.flv', '.m4v', '.webm', '.mpg', '.mpeg',
    '.3gp', '.ogv', '.ts', '.m2ts'
)

# 获取当前目录
$targetDir = Get-Location

# 收集所有视频文件，按名称排序
$videoFiles = Get-ChildItem -Path $targetDir -File | Where-Object {
    $_.Extension -in $videoExtensions
} | Sort-Object Name

# 检查是否有视频文件
if ($videoFiles.Count -eq 0) {
    Write-Host "当前目录未找到任何视频文件。" -ForegroundColor Yellow
    pause
    exit
}

# 显示将要重命名的文件
Write-Host "找到以下视频文件（按名称排序）：`n"
$counter = 0
foreach ($file in $videoFiles) {
    $counter++
    Write-Host "$counter. $($file.Name)"
}

Write-Host "`n重命名后文件将变为 1.扩展名, 2.扩展名 ..."
$confirm = Read-Host "`n是否继续？(Y/N)"
if ($confirm -notmatch '^[Yy]') {
    Write-Host "操作已取消。"
    pause
    exit
}

# 开始重命名
Write-Host "`n开始重命名..."
$num = 1
$errorOccurred = $false

foreach ($file in $videoFiles) {
    $newName = "$num$($file.Extension)"
    $newPath = Join-Path $targetDir $newName

    # 检查目标文件是否已存在（且不是当前文件本身，理论上不会，但以防万一）
    if (Test-Path $newPath) {
        Write-Host "[错误] 目标文件 '$newName' 已存在，跳过: $($file.Name)" -ForegroundColor Red
        $errorOccurred = $true
        continue
    }

    try {
        Rename-Item -Path $file.FullName -NewName $newName -ErrorAction Stop
        Write-Host "成功: $($file.Name) -> $newName" -ForegroundColor Green
        $num++
    }
    catch {
        Write-Host "[错误] 重命名失败: $($file.Name) - $_" -ForegroundColor Red
        $errorOccurred = $true
    }
}

if ($errorOccurred) {
    Write-Host "`n操作完成，但存在错误或跳过项。" -ForegroundColor Yellow
} else {
    Write-Host "`n所有视频文件已成功重命名！" -ForegroundColor Green
}

pause