<#
.SYNOPSIS
    生成 index.html，包含 1~9 的视频和图片，视频使用 <video> 标签（不自动播放，不预加载）。
.DESCRIPTION
    脚本会在当前目录创建 index.html，每个序号对应一个视频（序号.mp4）和一张图片（序号.jpg）。
    视频采用 HTML5 <video> 标签，带控件，不会自动播放，且不预加载视频内容。
#>

$outputFile = "index.html"

$htmlHeader = @'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>壁纸列表</title>
</head>
<body>
    <h1>壁纸列表</h1>
'@

$htmlFooter = @'
</body>
</html>
'@

# 初始化内容
$content = $htmlHeader

# 循环 1 到 9，不添加序号标题
for ($i = 1; $i -le 9; $i++) {
    $content += @"

    <div style="margin-bottom: 20px;">
        <video src="$i.mp4" width="640" height="360" controls preload="none"></video>
        <br>
        <img src="$i.jpg" alt="图片 $i" style="max-width: 640px;">
    </div>
"@
}

$content += $htmlFooter

# 将内容写入文件（覆盖）
$content | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "已生成 $outputFile" -ForegroundColor Green