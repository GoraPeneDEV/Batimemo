$dir = "C:\Users\LENOVO\Documents\oyee_app\lib\locale"
$files = Get-ChildItem $dir -Filter "language_*.dart" | Select-Object -ExpandProperty FullName

foreach ($file in $files) {
    $content = Get-Content $file -Raw -Encoding UTF8
    $selectDateCount = ([regex]::Matches($content, 'lblSelectDate')).Count
    $changed = $false

    if ($selectDateCount -ge 2) {
        $pattern = '  @override\r?\n  String get lblSelectDate => ''[^'']*'';\r?\n'
        $matchesList = [regex]::Matches($content, $pattern)
        if ($matchesList.Count -ge 2) {
            $lastMatch = $matchesList[$matchesList.Count - 1]
            $content = $content.Remove($lastMatch.Index, $lastMatch.Length)
            $changed = $true
            Write-Host "Removed duplicate lblSelectDate from: $(Split-Path $file -Leaf)"
        }
    }

    if ($content -notmatch 'lblNoItemsFound') {
        $lastBrace = $content.LastIndexOf('}')
        $insertText = "  @override`n  String get lblNoItemsFound => 'No items found';`n"
        $content = $content.Substring(0, $lastBrace) + $insertText + "}`n"
        $changed = $true
        Write-Host "Added lblNoItemsFound to: $(Split-Path $file -Leaf)"
    }

    if ($changed) {
        [System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)
    }
}
Write-Host "Done"
