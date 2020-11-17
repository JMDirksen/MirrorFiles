$sourcePath = "C:\Test\A"
$targetPath = "C:\Test\B"

# Copy/Create new/modified files/folders
Get-ChildItem -Path $sourcePath -Recurse | ForEach-Object {
    $sourceFileName = $_.FullName
    $targetFileName = $_.FullName.Replace($sourcePath, $targetPath)
    if ($_.PSIsContainer) {
        if (-not (Test-Path $targetFileName)) {
            "New folder {0}" -f $targetFileName
            New-Item -Path $targetFileName -ItemType "directory" | Out-Null
        }
    }
    else {
        if (Test-Path $targetFileName) {
            $targetFile = Get-Item -Path $targetFileName
            if ($_.LastWriteTime -ne $targetFile.LastWriteTime -or $_.Length -ne $targetFile.Length) {
                "Modified file {0}" -f $sourceFileName
                Copy-Item -Path $sourceFileName -Destination $targetFileName
            }
        }
        else {
            "New file {0}" -f $sourceFileName
            Copy-Item -Path $sourceFileName -Destination $targetFileName
        }
    }
}

# Remove extra files/folders
Get-ChildItem -Path $targetPath -Recurse | ForEach-Object {
    if (-not (Test-Path $_.FullName.Replace($targetPath, $sourcePath))) {
        $type = if ($_.PSIsContainer) { "folder" } else { "file" }
        "Extra {0} {1}" -f $type, $_.FullName
        Remove-Item -Path $_.FullName -Recurse
    }
}
